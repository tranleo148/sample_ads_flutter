import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: constant_identifier_names
class Preference {
  static const String USER_ID = 'USER_ID';
  static const String IS_USER_FIRSTTIME = 'IS_USER_FIRSTTIME';
  static const String TARGET_DRINK_WATER = 'TARGET_DRINK_WATER';
  static const String SELECTED_DRINK_WATER_ML = 'SELECTED_DRINK_WATER_ML';
  static const String IS_REMINDER_ON = 'IS_REMINDER_ON';
  static const String IS_DISTANCE_INDICATOR_ON = 'IS_DISTANCE_INDICATOR_ON';
  static const String TARGETVALUE_FOR_DISTANCE_IN_KM = 'TARGETVALUE_FOR_DISTANCE_IN_KM';
  static const String TARGETVALUE_FOR_RUNTIME = 'TARGETVALUE_FOR_RUNTIME';
  static const String TARGETVALUE_FOR_WALKTIME = 'TARGETVALUE_FOR_WALKTIME';
  static const String SLIDER_VALUE = 'SLIDER_VALUE';
  static const String IS_KM_SELECTED = 'IS_KM_SELECTED';
  static const String IS_KG_SELECTED = 'IS_KG_SELECTED';
  static const String IS_CM_SELECTED = 'IS_CM_SELECTED';
  static const String START_TIME_REMINDER = 'START_TIME_REMINDER';
  static const String DAILY_REMINDER_TIME = 'DAILY_REMINDER_TIME';
  static const String DRINK_WATER_INTERVAL = 'DRINK_WATER_INTERVAL';
  static const String DAILY_REMINDER_REPEAT_DAY = 'DAILY_REMINDER_REPEAT_DAY';
  static const String IS_DAILY_REMINDER_ON = 'IS_DAILY_REMINDER_ON';
  static const String END_TIME_REMINDER = 'END_TIME_REMINDER';
  static const String DRINK_WATER_NOTIFICATION_MESSAGE = 'DRINK_WATER_NOTIFICATION_MESSAGE';

  static const String METRIC_IMPERIAL_UNITS = 'METRIC_IMPERIAL_UNITS';
  static const String LANGUAGE = 'LANGUAGE';
  static const String FIRST_DAY_OF_WEEK = 'FIRST_DAY_OF_WEEK';
  static const String FIRST_DAY_OF_WEEK_IN_NUM = 'FIRST_DAY_OF_WEEK_IN_NUM';

  static const String GENDER = 'GENDER';
  static const String DISTANCE = 'DISTANCE';
  static const String HEIGHT = 'HEIGHT';
  static const String WEIGHT = 'WEIGHT';
  static const String TOTAL_STEPS = 'TOTAL_STEPS';
  static const String CURRENT_STEPS = 'CURRENT_STEPS';
  static const String TARGET_STEPS = 'TARGET_STEPS';
  static const String OLD_TIME = 'OLD_TIME';
  static const String OLD_DISTANCE = 'OLD_DISTANCE';
  static const String OLD_CALORIES = 'OLD_CALORIES';
  static const String DATE = 'DATE';
  static const String IS_PAUSE = 'IS_PAUSE';
  static const String DURATION = 'DURATION';
  static const String TRACK_STATUS = 'TRACK_STATUS';
  static const String RATING_SHOW_TIME = 'RATING_SHOW_TIME';
  static const String REVIEW_DISPLAYED = 'REVIEW_DISPLAYED';
  static const String RATED_STARS = 'RATED_STARS';
  static const String RATED_ON_STORE = 'RATED_ON_STORE';
  static const String ADS_DISPLAY_COUNT = 'ADS_DISPLAY_COUNT';

  static final Preference _preference = Preference._internal();

  factory Preference() {
    return _preference;
  }

  Preference._internal();

  static Preference get shared => _preference;

  static SharedPreferences? _pref;

  Future<SharedPreferences?> instance() async {
    if (_pref != null) return _pref;
    await SharedPreferences.getInstance().then((onValue) {
      _pref = onValue;
    }).catchError((onError) {
      _pref = null;
    });

    return _pref;
  }

  String? getString(String key) {
    return _pref!.getString(key);
  }

  Future<bool> setString(String key, String value) {
    return _pref!.setString(key, value);
  }

  int getInt(String key, [int defaultValue = 0]) {
    return _pref!.getInt(key) ?? defaultValue;
  }

  Future<bool> setInt(String key, int value) {
    return _pref!.setInt(key, value);
  }

  bool getBool(String key, [bool defaultValue = false]) {
    return _pref!.getBool(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) {
    return _pref!.setBool(key, value);
  }

  double getDouble(String key, [double defaultValue = 0.0]) {
    return _pref!.getDouble(key) ?? defaultValue;
  }

  Future<bool> setDouble(String key, double value) {
    return _pref!.setDouble(key, value);
  }

  Future<bool> remove(key, [multi = false]) async {
    SharedPreferences? pref = await instance();
    if (multi) {
      key.forEach((f) async {
        return await pref!.remove(f);
      });
    } else {
      return await pref!.remove(key);
    }

    return Future.value(true);
  }

  static Future<bool> clearTargetDrinkWater() async {
    _pref!.getKeys().forEach((key) async {
      if (key == TARGET_DRINK_WATER) {
        await _pref!.remove(key);
      }
    });
    return Future.value(true);
  }

  static Future<bool> clearSelectedDrinkWaterML() async {
    _pref!.getKeys().forEach((key) async {
      if (key == SELECTED_DRINK_WATER_ML) {
        await _pref!.remove(key);
      }
    });
    return Future.value(true);
  }

  static Future<bool> clearMetricAndImperialUnits() async {
    _pref!.getKeys().forEach((key) async {
      if (key == METRIC_IMPERIAL_UNITS) {
        await _pref!.remove(key);
      }
    });
    return Future.value(true);
  }

  static Future<int> increaseAdsDisplayCount() async {
    int curCount = shared.getInt(Preference.ADS_DISPLAY_COUNT, 0);
    await shared.setInt(Preference.ADS_DISPLAY_COUNT, curCount++);
    if (curCount == 5) {
      FirebaseAnalytics.instance.logEvent(name: 'view_5_ads');
    } else if (curCount == 7) {
      FirebaseAnalytics.instance.logEvent(name: 'view_ads_7');
    }
    return Future.value(curCount);
  }
}
