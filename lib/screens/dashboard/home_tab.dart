import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_language.dart';
import '../../l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_directory.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_thumb.dart';
import '../../widgets/language_toggle.dart';
import '../../widgets/primary_button.dart';
import 'category_screen.dart';
import 'find_worker_screen.dart';

/// First tab: a service + city search, then every category. Search opens
/// the matching workers; tapping a category opens its subcategories.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _service = TextEditingController();
  final _city = TextEditingController();

  @override
  void dispose() {
    _service.dispose();
    _city.dispose();
    super.dispose();
  }

  void _searchWorkers() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FindWorkerScreen(
        initialQuery: _service.text.trim(),
        initialLocation: _city.text.trim(),
      ),
    ));
  }

  void _openGroup(CategoryGroup g) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CategoryScreen(group: g)),
      );

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;
    final counts = context.watch<WorkerDirectory>().countsByCategory;

    return RefreshIndicator(
      color: AppColors.leaf,
      onRefresh: context.read<WorkerDirectory>().load,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Sahayi',
                style: TextStyle(
                  fontFamily: AppTheme.headingFont,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.forest,
                ),
              ),
              const Spacer(),
              const LanguageToggle(),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            _greeting(context),
            style: const TextStyle(
              fontFamily: AppTheme.headingFont,
              fontSize: AppTheme.headingSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context, 'find_worker_desc'),
            style: const TextStyle(fontSize: AppTheme.subheadingSize, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _service,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.handyman_outlined),
              hintText: S.of(context, 'search_categories'),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _city,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _searchWorkers(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.location_on_outlined),
              hintText: S.of(context, 'enter_city'),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: S.of(context, 'search'),
            icon: Icons.search_rounded,
            onPressed: _searchWorkers,
          ),
          const SizedBox(height: 24),
          Text(
            S.of(context, 'all_services'),
            style: const TextStyle(fontFamily: AppTheme.headingFont, fontWeight: FontWeight.w800, fontSize: AppTheme.headingSize),
          ),
          const SizedBox(height: 12),
          _CardList(
            rows: [
              for (final g in CategoryGroup.all)
                _CardRow(
                  thumb: CategoryThumb(
                    icon: g.icon,
                    color: g.color,
                    imageAsset: g.imageAsset,
                  ),
                  title: g.label(lang),
                  subtitle: g.preview(lang, count: 6),
                  footer: _countText(context, _groupCount(g, counts)),
                  onTap: () => _openGroup(g),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

int _groupCount(CategoryGroup g, Map<String, int> counts) =>
    g.subs.fold<int>(0, (a, s) => a + (counts[s.en] ?? 0));

String _countText(BuildContext context, int n) =>
    '$n ${S.of(context, n == 1 ? 'worker_word' : 'workers_word')}';

String _greeting(BuildContext context) {
  final name = context.watch<AuthProvider>().name.split(' ').first;
  final base = S.of(context, 'greeting');
  return name.isEmpty ? base : '$base, $name';
}

/// One big rounded card with divider-separated rows (as in the design).
class _CardList extends StatelessWidget {
  final List<Widget> rows;
  const _CardList({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              const Divider(height: 1, indent: 18, endIndent: 18),
          ],
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final Widget thumb;
  final String title;
  final String subtitle;
  final String? footer;
  final VoidCallback onTap;
  const _CardRow({
    required this.thumb,
    required this.title,
    required this.subtitle,
    this.footer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            thumb,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppTheme.headingFont,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppTheme.subheadingSize,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  if (footer != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.forest.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        footer!,
                        style: const TextStyle(
                          color: AppColors.forest,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.forest),
          ],
        ),
      ),
    );
  }
}
