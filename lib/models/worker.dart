class Worker {
  final String id;
  final String userId;
  final String name;
  final String categoryEn;
  final String categoryMl;
  final String city;
  final String country;
  final int experienceYears;
  final String about;
  final double rating;
  final String phone;
  final String? photoUrl;
  final List<String> workPhotoUrls;

  const Worker({
    required this.id,
    required this.userId,
    required this.name,
    required this.categoryEn,
    required this.categoryMl,
    required this.city,
    required this.country,
    required this.experienceYears,
    this.about = '',
    this.rating = 0,
    this.phone = '',
    this.photoUrl,
    this.workPhotoUrls = const [],
  });

  int get avatarColorSeed => id.hashCode.abs();

  factory Worker.fromMap(Map<String, dynamic> m) => Worker(
    id: m['id'] as String,
    userId: m['user_id'] as String,
    name: m['name'] as String,
    categoryEn: m['category_en'] as String,
    categoryMl: m['category_ml'] as String,
    city: m['city'] as String,
    country: (m['country'] as String?) ?? 'India',
    experienceYears: (m['experience_years'] as num?)?.toInt() ?? 0,
    about: (m['about'] as String?) ?? '',
    rating: (m['rating'] as num?)?.toDouble() ?? 0,
    phone: (m['phone'] as String?) ?? '',
    photoUrl: m['photo_url'] as String?,
    workPhotoUrls: ((m['work_photo_urls'] as List?) ?? const [])
        .cast<String>(),
  );
}
