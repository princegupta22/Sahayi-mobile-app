import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../theme/app_colors.dart';

const List<List<Color>> _avatarGradients = [
  [AppColors.leaf, AppColors.forest],
  [Color(0xFF42A5F5), Color(0xFF1565C0)],
  [AppColors.roof, AppColors.roofDeep],
  [Color(0xFFAB47BC), Color(0xFF6A1B9A)],
  [Color(0xFF26A69A), Color(0xFF00695C)],
];

/// Round avatar: network photo when available, gradient initials otherwise.
class UserAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final int seed;
  final double size;
  const UserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.seed = 0,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = _Initials(name: name, seed: seed, size: size);
    final url = photoUrl;
    if (url == null || url.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => fallback,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;
  final int seed;
  final double size;
  const _Initials({required this.name, required this.seed, required this.size});

  @override
  Widget build(BuildContext context) {
    final colors = _avatarGradients[seed % _avatarGradients.length];
    final trimmed = name.trim();
    final initials = trimmed.isEmpty
        ? '?'
        : trimmed.split(RegExp(r'\s+')).take(2).map((e) => e[0]).join().toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

class WorkerAvatar extends StatelessWidget {
  final Worker worker;
  final double size;
  const WorkerAvatar({super.key, required this.worker, this.size = 56});

  @override
  Widget build(BuildContext context) => UserAvatar(
    name: worker.name,
    photoUrl: worker.photoUrl,
    seed: worker.avatarColorSeed,
    size: size,
  );
}
