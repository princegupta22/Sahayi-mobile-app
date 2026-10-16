import 'package:flutter/material.dart';

/// Rounded square used on category cards: the category photo if one exists
/// in assets/categories/, otherwise a coloured gradient with an icon.
class CategoryThumb extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? imageAsset;
  final double size;
  const CategoryThumb({
    super.key,
    required this.icon,
    required this.color,
    this.imageAsset,
    this.size = 92,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(color, Colors.white, 0.25)!, color],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -size * 0.18,
            bottom: -size * 0.18,
            child: Icon(icon, size: size * 0.75, color: Colors.white.withValues(alpha: 0.18)),
          ),
          Center(child: Icon(icon, size: size * 0.44, color: Colors.white)),
        ],
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: imageAsset == null
          ? fallback
          : Image.asset(
              imageAsset!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}
