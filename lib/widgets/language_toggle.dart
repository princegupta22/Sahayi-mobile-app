import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_language.dart';
import '../theme/app_colors.dart';

/// Compact English / മലയാളം pill switch, shared by every screen.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageProvider>();
    final isMl = provider.isMalayalam;

    return GestureDetector(
      onTap: provider.toggle,
      child: Container(
        height: 38,
        width: 150,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: isMl ? Alignment.centerRight : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9EFCF),
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                _Label(text: 'English', selected: !isMl),
                _Label(text: 'മലയാളം', selected: isMl),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool selected;
  const _Label({required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected ? AppColors.forest : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
