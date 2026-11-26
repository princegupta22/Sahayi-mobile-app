import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../services/app_errors.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/email_field.dart';
import '../../widgets/field_label.dart';
import '../../widgets/primary_button.dart';
import 'verify_otp_screen.dart';

/// Step 1 of password reset: ask for the registered email and send a code.
class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(text: widget.initialEmail);
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().sendResetCode(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(S.read(context, 'code_sent'))));
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerifyOtpScreen(email: email)),
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
              title: S.of(context, 'forgot_title'),
              subtitle: S.of(context, 'forgot_subtitle'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FieldLabel(S.of(context, 'email_address')),
                    EmailField(
                      controller: _emailController,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: S.of(context, 'send_code'),
                      loading: _loading,
                      onPressed: _send,
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
