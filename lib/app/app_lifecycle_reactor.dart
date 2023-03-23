import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads/ad_helper.dart';
import '../ads/ads_repository.dart';
import '../utils/constant.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  bool _onSplashScreen = false;
  bool _isExcludeScreen = false;
  bool _isPrivacyPolicyScreen = false;
  int _permissionResult = -1;

  AppLifecycleReactor();

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) => _onAppStateChanged(state));
  }

  void setOnSplashScreen(bool value) {
    _onSplashScreen = value;
  }

  void setIsExcludeScreen(bool value) {
    _isExcludeScreen = value;
  }

  void setIsPrivacyPolicyScreen(bool value) {
    _isPrivacyPolicyScreen = value;
  }

  void setPermissionResult(int value) {
    _permissionResult = value;
  }

  int getPermissionResult() {
    return _permissionResult;
  }

  void _onAppStateChanged(AppState appState) {
    // Try to show an app open ad if the app is being resumed and
    // we're not already showing an app open ad.
    Debug.printLog('onSplashScreen:$_onSplashScreen');

    // Do not show AppOpenAd if it disabled from remoteConfig or when user on SplashScreen
    bool enableAppOpenAd = FirebaseRemoteConfig.instance.getBool(AdHelper.adsResume);
    if (!enableAppOpenAd || _onSplashScreen) return;
    // Show AppOpenAd when back to foreground but do not show on excluded screens and privacy policy screen
    if (appState == AppState.foreground) {
      if (!_isExcludeScreen && !_isPrivacyPolicyScreen) {
        AdsRepository.instance.showAppOpenAd(AdHelper.adsResume);
      } else {
        _isExcludeScreen = false;
      }
    } else if (appState == AppState.background) {
      AdsRepository.instance.loadAppOpenAd(AdHelper.adsResume);
    }
  }
}
