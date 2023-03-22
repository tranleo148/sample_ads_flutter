import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/preference.dart';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(Preference.LANGUAGE, languageCode);
  return _locale(languageCode);
}

Locale getLocale() {
  String languageCode = Preference.shared.getString(Preference.LANGUAGE) ?? 'en';
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  return languageCode.isNotEmpty ? Locale(languageCode, '') : const Locale('en', '');
}

void changeLanguage(BuildContext context, String selectedLanguageCode) async {
  var locale = await setLocale(selectedLanguageCode);
  Get.updateLocale(locale);
}
