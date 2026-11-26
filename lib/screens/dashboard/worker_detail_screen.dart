import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_language.dart';
import '../../l10n/strings.dart';
import '../../models/worker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_directory.dart';
import '../../services/app_errors.dart';
import '../../services/reviews_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/availability_tag.dart';
import '../../widgets/contact_buttons.dart';
import '../../utils/time_format.dart';
import '../../widgets/photo_viewer.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/worker_avatar.dart';
import 'find_worker_screen.dart' show WorkPhotoStrip;

class WorkerDetailScreen extends StatefulWidget {
  final Worker worker;
  const WorkerDetailScreen({super.key, required this.worker});

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  List<Review> _reviews = const [];
  bool _loadingReviews = true;
  bool _reviewsFailed = false;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _loadingReviews = true;
      _reviewsFailed = false;
    });
    try {
      final list = await ReviewsService.forWorker(widget.worker.id);
      if (!mounted) return;
      setState(() => _reviews = list);
    } catch (e) {
      debugPrint('load reviews failed: $e');
      if (mounted) setState(() => _reviewsFailed = true);
    } finally {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  Review? _myReview(String? uid) =>
      uid == null ? null : _reviews.where((r) => r.reviewerId == uid).firstOrNull;

  /// Opens the rating sheet; on success refreshes the reviews and the
  /// worker's average (recalculated by the database).
  Future<void> _openReviewSheet() async {
    final messenger = ScaffoldMessenger.of(context);
    final directory = context.read<WorkerDirectory>();
    final errorFallback = S.read(context, 'err_generic');

    Review? mine;
    try {
      mine = await ReviewsService.mine(widget.worker.id);
    } catch (e) {
      debugPrint('load my review failed: $e');
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(kDebugMode ? '$errorFallback ($e)' : errorFallback),
        ));
      return;
    }
    if (!mounted) return;

    final result = await showModalBottomSheet<_ReviewResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ReviewSheet(workerId: widget.worker.id, existing: mine),
    );
    if (result == null || !mounted) return;
    final msg = S.read(
      context,
      result == _ReviewResult.deleted ? 'review_deleted' : 'review_saved',
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
    await Future.wait([_loadReviews(), directory.load()]);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;
    // Prefer the freshly loaded copy so the average updates after a review.
    final worker = context.select<WorkerDirectory, Worker>(
      (d) => d.workers.where((w) => w.id == widget.worker.id).firstOrNull ??
          widget.worker,
    );
    final uid = context.watch<AuthProvider>().userId;
    final isOwn = uid != null && worker.userId == uid;
    final mine = _myReview(uid);
    final category = worker.serviceLabel(lang);

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
                    value: worker.rating.toStringAsFixed(1),
                    label:
                        '${S.of(context, 'rating_label')} · ${worker.ratingCount}',
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
            const SizedBox(height: 28),
            _SectionTitle(S.of(context, 'ratings_reviews')),
            const SizedBox(height: 12),
            _RatingSummary(worker: worker),
            const SizedBox(height: 12),
            if (isOwn)
              Text(
                S.of(context, 'own_listing_no_rate'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12.5),
              )
            else
              PrimaryButton(
                label: S.of(context,
                    mine == null ? 'rate_worker' : 'edit_review'),
                icon: mine == null ? Icons.star_rounded : Icons.edit_outlined,
                outlined: true,
                onPressed: _openReviewSheet,
              ),
            const SizedBox(height: 14),
            _buildReviewList(context, lang, uid),
          ],
        ),
      ),
      // Nothing at all when the worker turned both calls and messages off.
      bottomNavigationBar: ContactButtons.isVisible(worker)
          ? Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: ContactButtons(worker: worker),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildReviewList(BuildContext context, AppLanguage lang, String? uid) {
    if (_loadingReviews && _reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
      );
    }
    if (_reviewsFailed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration,
        child: Column(
          children: [
            Text(
              S.of(context, 'reviews_load_failed'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: _loadReviews,
              child: Text(S.of(context, 'retry')),
            ),
          ],
        ),
      );
    }
    if (_reviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration,
        child: Text(
          S.of(context, 'no_reviews_yet'),
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13, height: 1.45),
        ),
      );
    }
    const collapsed = 3;
    final visible = _showAll ? _reviews : _reviews.take(collapsed).toList();
    return Column(
      children: [
        for (final r in visible) ...[
          _ReviewTile(review: r, isMine: r.reviewerId == uid, lang: lang),
          const SizedBox(height: 10),
        ],
        if (_reviews.length > collapsed)
          TextButton(
            onPressed: () => setState(() => _showAll = !_showAll),
            child: Text(S.of(
                context, _showAll ? 'show_fewer_reviews' : 'show_all_reviews')),
          ),
      ],
    );
  }
}

enum _ReviewResult { saved, deleted }

/// Row of five stars, filled up to [rating] (supports halves for averages).
class _Stars extends StatelessWidget {
  final double rating;
  final double size;
  const _Stars({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              rating >= i - 0.25
                  ? Icons.star_rounded
                  : rating >= i - 0.75
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              size: size,
              color: AppColors.roof,
            ),
        ],
      );
}

/// Five big stars; tap or slide to choose 0.5 – 5.0 in half steps
/// (left half of a star = .5, right half = full).
class _StarPicker extends StatelessWidget {
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;
  const _StarPicker(
      {required this.value, required this.enabled, required this.onChanged});

  static const _star = 46.0;

  void _update(double dx) {
    if (!enabled) return;
    final halves = (dx / (_star / 2)).ceil().clamp(1, 10);
    onChanged(halves / 2);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => _update(d.localPosition.dx),
      onHorizontalDragUpdate: (d) => _update(d.localPosition.dx),
      child: SizedBox(
        width: _star * 5,
        height: _star + 8,
        child: Center(child: _Stars(rating: value, size: _star)),
      ),
    );
  }
}

/// Big average + stars + review count, or a hint when nobody rated yet.
class _RatingSummary extends StatelessWidget {
  final Worker worker;
  const _RatingSummary({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Text(
            worker.rating.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: AppTheme.headingFont,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Stars(rating: worker.hasRating ? worker.rating : 0, size: 22),
                const SizedBox(height: 4),
                Text(
                  '${worker.ratingCount} ${S.of(context, 'reviews_label')}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  final bool isMine;
  final AppLanguage lang;
  const _ReviewTile(
      {required this.review, required this.isMine, required this.lang});

  @override
  Widget build(BuildContext context) {
    final name = isMine
        ? S.of(context, 'you_label')
        : (review.reviewerName.isEmpty
            ? S.of(context, 'sahayi_member')
            : review.reviewerName);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                name: review.reviewerName,
                photoUrl: review.reviewerAvatarUrl,
                seed: review.reviewerId.hashCode.abs(),
                size: 36,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _Stars(rating: review.rating, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          formatDayLabel(review.createdAt, lang),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment.trim(),
              style: const TextStyle(
                  color: AppColors.textSecondary, height: 1.5, fontSize: 13.5),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet: pick 1-5 stars, optionally write a message, save.
/// Pops with a [_ReviewResult] when something changed.
class _ReviewSheet extends StatefulWidget {
  final String workerId;
  final Review? existing;
  const _ReviewSheet({required this.workerId, this.existing});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  late double _rating = widget.existing?.rating ?? 0;
  late final _comment = TextEditingController(text: widget.existing?.comment);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, _ReviewResult result) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop(result);
    } catch (e) {
      debugPrint('review save failed: $e');
      if (mounted) {
        setState(() {
          _busy = false;
          final base = S.read(context, errorKeyFor(e));
          _error = kDebugMode ? '$base ($e)' : base;
        });
      }
    }
  }

  void _submit() {
    if (_rating == 0) {
      setState(() => _error = S.read(context, 'pick_stars'));
      return;
    }
    _run(
      () => ReviewsService.save(
        workerId: widget.workerId,
        rating: _rating,
        comment: _comment.text,
        existingId: widget.existing?.id,
      ),
      _ReviewResult.saved,
    );
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SectionTitle(S.of(context, 'your_rating')),
            const SizedBox(height: 10),
            Center(
              child: _StarPicker(
                value: _rating,
                enabled: !_busy,
                onChanged: (v) => setState(() {
                  _rating = v;
                  _error = null;
                }),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                _rating == 0
                    ? S.of(context, 'rating_hint_half')
                    : _rating.toStringAsFixed(1),
                style: TextStyle(
                  color: _rating == 0
                      ? AppColors.textSecondary
                      : AppColors.roofDeep,
                  fontWeight: _rating == 0 ? FontWeight.w400 : FontWeight.w800,
                  fontSize: _rating == 0 ? 12.5 : 18,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _comment,
              enabled: !_busy,
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: S.of(context, 'write_review_hint'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.danger, fontSize: 12.5)),
            ],
            const SizedBox(height: 14),
            PrimaryButton(
              label: S.of(context, 'submit_review'),
              loading: _busy,
              onPressed: _submit,
            ),
            if (existing != null)
              Center(
                child: TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() => ReviewsService.delete(existing.id),
                          _ReviewResult.deleted),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger),
                  child: Text(S.of(context, 'delete_review')),
                ),
              ),
          ],
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
