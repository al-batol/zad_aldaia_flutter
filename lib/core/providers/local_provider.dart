import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProvider extends ChangeNotifier {
  String _locale = "en";
  List<String> _languageHistory = [];

  String get locale => _locale;
  List<String> get languageHistory => _languageHistory;

  Future<void> changeLanguage(String langCode) async {
    if (_locale == langCode) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("app_lang", langCode);

    _languageHistory = prefs.getStringList("language_history") ?? [];
    if (!_languageHistory.contains(langCode)) {
      _languageHistory.add(langCode);
      await prefs.setStringList("language_history", _languageHistory);
    }
    _locale = langCode;
    notifyListeners();
  }

  Future<void> loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString("app_lang");
    if (savedLocale != null) {
      _locale = savedLocale;
    }
    _languageHistory = prefs.getStringList("language_history") ?? [];
  }
}
