import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../services/app_errors.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/field_label.dart';
import '../../widgets/primary_button.dart';
import 'login_screen.dart';

/// Step 3: choose a new password (the code check already signed the user in
/// with a recovery session). Afterwards we sign out and go to log in.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _done = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    setState(() => _loading = true);
    try {
      await auth.updatePassword(_passwordController.text);
      _done = true;
      await auth.signOut(); // make them log in with the new password
      if (!mounted) return;
      await _showSuccess();
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.read(context, errorKeyFor(e)))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showSuccess() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
          Navigator.of(dialogContext).pop();
        }
      });
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: AppColors.leaf,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                S.read(context, 'password_updated'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppTheme.headingSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                S.read(context, 'password_updated_hint'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    },
  );

  InputDecoration _decoration() => InputDecoration(
    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.leaf),
    suffixIcon: IconButton(
      icon: Icon(
        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textSecondary,
      ),
      onPressed: () => setState(() => _obscure = !_obscure),
    ),
    hintText: '••••••••',
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Leaving without saving must not leave the recovery session signed in.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !_done) context.read<AuthProvider>().signOut();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                showBack: true,
                title: S.of(context, 'reset_title'),
                subtitle: S.of(context, 'reset_subtitle'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FieldLabel(S.of(context, 'new_password')),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration(),
                        validator: (v) => (v == null || v.length < 6)
                            ? S.read(context, 'err_password')
                            : null,
                      ),
                      const SizedBox(height: 20),
                      FieldLabel(S.of(context, 'confirm_password')),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _save(),
                        decoration: _decoration(),
                        validator: (v) => v != _passwordController.text
                            ? S.read(context, 'err_match')
                            : null,
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: S.of(context, 'update_password'),
                        loading: _loading,
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
