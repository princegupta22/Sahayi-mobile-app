import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../services/app_errors.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/field_label.dart';
import '../../widgets/email_field.dart';
import '../../widgets/primary_button.dart';
import '../dashboard/dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(
              title: S.of(context, 'log_in'),
              subtitle: S.of(context, 'welcome_back_login'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FieldLabel(S.of(context, 'email_address')),
                    EmailField(controller: _emailController),
                    const SizedBox(height: 20),
                    FieldLabel(S.of(context, 'password')),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.leaf),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        hintText: '••••••••',
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? S.read(context, 'err_password')
                          : null,
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: S.of(context, 'log_in'),
                      loading: _loading,
                      onPressed: _login,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${S.of(context, 'no_account')} ',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SignupScreen()),
                          ),
                          child: Text(
                            S.of(context, 'sign_up'),
                            style: const TextStyle(
                              color: AppColors.leaf,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
