import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';

/// Small "Available" (green) / "Booked" (red) pill shown on worker profiles.
class AvailabilityTag extends StatelessWidget {
  final bool available;
  const AvailabilityTag({super.key, required this.available});

  @override
  Widget build(BuildContext context) {
    final color = available ? AppColors.leaf : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            S.of(context, available ? 'available' : 'booked'),
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
