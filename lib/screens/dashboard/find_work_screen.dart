import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_language.dart';
import '../../l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_directory.dart';
import '../../services/app_errors.dart';
import '../../services/payment_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../payment/payment_screen.dart';

class FindWorkScreen extends StatefulWidget {
  const FindWorkScreen({super.key});

  @override
  State<FindWorkScreen> createState() => _FindWorkScreenState();
}

class _FindWorkScreenState extends State<FindWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _experienceController = TextEditingController();
  final _aboutController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');
  final _phoneController = TextEditingController();

  XFile? _newProfilePhoto;
  String? _existingProfileUrl;
  final List<ListingPhoto> _workPhotos = [];
  WorkCategory? _category;
  bool _submitting = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    final mine = context.read<WorkerDirectory>().myListing;
    if (mine != null) {
      _isEdit = true;
      _nameController.text = mine.name;
      _experienceController.text = '${mine.experienceYears}';
      _aboutController.text = mine.about;
      _cityController.text = mine.city;
      _countryController.text = mine.country;
      _phoneController.text = mine.phone;
      _existingProfileUrl = mine.photoUrl;
      _workPhotos.addAll(mine.workPhotoUrls.map(ListingPhoto.remote));
      _category = WorkCategory.byEnglish(mine.categoryEn);
    } else {
      _nameController.text = context.read<AuthProvider>().name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _experienceController.dispose();
    _aboutController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toast(String key) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(S.read(context, key))));
  }

  /// Opens the gallery. The OS asks for photo access when needed;
  /// if the user has denied it we explain how to turn it back on.
  Future<XFile?> _pickFromGallery() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );
    } on PlatformException catch (e) {
      if (!mounted) return null;
      _toast(e.code.contains('denied') ? 'photo_denied' : 'err_generic');
      return null;
    }
  }

  Future<void> _pickCategory() async {
    final picked = await showModalBottomSheet<WorkCategory>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _CategorySearchSheet(),
    );
    if (picked != null) setState(() => _category = picked);
  }

  Future<void> _pickProfilePhoto() async {
    final file = await _pickFromGallery();
    if (file != null && mounted) setState(() => _newProfilePhoto = file);
  }

  Future<void> _pickWorkPhoto() async {
    if (_workPhotos.length >= 3) return;
    final file = await _pickFromGallery();
    if (file != null && mounted) {
      setState(() => _workPhotos.add(ListingPhoto.local(file)));
    }
  }

  Future<void> _submit() async {
    if (_category == null) return _toast('required_field');
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    // A new worker profile needs the one-time listing fee; edits are free.
    if (!_isEdit &&
        (!await PaymentScreen.ensurePaid(context, PaymentPurpose.listing) ||
            !mounted)) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await context.read<WorkerDirectory>().saveListing(
        name: _nameController.text.trim(),
        categoryEn: _category!.en,
        categoryMl: _category!.ml,
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        experienceYears: int.parse(_experienceController.text.trim()),
        about: _aboutController.text.trim(),
        phone: _phoneController.text.trim(),
        newProfilePhoto: _newProfilePhoto,
        workPhotos: _workPhotos,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.forest,
          content: Text(S.read(context, _isEdit ? 'listing_updated' : 'listing_success')),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _toast(errorKeyFor(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  ImageProvider? get _profileImage {
    final f = _newProfilePhoto;
    if (f != null) return kIsWeb ? NetworkImage(f.path) : FileImage(File(f.path));
    final url = _existingProfileUrl;
    return (url == null || url.isEmpty) ? null : NetworkImage(url);
  }

  Widget _workPhotoTile(ListingPhoto p) {
    final image = p.file != null
        ? (kIsWeb
            ? Image.network(p.file!.path, width: 78, height: 78, fit: BoxFit.cover)
            : Image.file(File(p.file!.path), width: 78, height: 78, fit: BoxFit.cover))
        : Image.network(p.url!, width: 78, height: 78, fit: BoxFit.cover);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: image),
          Positioned(
            right: -4,
            top: -4,
            child: GestureDetector(
              onTap: () => setState(() => _workPhotos.remove(p)),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context, _isEdit ? 'edit_listing' : 'create_listing'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context, 'add_your_details'),
                style: const TextStyle(fontFamily: AppTheme.headingFont, fontSize: AppTheme.headingSize, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 22),
              Center(
                child: GestureDetector(
                  onTap: _pickProfilePhoto,
                  child: Stack(
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.divider.withValues(alpha: 0.4),
                          image: _profileImage != null
                              ? DecorationImage(image: _profileImage!, fit: BoxFit.cover)
                              : null,
                          border: Border.all(color: AppColors.leaf, width: 1.6),
                        ),
                        child: _profileImage == null
                            ? const Icon(Icons.add_a_photo_outlined, color: AppColors.leaf, size: 30)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.leaf,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  S.of(context, 'tap_to_upload'),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 26),
              _Label(S.of(context, 'full_name')),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => (v == null || v.trim().isEmpty) ? S.read(context, 'required_field') : null,
              ),
              const SizedBox(height: 20),
              _Label(S.of(context, 'work_category')),
              const SizedBox(height: 10),
              _CategoryField(
                category: _category,
                lang: lang,
                onTap: _pickCategory,
              ),
              const SizedBox(height: 20),
              _Label(S.of(context, 'experience_years')),
              const SizedBox(height: 8),
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: const InputDecoration(prefixIcon: Icon(Icons.timeline_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? S.read(context, 'required_field') : null,
              ),
              const SizedBox(height: 20),
              _Label(S.of(context, 'about_you')),
              const SizedBox(height: 8),
              TextFormField(
                controller: _aboutController,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(hintText: S.of(context, 'about_hint')),
              ),
              const SizedBox(height: 20),
              _Label(S.of(context, 'phone_optional')),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.call_outlined),
                  hintText: S.of(context, 'phone_hint'),
                ),
                validator: (v) => (v == null || v.isEmpty || v.length == 10)
                    ? null
                    : S.read(context, 'err_phone'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(S.of(context, 'city')),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.location_city_outlined)),
                          validator: (v) => (v == null || v.trim().isEmpty) ? S.read(context, 'required_field') : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(S.of(context, 'country')),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _countryController,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.public_outlined)),
                          validator: (v) => (v == null || v.trim().isEmpty) ? S.read(context, 'required_field') : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _Label(S.of(context, 'work_photos')),
              const SizedBox(height: 10),
              Row(
                children: [
                  ..._workPhotos.map(_workPhotoTile),
                  if (_workPhotos.length < 3)
                    GestureDetector(
                      onTap: _pickWorkPhoto,
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider, width: 1.4),
                          color: AppColors.surface,
                        ),
                        child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.leaf),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 34),
              PrimaryButton(
                label: S.of(context, _isEdit ? 'update_listing' : 'submit_listing'),
                loading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5));
  }
}

/// Looks like a text field; shows the chosen service and opens the search
/// sheet when tapped.
class _CategoryField extends StatelessWidget {
  final WorkCategory? category;
  final AppLanguage lang;
  final VoidCallback onTap;
  const _CategoryField({
    required this.category,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = category;
    final group = c == null ? null : CategoryGroup.byId(c.groupId);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        isEmpty: c == null,
        decoration: InputDecoration(
          prefixIcon: Icon(
            c?.icon ?? Icons.search_rounded,
            color: group?.color ?? AppColors.textSecondary,
          ),
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          hintText: S.of(context, 'search_categories'),
        ),
        child: c == null
            ? null
            : Text(
                '${c.label(lang)}  ·  ${group?.label(lang) ?? ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

/// Bottom sheet with a search box over every service; matches the service
/// or its group name in either language. Pops the chosen [WorkCategory].
class _CategorySearchSheet extends StatefulWidget {
  const _CategorySearchSheet();

  @override
  State<_CategorySearchSheet> createState() => _CategorySearchSheetState();
}

class _CategorySearchSheetState extends State<_CategorySearchSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;
    final q = _search.text.trim().toLowerCase();
    bool hit(String en, String ml) =>
        en.toLowerCase().contains(q) || ml.contains(q);
    final results = WorkCategory.all.where((c) {
      if (q.isEmpty || hit(c.en, c.ml)) return true;
      final g = CategoryGroup.byId(c.groupId);
      return g != null && hit(g.en, g.ml);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: TextField(
                controller: _search,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: S.of(context, 'search_categories'),
                  suffixIcon: q.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => setState(_search.clear),
                        ),
                ),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? Center(child: Text(S.of(context, 'no_services_match')))
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemCount: results.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 64),
                      itemBuilder: (_, i) {
                        final c = results[i];
                        final g = CategoryGroup.byId(c.groupId);
                        final color = g?.color ?? AppColors.leaf;
                        return ListTile(
                          onTap: () => Navigator.of(context).pop(c),
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.12),
                            child: Icon(c.icon, color: color, size: 20),
                          ),
                          title: Text(
                            c.label(lang),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            g?.label(lang) ?? '',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
