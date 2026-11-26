import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../services/app_errors.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/field_label.dart';
import '../../widgets/primary_button.dart';
import 'reset_password_screen.dart';

/// Step 2: enter the 6-digit code from the email.
class VerifyOtpScreen extends StatefulWidget {
  final String email;
  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  // Supabase's "Email OTP Length" setting is 6 to 10 digits; accept any.
  static const _minCodeLength = 6;
  static const _maxCodeLength = 10;
  static const _cooldown = 60; // Supabase allows one reset email a minute

  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _loading = false;
  bool _resending = false;
  int _secondsLeft = _cooldown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _cooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) t.cancel();
    });
  }

  void _toast(String key) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(S.read(context, key))));
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().verifyResetCode(
        email: widget.email,
        code: _codeController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _toast(errorKeyFor(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await context.read<AuthProvider>().sendResetCode(widget.email);
      if (!mounted) return;
      _codeController.clear();
      _startTimer();
      _toast('code_sent');
    } catch (e) {
      if (!mounted) return;
      _toast(errorKeyFor(e));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft <= 0 && !_resending;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(
              showBack: true,
              title: S.of(context, 'verify_title'),
              subtitle: '${S.of(context, 'otp_subtitle')}\n${widget.email}',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FieldLabel(S.of(context, 'otp_label')),
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      textAlign: TextAlign.center,
                      maxLength: _maxCodeLength,
                      onFieldSubmitted: (_) => _verify(),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 8,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: '••••••••',
                      ),
                      validator: (v) => (v == null || v.length < _minCodeLength)
                          ? S.read(context, 'err_otp')
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context, 'otp_spam_hint'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: S.of(context, 'verify_btn'),
                      loading: _loading,
                      onPressed: _verify,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: canResend
                          ? TextButton(
                              onPressed: _resend,
                              child: Text(
                                S.of(context, 'resend_code'),
                                style: const TextStyle(
                                  color: AppColors.leaf,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                '${S.of(context, 'resend_in')} 0:${_secondsLeft.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
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
