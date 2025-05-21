import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/core/networking/api_service.dart';
import 'package:zad_aldaia/core/networking/translation_request.dart';

class Translator {
  static Future<String?> text(String text, String language) async {
    text = text.replaceAll('\n', '*');
    try {
      var response = await getIt<ApiService>().translateText(TranslationRequest(text, language));
      text = response.data.translations.first.translatedText;
      text = text.replaceAll('*', '\n');
      return text;
    } catch (e) {
      return null;
    }
  }
}
