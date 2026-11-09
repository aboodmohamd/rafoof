import 'package:flutter/material.dart';
import 'package:rafoof/core/constants/app_constants.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _languageCode = 'en';

  String get languageCode => _languageCode;
  bool get isArabic => _languageCode == 'ar';

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString(AppConstants.languageKey) ?? 'en';
    AppStrings.languageCode = _languageCode;
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == _languageCode) return;
    _languageCode = languageCode;
    AppStrings.languageCode = languageCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, languageCode);
  }
}
