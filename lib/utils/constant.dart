import 'dart:developer';

// ignore_for_file: constant_identifier_names
class Constant {
  static const STR_BACK = 'Back';
  static const STR_DELETE = 'DELETE';
  static const STR_SETTING = 'Setting';
  static const STR_SETTING_CIRCLE = 'Setting_circle';
  static const STR_CLOSE = 'CLOSE';
  static const STR_INFO = 'INFO';
  static const STR_OPTIONS = 'OPTIONS';

  static const String ADJUST_ID = '';

  // FYI: appStoreId is only required on IOS and MacOS and can be found in App Store Connect under
  // General > App Information > Apple ID.
  static const String APPLE_APPSTORE_ID = '';

  static const String trackingStatus = 'TrackingStatus.authorized';
}

class Debug {
  static const DEBUG = true;
  static const USE_COLLAPSIBLE_BANNER = false;

  static printLog(String str) {
    if (DEBUG) log(str);
  }
}
