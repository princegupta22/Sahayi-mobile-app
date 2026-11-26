import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;
import '../config/supabase_config.dart';

enum PaymentOutcome { success, cancelled, pending }

/// The one-time purchases, each with its own flag on profiles. Prices are
/// display only; set the real price on the product in Google Play Console.
enum PaymentPurpose {
  /// Messaging and calling workers.
  contact('is_paid', 'contact_unlock', '₹149'),

  /// Publishing your own worker profile.
  listing('is_worker_paid', 'worker_listing', '₹149');

  final String column;

  /// Product id in Google Play Console (In-app products → one-time product).
  /// Must match PURPOSES in supabase/functions/_shared/common.ts.
  final String productId;
  final String price;
  const PaymentPurpose(this.column, this.productId, this.price);

  static PaymentPurpose? byProductId(String id) =>
      values.where((p) => p.productId == id).firstOrNull;
}

/// Google Play Billing for a [PaymentPurpose] (Android only; there is no
/// purchase flow on iOS). The app only collects the purchase; a Supabase edge
/// function checks it with Google and unlocks the account.
class PaymentService {
  static bool get supported => !kIsWeb && Platform.isAndroid;

  /// Opens the Google Play purchase sheet and resolves once the server has
  /// verified the purchase.
  /// Throws StateError: android_only, billing_unavailable, product_not_found,
  /// purchase_used or payment_failed.
  static Future<PaymentOutcome> pay({
    required PaymentPurpose purpose,
    required String userId,
  }) async {
    if (!supported) throw StateError('android_only');

    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) throw StateError('billing_unavailable');

    final found = await iap.queryProductDetails({purpose.productId});
    if (found.productDetails.isEmpty) throw StateError('product_not_found');
    final product = found.productDetails.first;

    final done = Completer<PaymentOutcome>();
    var claimedLeftover = false; // an earlier purchase we are finishing now

    Future<void> handle(PurchaseDetails p) async {
      final mine = PaymentPurpose.byProductId(p.productID);
      switch (p.status) {
        case PurchaseStatus.pending:
          return; // the sheet is still open / waiting on the bank
        case PurchaseStatus.canceled:
          if (!done.isCompleted) done.complete(PaymentOutcome.cancelled);
        case PurchaseStatus.error:
          if (!done.isCompleted) {
            done.completeError(StateError('payment_failed'));
          }
        case PurchaseStatus.purchased || PurchaseStatus.restored:
          if (mine == null) return;
          if (p.status == PurchaseStatus.restored && mine == purpose) {
            claimedLeftover = true;
          }
          try {
            final outcome = await _verify(mine, p);
            if (p.pendingCompletePurchase) {
              // The server consumes it; this just acknowledges as a fallback.
              unawaited(iap.completePurchase(p).catchError((_) => null));
            }
            if (mine == purpose && !done.isCompleted) done.complete(outcome);
          } catch (e) {
            if (mine == purpose && !done.isCompleted) done.completeError(e);
          }
      }
    }

    final sub = iap.purchaseStream.listen(
      (list) {
        for (final p in list) {
          handle(p);
        }
      },
      onError: (Object e) {
        if (!done.isCompleted) done.completeError(StateError('payment_failed'));
      },
    );

    try {
      final started = await iap.buyConsumable(
        // applicationUserName tags the purchase with the buyer; the server
        // rejects it if it belongs to someone else.
        purchaseParam: PurchaseParam(
          productDetails: product,
          applicationUserName: userId,
        ),
        autoConsume: false, // consumed by the server after it unlocks the account
      );
      if (!started) {
        // Usually "already owned": a purchase from an earlier attempt was
        // never finished (app closed mid-payment). Finish it instead.
        await iap.restorePurchases();
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (!claimedLeftover && !done.isCompleted) {
          throw StateError('payment_failed');
        }
      }
      return await done.future;
    } finally {
      await sub.cancel();
    }
  }

  static Future<PaymentOutcome> _verify(
    PaymentPurpose purpose,
    PurchaseDetails p,
  ) async {
    try {
      final res = await supabase.functions.invoke(
        'verify-play-purchase',
        body: {
          'purpose': purpose.name,
          'product_id': p.productID,
          'purchase_token': p.verificationData.serverVerificationData,
        },
      );
      final data = res.data as Map<String, dynamic>?;
      if (data?['paid'] == true) return PaymentOutcome.success;
      if (data?['pending'] == true) return PaymentOutcome.pending;
      throw StateError('payment_failed');
    } on FunctionException catch (e) {
      throw StateError(e.status == 409 ? 'purchase_used' : 'payment_failed');
    }
  }
}
