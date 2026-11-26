import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../services/payment_service.dart';

/// Email + password login using Supabase's built-in email/password auth.
class AuthProvider extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  AuthProvider() {
    _sub = supabase.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  static String _clean(String email) => email.trim().toLowerCase();

  User? get user => supabase.auth.currentUser;
  String? get userId => user?.id;
  bool get isSignedIn => supabase.auth.currentSession != null;

  String get name => (user?.userMetadata?['name'] as String?)?.trim() ?? '';

  String get email => user?.email ?? '';

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(
      email: _clean(email),
      password: password,
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await supabase.auth.signUp(
      email: _clean(email),
      password: password,
      data: {'name': name},
    );
    // A null session means "Confirm email" is still ON in the dashboard.
    if (res.session == null) throw StateError('email_confirmation_on');
  }

  /// Emails a 6-digit code to a registered address (Supabase "Reset password"
  /// template). Unknown emails get no mail but no error either.
  Future<void> sendResetCode(String email) =>
      supabase.auth.resetPasswordForEmail(_clean(email));

  /// Checks the emailed code. On success Supabase signs the user in with a
  /// short-lived recovery session, which [updatePassword] then uses.
  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    await supabase.auth.verifyOTP(
      email: _clean(email),
      token: code.trim(),
      type: OtpType.recovery,
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  final _paid = <PaymentPurpose, bool>{};
  bool hasPaid(PaymentPurpose purpose) => _paid[purpose] ?? false;

  /// Reads the paid flags from the server (profiles.is_paid /
  /// is_worker_paid) and returns the one for [purpose]. Errors propagate;
  /// until a read succeeds the flags stay "not paid".
  Future<bool> refreshPaid(PaymentPurpose purpose) async {
    final id = userId;
    if (id == null) return false;
    try {
      final row = await supabase
          .from('profiles')
          .select(PaymentPurpose.values.map((p) => p.column).join(','))
          .eq('id', id)
          .maybeSingle();
      for (final p in PaymentPurpose.values) {
        _paid[p] = row?[p.column] == true;
      }
    } finally {
      notifyListeners();
    }
    return hasPaid(purpose);
  }

  /// Permanently deletes the account through the `delete-account` edge
  /// function (photos, listing, reviews, chats and the login all go), then
  /// drops the now-invalid local session. Throws if the server refuses.
  Future<void> deleteAccount() async {
    final res = await supabase.functions.invoke('delete-account');
    final data = res.data;
    if (data is! Map || data['deleted'] != true) {
      throw StateError('delete_failed');
    }
    _paid.clear();
    try {
      await supabase.auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      // The user no longer exists server-side; the local session is junk.
    }
  }

  Future<void> signOut() async {
    _paid.clear();
    await supabase.auth.signOut();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
