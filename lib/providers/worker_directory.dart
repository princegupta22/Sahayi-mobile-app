import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
import '../config/supabase_config.dart';
import '../models/worker.dart';

/// A work photo in the listing form: already uploaded (url) or newly picked.
class ListingPhoto {
  final String? url;
  final XFile? file;
  const ListingPhoto.remote(String this.url) : file = null;
  const ListingPhoto.local(XFile this.file) : url = null;
}

class WorkerDirectory extends ChangeNotifier {
  List<Worker> _workers = [];
  Worker? _myListing;
  bool _loading = false;
  Object? _error;

  List<Worker> get workers => List.unmodifiable(_workers);
  Worker? get myListing => _myListing;
  bool get loading => _loading;
  Object? get error => _error;

  /// Number of listed workers per subcategory (keyed by English name).
  Map<String, int> get countsByCategory {
    final m = <String, int>{};
    for (final w in _workers) {
      m[w.categoryEn] = (m[w.categoryEn] ?? 0) + 1;
    }
    return m;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final rows = await supabase
          .from('workers')
          .select()
          .order('created_at', ascending: false);
      _workers = rows.map<Worker>(Worker.fromMap).toList();
      final uid = supabase.auth.currentUser?.id;
      _myListing = _workers.where((w) => w.userId == uid).firstOrNull;
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _workers = [];
    _myListing = null;
    _error = null;
    notifyListeners();
  }

  /// Creates or updates the signed-in user's single listing.
  Future<void> saveListing({
    required String name,
    required String categoryEn,
    required String categoryMl,
    required String city,
    required String country,
    required int experienceYears,
    required String about,
    required String phone,
    XFile? newProfilePhoto,
    required List<ListingPhoto> workPhotos,
  }) async {
    final uid = supabase.auth.currentUser!.id;

    var photoUrl = _myListing?.photoUrl;
    if (newProfilePhoto != null) {
      photoUrl = await _upload('avatars', uid, newProfilePhoto);
    }

    final workUrls = <String>[];
    for (final p in workPhotos) {
      workUrls.add(p.url ?? await _upload('work-photos', uid, p.file!));
    }

    final data = {
      'name': name,
      'category_en': categoryEn,
      'category_ml': categoryMl,
      'city': city,
      'country': country,
      'experience_years': experienceYears,
      'about': about,
      'phone': phone,
      'photo_url': photoUrl,
      'work_photo_urls': workUrls,
    };

    if (_myListing == null) {
      await supabase.from('workers').insert({...data, 'user_id': uid});
    } else {
      await supabase.from('workers').update(data).eq('user_id', uid);
    }

    // Keep the profile (used by chat) in sync with the listing.
    await supabase
        .from('profiles')
        .update({'name': name, 'avatar_url': photoUrl})
        .eq('id', uid);

    await load();
  }

  Future<String> _upload(String bucket, String uid, XFile file) async {
    final Uint8List bytes = await file.readAsBytes();
    var ext = file.path.split('.').last.toLowerCase();
    if (!const ['jpg', 'jpeg', 'png', 'webp'].contains(ext)) ext = 'jpg';
    final contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    final path = '$uid/${DateTime.now().microsecondsSinceEpoch}.$ext';
    await supabase.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );
    return supabase.storage.from(bucket).getPublicUrl(path);
  }
}
