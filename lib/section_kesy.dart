import 'package:flutter/cupertino.dart';

import 'generated/l10n.dart';

class SectionKeys {
  static const String introToIslam = 'intro_to_islam';
  static const String christiansDialog = 'christians_dialog';
  static const String atheistDialog = 'atheist_dialog';
  static const String otherSects = 'other_sects';
  static const String whyIslamIsTrue = 'why_islam_is_true';
  static const String teachingNewMuslims = 'teaching_new_muslims';
  static const String questionsAboutIslam = 'questions_about_islam';
  static const String daiaGuide = 'daia_guide';

  static String getKeyFromLocalizedName(String localizedName, BuildContext context) {
    Map<String, String> mapping = {
      S.of(context).introToIslam: introToIslam,
      S.of(context).christiansDialog: christiansDialog,
      S.of(context).atheistDialog: atheistDialog,
      S.of(context).otherSects: otherSects,
      S.of(context).whyIslamIsTrue: whyIslamIsTrue,
      S.of(context).teachingNewMuslims: teachingNewMuslims,
      S.of(context).questionsAboutIslam: questionsAboutIslam,
      S.of(context).daiaGuide: daiaGuide,
    };

    return mapping[localizedName] ?? localizedName;
  }
  static String getLocalizedNameFromKey(String key, BuildContext context) {
    switch (key) {
      case introToIslam:
        return S.of(context).introToIslam;
      case christiansDialog:
        return S.of(context).christiansDialog;
      case atheistDialog:
        return S.of(context).atheistDialog;
      case otherSects:
        return S.of(context).otherSects;
      case whyIslamIsTrue:
        return S.of(context).whyIslamIsTrue;
      case teachingNewMuslims:
        return S.of(context).teachingNewMuslims;
      case questionsAboutIslam:
        return S.of(context).questionsAboutIslam;
      case daiaGuide:
        return S.of(context).daiaGuide;
      default:
        return key;
    }
  }
}