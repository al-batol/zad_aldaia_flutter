import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProvider extends ChangeNotifier {
  late String _locale;
  List<String> _languageHistory = [];

  String get locale => _locale;
  List<String> get languageHistory => _languageHistory;

  LocalProvider();

  Future<void> changeLanguage(String langCode) async {
    _locale = langCode;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    _languageHistory = prefs.getStringList("language_history") ?? [];
    if (!_languageHistory.contains(langCode)) {
      _languageHistory.add(langCode);
      await prefs.setStringList("language_history", _languageHistory);
    }

    await prefs.setString("app_lang", langCode);

    notifyListeners();
  }

  Future<void> loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString("app_lang") ?? "en";
    _languageHistory = prefs.getStringList("language_history") ?? [];
    notifyListeners();
  }
}
