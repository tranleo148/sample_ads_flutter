import 'dart:io';

import '../utils/constant.dart';

class AdHelper {
  static String adsAppOpen = 'app_open';
  static String adsBanner = 'banner';
  static String adsBannerCollapsible = 'banner_collapsible';
  static String adsInterstitial = 'interstitial';
  static String adsInterstitialVideo = 'interstitial_video';
  static String adsRewarded = 'rewarded';
  static String adsRewardedInterstitial = 'rewarded_interstitial';
  static String adsNativeAdvanced = 'native_advanced';
  static String adsNativeAdvancedVideo = 'native_advanced_video';

  static String adsInterSplash = 'inter_splash';
  static String adsNativeLanguage = 'native_language';
  static String adsAppOpenHigh = 'ads_app_open_high';
  static String adsResume = 'ads_resume';
  static String adsInterClickRun = 'inter_click_run';
  static String adsNativeHome = 'native_home';
  static String adsBannerHome = 'banner_home';

  static var androidTestAdUnitIds = {
    adsAppOpen: 'ca-app-pub-3940256099942544/3419835294',
    adsBanner: 'ca-app-pub-3940256099942544/6300978111',
    adsBannerCollapsible: 'ca-app-pub-3940256099942544/2014213617',
    adsInterstitial: 'ca-app-pub-3940256099942544/1033173712',
    adsInterstitialVideo: 'ca-app-pub-3940256099942544/8691691433',
    adsRewarded: 'ca-app-pub-3940256099942544/5224354917',
    adsRewardedInterstitial: 'ca-app-pub-3940256099942544/5354046379',
    adsNativeAdvanced: 'ca-app-pub-3940256099942544/2247696110',
    adsNativeAdvancedVideo: 'ca-app-pub-3940256099942544/1044960115',
  };

  static var iOSAdTestUnitIds = {
    adsAppOpen: 'ca-app-pub-3940256099942544/5662855259',
    adsBanner: 'ca-app-pub-3940256099942544/2934735716',
    adsBannerCollapsible: 'ca-app-pub-3940256099942544/8388050270',
    adsInterstitial: 'ca-app-pub-3940256099942544/4411468910',
    adsInterstitialVideo: 'ca-app-pub-3940256099942544/5135589807',
    adsRewarded: 'ca-app-pub-3940256099942544/1712485313',
    adsRewardedInterstitial: 'ca-app-pub-3940256099942544/6978759866',
    adsNativeAdvanced: 'ca-app-pub-3940256099942544/3986624511',
    adsNativeAdvancedVideo: 'ca-app-pub-3940256099942544/2521693316',
  };

  static var androidAdUnitIds = {
    adsInterSplash: Debug.DEBUG
        ? androidTestAdUnitIds[adsInterstitial]
        : 'ca-app-pub-4584260126367940/2748183426',
    adsNativeLanguage: Debug.DEBUG
        ? androidTestAdUnitIds[adsNativeAdvanced]
        : 'ca-app-pub-4584260126367940/1738354089',
    adsAppOpenHigh:
        Debug.DEBUG ? androidTestAdUnitIds[adsAppOpen] : 'ca-app-pub-4584260126367940/5690821786',
    adsResume:
        Debug.DEBUG ? androidTestAdUnitIds[adsAppOpen] : 'ca-app-pub-4584260126367940/5690821786',
    adsInterClickRun: Debug.DEBUG
        ? androidTestAdUnitIds[adsInterstitial]
        : 'ca-app-pub-4584260126367940/9425272415',
    adsNativeHome: Debug.DEBUG
        ? androidTestAdUnitIds[adsNativeAdvanced]
        : 'ca-app-pub-4584260126367940/3579663768',
    adsBannerHome:
        Debug.DEBUG ? androidTestAdUnitIds[adsBanner] : 'ca-app-pub-4584260126367940/4072428219',
  };

  static var androidAdUnitIdsCollapsible = {
    adsBannerHome: Debug.DEBUG
        ? androidTestAdUnitIds[adsBannerCollapsible]
        : 'ca-app-pub-4584260126367940/4072428219',
  };

  static var iOSAdUnitIds = {
    adsInterSplash:
        Debug.DEBUG ? iOSAdTestUnitIds[adsInterstitial] : 'ca-app-pub-4584260126367940/2748183426',
    adsNativeLanguage: Debug.DEBUG
        ? iOSAdTestUnitIds[adsNativeAdvanced]
        : 'ca-app-pub-4584260126367940/1738354089',
    adsAppOpenHigh:
        Debug.DEBUG ? iOSAdTestUnitIds[adsAppOpen] : 'ca-app-pub-4584260126367940/5690821786',
    adsResume:
        Debug.DEBUG ? iOSAdTestUnitIds[adsAppOpen] : 'ca-app-pub-4584260126367940/5690821786',
    adsInterClickRun:
        Debug.DEBUG ? iOSAdTestUnitIds[adsInterstitial] : 'ca-app-pub-4584260126367940/9425272415',
    adsNativeHome: Debug.DEBUG
        ? iOSAdTestUnitIds[adsNativeAdvanced]
        : 'ca-app-pub-4584260126367940/3579663768',
    adsBannerHome:
        Debug.DEBUG ? iOSAdTestUnitIds[adsBanner] : 'ca-app-pub-4584260126367940/4072428219',
  };

  static String getAdUnitIdByType(String type, {bool isCollapsibleBanner = false}) {
    if (Platform.isAndroid) {
      if (isCollapsibleBanner) return androidAdUnitIdsCollapsible[type]!;
      return androidAdUnitIds[type]!;
    } else if (Platform.isIOS) {
      return iOSAdUnitIds[type]!;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

class BannerCollapsiblePos {
  static const String top = 'top';
  static const String bottom = 'bottom';
  static const String left = 'left';
  static const String right = 'right';
}
