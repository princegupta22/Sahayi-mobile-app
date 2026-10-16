import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_language.dart';
import '../../l10n/strings.dart';
import '../../providers/worker_directory.dart';
import '../../theme/app_colors.dart';
import 'find_worker_screen.dart';

/// Subcategories of one category group, with their worker counts.
class CategoryScreen extends StatefulWidget {
  final CategoryGroup group;
  const CategoryScreen({super.key, required this.group});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;
    final counts = context.watch<WorkerDirectory>().countsByCategory;
    final g = widget.group;
    final q = _search.text.trim().toLowerCase();
    final subs = g.subs
        .where((s) => q.isEmpty || s.en.toLowerCase().contains(q) || s.ml.contains(q))
        .toList();
    final total = g.subs.fold<int>(0, (a, s) => a + (counts[s.en] ?? 0));

    return Scaffold(
      appBar: AppBar(title: Text(g.label(lang))),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: S.of(context, 'search_categories'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FindWorkerScreen(group: g),
                    )),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [g.color, g.color.withValues(alpha: 0.75)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Icon(g.icon, color: Colors.white, size: 30),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context, 'view_all_workers'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  _countLabel(context, total),
                                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    S.of(context, 'choose_service'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (subs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(S.of(context, 'no_services_match'))),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverGrid.builder(
                itemCount: subs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 128,
                ),
                itemBuilder: (_, i) => _SubTile(
                  sub: subs[i],
                  color: g.color,
                  count: counts[subs[i].en] ?? 0,
                  lang: lang,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => FindWorkerScreen(
                      group: g,
                      initialCategory: subs[i].en,
                    ),
                  )),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _countLabel(BuildContext context, int n) =>
    '$n ${S.of(context, n == 1 ? 'worker_word' : 'workers_word')}';

class _SubTile extends StatelessWidget {
  final WorkCategory sub;
  final Color color;
  final int count;
  final AppLanguage lang;
  final VoidCallback onTap;
  const _SubTile({
    required this.sub,
    required this.color,
    required this.count,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(sub.icon, color: color, size: 23),
            ),
            const Spacer(),
            Text(
              sub.label(lang),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, height: 1.2),
            ),
            const SizedBox(height: 4),
            Text(
              _countLabel(context, count),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: count > 0 ? AppColors.leaf : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
