import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/supabase_config.dart';
import '../l10n/strings.dart';
import '../models/worker.dart';
import '../providers/auth_provider.dart';
import '../screens/dashboard/chat_screen.dart';
import '../screens/payment/payment_screen.dart';
import 'app_errors.dart';
import 'payment_service.dart';

void _toast(BuildContext context, String key) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(S.read(context, key))));
}

/// Messaging or calling a worker needs the one-time ₹99 unlock
/// (profiles.is_paid). Opens checkout if it isn't paid yet; true once it is.
Future<bool> _unlockContact(BuildContext context, Worker worker) async {
  final auth = context.read<AuthProvider>();
  if (auth.userId == null) {
    _toast(context, 'sign_in_required');
    return false;
  }
  if (worker.userId == auth.userId) {
    _toast(context, 'cant_message_self');
    return false;
  }
  return PaymentScreen.ensurePaid(context, PaymentPurpose.contact);
}

Future<void> callWorker(BuildContext context, Worker worker) async {
  if (!await _unlockContact(context, worker) || !context.mounted) return;
  // Phone numbers aren't readable from the workers table; the server only
  // hands them to paid users.
  final String? phone;
  try {
    phone = await supabase.rpc('worker_phone', params: {'wid': worker.id})
        as String?;
  } catch (e) {
    if (context.mounted) _toast(context, errorKeyFor(e));
    return;
  }
  if (!context.mounted) return;
  if (phone == null || phone.isEmpty) return _toast(context, 'no_phone');
  final ok = await launchUrl(Uri(scheme: 'tel', path: phone));
  if (!ok && context.mounted) _toast(context, 'cant_open_dialer');
}

Future<void> messageWorker(BuildContext context, Worker worker) async {
  if (!await _unlockContact(context, worker) || !context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ChatScreen(
        otherUserId: worker.userId,
        otherName: worker.name,
        otherAvatarUrl: worker.photoUrl,
        subtitle: worker.categoryEn,
      ),
    ),
  );
}
