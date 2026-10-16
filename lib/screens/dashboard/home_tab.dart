import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_language.dart';
import '../../l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_directory.dart';
import '../../theme/app_colors.dart';
import '../../widgets/category_thumb.dart';
import '../../widgets/language_toggle.dart';
import 'category_screen.dart';
import 'find_worker_screen.dart';

/// First tab: every category with search. Tapping a category opens its
/// subcategories, and a subcategory opens the workers listed under it.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openGroup(CategoryGroup g) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CategoryScreen(group: g)),
      );

  void _openSub(WorkCategory c) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FindWorkerScreen(
            group: CategoryGroup.byId(c.groupId),
            initialCategory: c.en,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;
    final counts = context.watch<WorkerDirectory>().countsByCategory;
    final raw = _search.text.trim();
    final q = raw.toLowerCase();
    final searching = q.isNotEmpty;

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
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context, 'find_worker_desc'),
            style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {},
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: S.of(context, 'search_categories'),
              suffixIcon: searching
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => setState(_search.clear),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          if (searching)
            ..._results(context, lang, counts, q, raw)
          else ...[
            Text(
              S.of(context, 'all_services'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
        ],
      ),
    );
  }

  List<Widget> _results(BuildContext context, AppLanguage lang,
      Map<String, int> counts, String q, String raw) {
    bool hit(String en, String ml) => en.toLowerCase().contains(q) || ml.contains(q);
    final groups = CategoryGroup.all.where((g) => hit(g.en, g.ml)).toList();
    final subs = WorkCategory.all.where((c) => hit(c.en, c.ml)).toList();

    return [
      if (groups.isEmpty && subs.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              S.of(context, 'no_services_match'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        )
      else
        _CardList(
          rows: [
            for (final g in groups)
              _CardRow(
                thumb: CategoryThumb(icon: g.icon, color: g.color, imageAsset: g.imageAsset),
                title: g.label(lang),
                subtitle: g.preview(lang, count: 6),
                footer: _countText(context, _groupCount(g, counts)),
                onTap: () => _openGroup(g),
              ),
            for (final c in subs)
              _CardRow(
                thumb: CategoryThumb(
                  icon: c.icon,
                  color: CategoryGroup.byId(c.groupId)?.color ?? AppColors.leaf,
                ),
                title: c.label(lang),
                subtitle: CategoryGroup.byId(c.groupId)?.label(lang) ?? '',
                footer: _countText(context, counts[c.en] ?? 0),
                onTap: () => _openSub(c),
              ),
          ],
        ),
      const SizedBox(height: 14),
      _CardList(
        rows: [
          _CardRow(
            thumb: const CategoryThumb(
              icon: Icons.person_search_rounded,
              color: AppColors.roofDeep,
              size: 56,
            ),
            title: '${S.of(context, 'search_workers_for')} “$raw”',
            subtitle: S.of(context, 'find_worker_title'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => FindWorkerScreen(initialQuery: raw),
            )),
          ),
        ],
      ),
    ];
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
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  if (footer != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      footer!,
                      style: const TextStyle(
                        color: AppColors.leaf,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
