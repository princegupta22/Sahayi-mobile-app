import '../config/supabase_config.dart';

/// One customer's rating (1-5 stars) and optional message for a worker.
class Review {
  final String id;
  final String workerId;
  final String reviewerId;
  /// 0.5 – 5.0 in steps of 0.5.
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String reviewerName;
  final String? reviewerAvatarUrl;

  const Review({
    required this.id,
    required this.workerId,
    required this.reviewerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.reviewerName,
    this.reviewerAvatarUrl,
  });

  factory Review.fromMap(Map<String, dynamic> m) {
    final profile = m['profiles'] as Map<String, dynamic>?;
    return Review(
      id: m['id'] as String,
      workerId: m['worker_id'] as String,
      reviewerId: m['reviewer_id'] as String,
      rating: (m['rating'] as num).toDouble(),
      comment: (m['comment'] as String?) ?? '',
      createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      reviewerName: ((profile?['name'] as String?) ?? '').trim(),
      reviewerAvatarUrl: profile?['avatar_url'] as String?,
    );
  }
}

/// Reads and writes `worker_reviews` (see supabase/reviews.sql). The worker's
/// average rating is recalculated by the database, never by the app.
class ReviewsService {
  ReviewsService._();

  static const _columns = 'id, worker_id, reviewer_id, rating, comment, '
      'created_at, profiles(name, avatar_url)';

  /// Newest first.
  static Future<List<Review>> forWorker(String workerId) async {
    final rows = await supabase
        .from('worker_reviews')
        .select(_columns)
        .eq('worker_id', workerId)
        .order('created_at', ascending: false)
        .limit(100);
    return rows.map<Review>(Review.fromMap).toList();
  }

  /// The signed-in user's own review of [workerId], if any.
  static Future<Review?> mine(String workerId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await supabase
        .from('worker_reviews')
        .select(_columns)
        .eq('worker_id', workerId)
        .eq('reviewer_id', uid)
        .maybeSingle();
    return row == null ? null : Review.fromMap(row);
  }

  /// Adds a review, or edits the user's existing one for this worker.
  static Future<void> save({
    required String workerId,
    required double rating,
    required String comment,
    String? existingId,
  }) async {
    final data = {'rating': rating, 'comment': comment.trim()};
    final id = existingId ?? (await mine(workerId))?.id;
    if (id == null) {
      await supabase
          .from('worker_reviews')
          .insert({...data, 'worker_id': workerId});
    } else {
      await supabase.from('worker_reviews').update(data).eq('id', id);
    }
  }

  static Future<void> delete(String id) =>
      supabase.from('worker_reviews').delete().eq('id', id);
}
