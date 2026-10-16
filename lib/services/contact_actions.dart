import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/strings.dart';
import '../models/worker.dart';
import '../providers/auth_provider.dart';
import '../screens/dashboard/chat_screen.dart';

void _toast(BuildContext context, String key) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(S.read(context, key))));
}

Future<void> callWorker(BuildContext context, Worker worker) async {
  if (worker.phone.isEmpty) return _toast(context, 'no_phone');
  final ok = await launchUrl(Uri(scheme: 'tel', path: worker.phone));
  if (!ok && context.mounted) _toast(context, 'cant_open_dialer');
}

void messageWorker(BuildContext context, Worker worker) {
  final me = context.read<AuthProvider>().userId;
  if (me == null) return _toast(context, 'sign_in_required');
  if (worker.userId == me) return _toast(context, 'cant_message_self');
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
