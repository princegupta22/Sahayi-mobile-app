import 'package:flutter/material.dart';
import '../../l10n/strings.dart';
import '../../theme/app_colors.dart';
import '../../widgets/language_toggle.dart';
import 'find_work_screen.dart';

/// Second tab: list yourself for work, or jump to the Home tab to find one.
class WorkTab extends StatelessWidget {
  /// Switches the dashboard to the Home (categories) tab.
  final VoidCallback onFindWorker;
  const WorkTab({super.key, required this.onFindWorker});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                S.of(context, 'dashboard_title_work'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              const LanguageToggle(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            S.of(context, 'dashboard_subtitle'),
            style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _ActionCard(
            titleKey: 'find_work_title',
            descKey: 'find_work_desc',
            imagePath: 'assets/work.png',
            gradient: AppColors.roofGradient,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FindWorkScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _ActionCard(
            titleKey: 'find_worker_title',
            descKey: 'find_worker_desc',
            imagePath: 'assets/worker.png',
            gradient: AppColors.primaryGradient,
            onTap: onFindWorker,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String titleKey;
  final String descKey;
  final String imagePath;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.titleKey,
    required this.descKey,
    required this.imagePath,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 74,
              height: 74,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context, titleKey),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context, descKey),
                    style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
