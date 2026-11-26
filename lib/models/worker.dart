import '../l10n/app_language.dart';

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

  /// How many customers rated this worker (0 = not rated yet).
  final int ratingCount;

  /// Empty for other people's listings; see worker_phone() in payments.sql.
  final String phone;
  final String? photoUrl;
  final List<String> workPhotoUrls;

  /// Set by the worker; others see an Available / Booked tag.
  final bool isAvailable;

  /// Free-text service name, used when the category is "Other".
  final String customService;

  /// false = "Only me": the number is never handed out to anyone else.
  final bool phonePublic;

  /// false = nobody can start a chat or send this worker a new message.
  final bool allowMessages;

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
    this.ratingCount = 0,
    this.phone = '',
    this.photoUrl,
    this.workPhotoUrls = const [],
    this.isAvailable = true,
    this.customService = '',
    this.phonePublic = true,
    this.allowMessages = true,
  });

  int get avatarColorSeed => id.hashCode.abs();

  /// What to show as the service: the worker's own text for "Other",
  /// otherwise the category in the chosen language.
  String serviceLabel(AppLanguage lang) {
    if (customService.trim().isNotEmpty) return customService.trim();
    return lang == AppLanguage.malayalam ? categoryMl : categoryEn;
  }

  bool get hasRating => ratingCount > 0 && rating > 0;

  /// Can a customer reach this worker at all?
  bool get canBeContacted => phonePublic || allowMessages;

  Worker copyWith({
    bool? isAvailable,
    bool? phonePublic,
    bool? allowMessages,
  }) => Worker(
    id: id,
    userId: userId,
    name: name,
    categoryEn: categoryEn,
    categoryMl: categoryMl,
    city: city,
    country: country,
    experienceYears: experienceYears,
    about: about,
    rating: rating,
    ratingCount: ratingCount,
    phone: phone,
    photoUrl: photoUrl,
    workPhotoUrls: workPhotoUrls,
    isAvailable: isAvailable ?? this.isAvailable,
    customService: customService,
    phonePublic: phonePublic ?? this.phonePublic,
    allowMessages: allowMessages ?? this.allowMessages,
  );

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
    ratingCount: (m['rating_count'] as num?)?.toInt() ?? 0,
    phone: (m['phone'] as String?) ?? '',
    photoUrl: m['photo_url'] as String?,
    workPhotoUrls: ((m['work_photo_urls'] as List?) ?? const [])
        .cast<String>(),
    isAvailable: (m['is_available'] as bool?) ?? true,
    customService: (m['custom_service'] as String?) ?? '',
    phonePublic: (m['phone_public'] as bool?) ?? true,
    allowMessages: (m['allow_messages'] as bool?) ?? true,
  );
}
