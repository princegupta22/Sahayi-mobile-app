import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

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

  bool _isPaid = false;
  bool get isPaid => _isPaid;

  /// Reads the paid flag from the server (profiles.is_paid). Fails closed:
  /// any error means "not paid".
  Future<bool> refreshPaid() async {
    final id = userId;
    if (id == null) return _isPaid = false;
    try {
      final row = await supabase
          .from('profiles')
          .select('is_paid')
          .eq('id', id)
          .maybeSingle();
      _isPaid = row?['is_paid'] == true;
    } catch (_) {
      rethrow;
    } finally {
      notifyListeners();
    }
    return _isPaid;
  }

  Future<void> signOut() async {
    _isPaid = false;
    await supabase.auth.signOut();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
