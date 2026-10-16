import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_language.dart';
import '../../l10n/strings.dart';
import '../../models/worker.dart';
import '../../providers/worker_directory.dart';
import '../../services/app_errors.dart';
import '../../services/contact_actions.dart';
import '../../theme/app_colors.dart';
import '../../widgets/photo_viewer.dart';
import '../../widgets/worker_avatar.dart';
import 'worker_detail_screen.dart';

class FindWorkerScreen extends StatefulWidget {
  /// Restricts the list to one category group (and offers its subcategories
  /// as filter chips). [initialCategory] preselects one subcategory.
  final CategoryGroup? group;
  final String? initialCategory;
  final String? initialQuery;
  const FindWorkerScreen({
    super.key,
    this.group,
    this.initialCategory,
    this.initialQuery,
  });

  @override
  State<FindWorkerScreen> createState() => _FindWorkerScreenState();
}

class _FindWorkerScreenState extends State<FindWorkerScreen> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();
  String? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _searchController.text = widget.initialQuery ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;
    final directory = context.watch<WorkerDirectory>();
    final allWorkers = directory.workers;

    final query = _searchController.text.trim().toLowerCase();
    final location = _locationController.text.trim().toLowerCase();

    final filtered = allWorkers.where((w) {
      final matchesCategory = _category != null
          ? w.categoryEn == _category
          : widget.group == null || widget.group!.contains(w.categoryEn);
      final matchesQuery = query.isEmpty ||
          w.categoryEn.toLowerCase().contains(query) ||
          w.categoryMl.contains(query) ||
          w.name.toLowerCase().contains(query);
      final matchesLocation = location.isEmpty ||
          w.city.toLowerCase().contains(location) ||
          w.country.toLowerCase().contains(location);
      return matchesCategory && matchesQuery && matchesLocation;
    }).toList();

    final content = RefreshIndicator(
      color: AppColors.leaf,
      onRefresh: directory.load,
      child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      _SearchRow(
                        controller: _searchController,
                        icon: Icons.search_rounded,
                        hint: S.of(context, 'search_hint'),
                        onChanged: () => setState(() {}),
                      ),
                      const Divider(height: 1, indent: 14, endIndent: 14),
                      _SearchRow(
                        controller: _locationController,
                        icon: Icons.location_on_outlined,
                        hint: S.of(context, 'filter_by_location'),
                        onChanged: () => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.group != null) SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryFilterChip(
                        label: S.read(context, 'all'),
                        selected: _category == null,
                        onTap: () => setState(() => _category = null),
                      ),
                      ...widget.group!.subs.map(
                        (c) => _CategoryFilterChip(
                          label: c.label(lang),
                          icon: c.icon,
                          selected: _category == c.en,
                          onTap: () => setState(() => _category = c.en),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: widget.group != null ? 18 : 6),
                Row(
                  children: [
                    Text(
                      '${filtered.length} ${S.of(context, 'workers_found')}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (_category != null || query.isNotEmpty || location.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() {
                          _category = null;
                          _searchController.clear();
                          _locationController.clear();
                        }),
                        child: Text(
                          S.of(context, 'clear_filters'),
                          style: const TextStyle(color: AppColors.leaf, fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (directory.loading && allWorkers.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator(color: AppColors.leaf)),
          )
        else if (directory.error != null && allWorkers.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.wifi_off_rounded,
              title: S.of(context, errorKeyFor(directory.error!)),
              action: TextButton(
                onPressed: directory.load,
                child: Text(S.of(context, 'retry')),
              ),
            ),
          )
        else if (allWorkers.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.groups_outlined,
              title: S.of(context, 'no_workers_yet'),
            ),
          )
        else if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.search_off_rounded,
              title: S.of(context, 'no_workers_found'),
              subtitle: S.of(context, 'try_different_search'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) => _WorkerCard(worker: filtered[i], lang: lang),
            ),
          ),
      ],
    ));

    final selected = _category == null ? null : WorkCategory.byEnglish(_category!);
    final title = selected?.label(lang) ??
        widget.group?.label(lang) ??
        S.of(context, 'find_worker_title');

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: content,
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryFilterChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.forest : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppColors.forest : AppColors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: selected ? Colors.white : AppColors.textSecondary),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final VoidCallback onChanged;
  const _SearchRow({
    required this.controller,
    required this.icon,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      style: const TextStyle(fontSize: 14.5),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 21),
        hintText: hint,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final Worker worker;
  final AppLanguage lang;
  const _WorkerCard({required this.worker, required this.lang});

  @override
  Widget build(BuildContext context) {
    final category =
        lang == AppLanguage.malayalam ? worker.categoryMl : worker.categoryEn;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => WorkerDetailScreen(worker: worker)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B2420).withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WorkerAvatar(worker: worker, size: 60),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        category,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${worker.city}, ${worker.country}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          worker.rating > 0
                              ? Icons.star_rounded
                              : Icons.auto_awesome_rounded,
                          size: 15,
                          color: AppColors.roof),
                      const SizedBox(width: 3),
                      Text(
                        worker.rating > 0
                            ? worker.rating.toStringAsFixed(1)
                            : S.of(context, 'new_label'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.roofDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_outlined,
                      size: 17, color: AppColors.leaf),
                  const SizedBox(width: 8),
                  Text(
                    '${worker.experienceYears} ${S.of(context, 'years_exp')}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (worker.workPhotoUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              WorkPhotoStrip(worker: worker, tileSize: 64),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Material(
                  color: AppColors.background,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => callWorker(context, worker),
                    child: const SizedBox(
                      width: 46,
                      height: 46,
                      child: Icon(Icons.call_rounded,
                          size: 20, color: AppColors.forest),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () => messageWorker(context, worker),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
                      label: Text(
                        S.of(context, 'send_message'),
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forest,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Row of the worker's uploaded work photos. Falls back to a few
/// category-themed placeholder tiles when no photos were uploaded
/// (e.g. sample/demo listings), so a post never looks empty.
class WorkPhotoStrip extends StatelessWidget {
  final Worker worker;
  final double tileSize;
  const WorkPhotoStrip({super.key, required this.worker, this.tileSize = 84});

  @override
  Widget build(BuildContext context) {
    if (worker.workPhotoUrls.isNotEmpty) {
      return SizedBox(
        height: tileSize,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: worker.workPhotoUrls.length,
          separatorBuilder: (_, i) => const SizedBox(width: 8),
          itemBuilder: (context, i) => GestureDetector(
            onTap: () => PhotoViewer.open(
              context,
              worker.workPhotoUrls,
              initialIndex: i,
            ),
            child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              worker.workPhotoUrls[i],
              width: tileSize,
              height: tileSize,
              fit: BoxFit.cover,
              errorBuilder: (_, e, st) => Container(
                width: tileSize,
                height: tileSize,
                color: AppColors.divider,
                child: const Icon(Icons.broken_image_outlined,
                    color: AppColors.textSecondary),
              ),
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(
                      width: tileSize,
                      height: tileSize,
                      color: AppColors.divider.withValues(alpha: 0.5),
                    ),
            ),
          ),
          ),
        ),
      );
    }

    final gradients = [
      [AppColors.leaf, AppColors.forest],
      [AppColors.roof, AppColors.roofDeep],
      [const Color(0xFF42A5F5), const Color(0xFF1565C0)],
    ];
    return Row(
      children: List.generate(3, (i) {
        final colors = gradients[(worker.avatarColorSeed + i) % gradients.length];
        return Padding(
          padding: EdgeInsets.only(right: i == 2 ? 0 : 8),
          child: Container(
            width: tileSize,
            height: tileSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors[0].withValues(alpha: 0.16), colors[1].withValues(alpha: 0.16)],
              ),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.image_outlined, color: colors[1], size: tileSize * 0.34),
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  const _EmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.divider),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
            ],
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}
