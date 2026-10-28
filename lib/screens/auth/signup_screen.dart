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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(
              showBack: true,
              title: S.of(context, 'create_account'),
              subtitle: S.of(context, 'signup_subtitle'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FieldLabel(S.of(context, 'full_name')),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline_rounded,
                            color: AppColors.leaf),
                        hintText: S.of(context, 'name_hint'),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? S.read(context, 'err_name')
                          : null,
                    ),
                    const SizedBox(height: 20),
                    FieldLabel(S.of(context, 'email_address')),
                    EmailField(controller: _emailController),
                    const SizedBox(height: 20),
                    FieldLabel(S.of(context, 'password')),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 20),
                    FieldLabel(S.of(context, 'confirm_password')),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _signup(),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_person_outlined,
                            color: AppColors.leaf),
                        hintText: '••••••••',
                      ),
                      validator: (v) => (v != _passwordController.text)
                          ? S.read(context, 'err_match')
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _ConsentField(
                      text: S.of(context, 'consent_terms'),
                      error: S.of(context, 'err_consent'),
                    ),
                    const SizedBox(height: 14),
                    _ConsentField(
                      text: S.of(context, 'consent_no_bypass'),
                      error: S.of(context, 'err_consent'),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: S.of(context, 'create_account'),
                      loading: _loading,
                      onPressed: _signup,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${S.of(context, 'have_account')} ',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            S.of(context, 'log_in'),
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

/// Required tick box: the signup form won't validate until it is ticked.
class _ConsentField extends FormField<bool> {
  _ConsentField({required String text, required String error})
      : super(
          initialValue: false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (v) => v == true ? null : error,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => field.didChange(field.value != true),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: field.value,
                        onChanged: field.didChange,
                        activeColor: AppColors.leaf,
                        side: BorderSide(
                          color: field.hasError
                              ? AppColors.danger
                              : AppColors.textSecondary,
                          width: 1.6,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 34, top: 4),
                  child: Text(
                    field.errorText!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
}
