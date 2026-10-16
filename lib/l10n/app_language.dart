import 'package:flutter/material.dart';

enum AppLanguage { english, malayalam }

/// App-wide language state for screens (dashboard onward) that switch
/// entirely between English and Malayalam via the top toggle.
class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;
  bool get isMalayalam => _language == AppLanguage.malayalam;

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
  }

  void toggle() {
    setLanguage(
      _language == AppLanguage.english
          ? AppLanguage.malayalam
          : AppLanguage.english,
    );
  }
}
