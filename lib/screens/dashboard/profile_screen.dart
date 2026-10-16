import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversations_provider.dart';
import '../../providers/worker_directory.dart';
import '../../theme/app_colors.dart';
import '../../widgets/language_toggle.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/worker_avatar.dart';
import '../auth/login_screen.dart';
import 'find_work_screen.dart';
import 'worker_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myListing = context.watch<WorkerDirectory>().myListing;
    final auth = context.watch<AuthProvider>();
    final displayName = auth.name.isEmpty ? S.of(context, 'sahayi_member') : auth.name;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context, 'my_profile'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 3),
                      Text(auth.email.isEmpty ? S.of(context, 'sahayi_member') : auth.email, style: const TextStyle(color: Colors.white70, fontSize: 12.5, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(S.of(context, 'verified'), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(S.of(context, 'my_listing'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 12),
          if (myListing == null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Icon(Icons.work_off_outlined, color: AppColors.textSecondary, size: 30),
                  const SizedBox(height: 10),
                  Text(
                    S.of(context, 'no_listing_yet'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: S.of(context, 'create_listing'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FindWorkScreen()),
                    ),
                  ),
                ],
              ),
            )
          else
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => WorkerDetailScreen(worker: myListing)),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    WorkerAvatar(worker: myListing, size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(myListing.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                          const SizedBox(height: 3),
                          Text(myListing.categoryEn, style: const TextStyle(color: AppColors.leaf, fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: S.of(context, 'edit_listing'),
                      icon: const Icon(Icons.edit_outlined, color: AppColors.forest),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FindWorkScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 28),
          Text(S.of(context, 'settings'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language, color: AppColors.leaf),
                    title: Text(S.of(context, 'language'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    trailing: const LanguageToggle(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: AppColors.danger),
                    title: Text(
                      S.of(context, 'logout'),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.danger),
                    ),
                    onTap: () async {
                      final nav = Navigator.of(context);
                      final directory = context.read<WorkerDirectory>();
                      final convos = context.read<ConversationsProvider>();
                      await convos.stop();
                      directory.clear();
                      await auth.signOut();
                      nav.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
