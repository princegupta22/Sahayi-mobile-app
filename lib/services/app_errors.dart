import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps any thrown error to a key in the S translation table.
String errorKeyFor(Object e) {
  if (e is AuthException) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
      return 'err_invalid_login';
    }
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return 'err_phone_taken';
    }
    if (msg.contains('password') && msg.contains('characters')) {
      return 'err_password';
    }
    if (msg.contains('rate limit') || e.statusCode == '429') {
      return 'err_rate_limit';
    }
  }
  if (e is SocketException ||
      e is TimeoutException ||
      e.toString().contains('SocketException') ||
      e.toString().contains('ClientException') ||
      e.toString().contains('Failed host lookup')) {
    return 'err_network';
  }
  if (e is StateError && e.message == 'email_confirmation_on') {
    return 'err_setup_confirm';
  }
  if (e is StateError && e.message == 'payment_failed') {
    return 'err_payment';
  }
  return 'err_generic';
}
