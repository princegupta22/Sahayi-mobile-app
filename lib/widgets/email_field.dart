import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';

final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

/// Email field used for sign-up and log-in.
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;
  const EmailField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.leaf),
        hintText: S.of(context, 'email_hint'),
      ),
      validator: (v) => (v == null || !_emailRe.hasMatch(v.trim()))
          ? S.read(context, 'err_email')
          : null,
    );
  }
}
