import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shows English text with the Malayalam translation stacked beneath it.
/// Used on splash/auth screens where both languages are always visible.
class BilingualText extends StatelessWidget {
  final String en;
  final String ml;
  final TextAlign align;
  final double enSize;
  final double mlSize;
  final FontWeight enWeight;
  final FontWeight mlWeight;
  final Color? enColor;
  final Color? mlColor;
  final double gap;

  const BilingualText({
    super.key,
    required this.en,
    required this.ml,
    this.align = TextAlign.start,
    this.enSize = 15,
    this.mlSize = 13,
    this.enWeight = FontWeight.w600,
    this.mlWeight = FontWeight.w400,
    this.enColor,
    this.mlColor,
    this.gap = 2,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxis = switch (align) {
      TextAlign.center => CrossAxisAlignment.center,
      TextAlign.end || TextAlign.right => CrossAxisAlignment.end,
      _ => CrossAxisAlignment.start,
    };
    return Column(
      crossAxisAlignment: crossAxis,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          en,
          textAlign: align,
          style: TextStyle(
            fontSize: enSize,
            fontWeight: enWeight,
            color: enColor ?? AppColors.textPrimary,
          ),
        ),
        SizedBox(height: gap),
        Text(
          ml,
          textAlign: align,
          style: TextStyle(
            fontSize: mlSize,
            fontWeight: mlWeight,
            color: mlColor ?? AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Inline "English / മലയാളം" label, e.g. for field hints or short labels.
class BilingualInline extends StatelessWidget {
  final String en;
  final String ml;
  final TextStyle? style;
  const BilingualInline({
    super.key,
    required this.en,
    required this.ml,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style:
            style ??
            const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        children: [
          TextSpan(text: en),
          const TextSpan(
            text: '  •  ',
            style: TextStyle(color: AppColors.divider),
          ),
          TextSpan(
            text: ml,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
