import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../config/supabase_config.dart';

enum PaymentOutcome { success, cancelled }

/// The one-time payments, each with its own flag on profiles. Prices are
/// display only; the charged amount is fixed in the edge functions.
enum PaymentPurpose {
  /// Messaging and calling workers.
  contact('is_paid', '₹99', 'One-time contact unlock (Inclusive of all Taxes)'),

  /// Publishing your own worker profile.
  listing('is_worker_paid', '₹99', 'One-time worker profile fee (Inclusive of all Taxes)');

  final String column;
  final String price;
  final String description;
  const PaymentPurpose(this.column, this.price, this.description);
}

/// Razorpay checkout for a [PaymentPurpose]. The amount, order and signature
/// check all live in Supabase edge functions; the app never sees the
/// Razorpay secret.
class PaymentService {
  /// Opens checkout and resolves once the server has verified the payment.
  /// Throws StateError('payment_failed') if verification fails.
  static Future<PaymentOutcome> pay({
    required PaymentPurpose purpose,
    required String name,
    required String email,
  }) async {
    final res = await supabase.functions.invoke(
      'create-razorpay-order',
      body: {'purpose': purpose.name},
    );
    final data = res.data as Map<String, dynamic>;
    if (data['already_paid'] == true) return PaymentOutcome.success;
    final orderId = data['order_id'] as String?;
    final keyId = data['key_id'] as String?;
    if (orderId == null || keyId == null) throw StateError('payment_failed');

    final razorpay = Razorpay();
    final done = Completer<PaymentOutcome>();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
        (PaymentSuccessResponse r) async {
      try {
        final v = await supabase.functions.invoke(
          'verify-razorpay-payment',
          body: {
            'razorpay_order_id': r.orderId,
            'razorpay_payment_id': r.paymentId,
            'razorpay_signature': r.signature,
          },
        );
        final ok = (v.data as Map<String, dynamic>?)?['paid'] == true;
        if (ok) {
          done.complete(PaymentOutcome.success);
        } else {
          done.completeError(StateError('payment_failed'));
        }
      } catch (e) {
        done.completeError(e);
      }
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
      // code 0 = user dismissed the checkout
      if (r.code == Razorpay.PAYMENT_CANCELLED) {
        done.complete(PaymentOutcome.cancelled);
      } else {
        done.completeError(StateError('payment_failed'));
      }
    });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});

    razorpay.open({
      'key': keyId,
      'order_id': orderId,
      'amount': data['amount'],
      'currency': 'INR',
      'name': 'Sahayi',
      'description': purpose.description,
      'prefill': {'email': email, 'name': name},
      'theme': {'color': '#2E7D32'},
    });

    try {
      return await done.future;
    } finally {
      razorpay.clear();
    }
  }
}
