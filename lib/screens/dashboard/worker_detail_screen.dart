import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_language.dart';
import '../../l10n/strings.dart';
import '../../models/worker.dart';
import '../../services/contact_actions.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/availability_tag.dart';
import '../../widgets/photo_viewer.dart';
import '../../widgets/worker_avatar.dart';
import 'find_worker_screen.dart' show WorkPhotoStrip;

class WorkerDetailScreen extends StatelessWidget {
  final Worker worker;
  const WorkerDetailScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;
    final category =
        lang == AppLanguage.malayalam ? worker.categoryMl : worker.categoryEn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).maybePop(),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.arrow_back_rounded, size: 20),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.leaf.withValues(alpha: 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: worker.photoUrl == null || worker.photoUrl!.isEmpty
                          ? null
                          : () => PhotoViewer.open(
                                context,
                                [worker.photoUrl!],
                                heroTag: 'avatar_${worker.id}',
                              ),
                      child: worker.photoUrl == null || worker.photoUrl!.isEmpty
                          ? WorkerAvatar(worker: worker, size: 104)
                          : Hero(
                              tag: 'avatar_${worker.id}',
                              child: WorkerAvatar(worker: worker, size: 104),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    worker.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.headingFont,
                      fontSize: AppTheme.headingSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9EFCF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: AppColors.forest,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AvailabilityTag(available: worker.isAvailable),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        '${worker.city}, ${worker.country}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.star_rounded,
                    iconColor: AppColors.roof,
                    value: worker.rating > 0
                        ? worker.rating.toStringAsFixed(1)
                        : S.of(context, 'new_label'),
                    label: S.of(context, 'rating_label'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.workspace_premium_outlined,
                    iconColor: AppColors.leaf,
                    value: '${worker.experienceYears}',
                    label:
                        '${S.of(context, 'experience_label')} · ${S.of(context, 'years_short')}',
                  ),
                ),
              ],
            ),
            if (worker.about.trim().isNotEmpty) ...[
              const SizedBox(height: 28),
              _SectionTitle(S.of(context, 'about')),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration,
                child: Text(
                  worker.about,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.55,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            _SectionTitle(S.of(context, 'work_gallery')),
            const SizedBox(height: 12),
            WorkPhotoStrip(worker: worker, tileSize: 108),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                Material(
                  color: AppColors.background,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => callWorker(context, worker),
                    child: const SizedBox(
                      width: 54,
                      height: 54,
                      child: Icon(Icons.call_rounded,
                          size: 22, color: AppColors.forest),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => messageWorker(context, worker),
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 19),
                      label: Text(
                        S.of(context, 'send_message'),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forest,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final _cardDecoration = BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: const Color(0xFF1B2420).withValues(alpha: 0.05),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ],
);

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.w800,
            fontSize: AppTheme.headingSize),
      );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
