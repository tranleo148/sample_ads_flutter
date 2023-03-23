import 'dart:async';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/constant.dart';
import '../utils/preference.dart';
import '../utils/utils.dart';
import 'ad_helper.dart';
import 'ad_loading_controller.dart';
import 'ad_loading_dialog.dart';

class AdsRepository {
  AdsRepository._();

  static AdsRepository? _instance;
  static AdsRepository get instance => _instance ??= AdsRepository._();

  /// Ready to show Ad when application not in background
  bool _readyToShowAds = true;

  /// True value when there is exist an Ad and false otherwise.
  bool _isFullscreenAdShowing = false;

  /// Maximum duration allowed between loading and showing the ad.
  final Duration _maxCacheDuration = const Duration(hours: 4);

  void onResume() {
    _readyToShowAds = true;
  }

  void onPause() {
    _readyToShowAds = false;
  }

  final Map<String, InterstitialAd?> _interstitialAds = {};
  InterstitialAd? getInterstitialAdById(String adUnitId) {
    return _interstitialAds[adUnitId];
  }

  final Map<String, NativeAd?> _nativeAds = {};
  NativeAd? getNativeAdById(String adUnitId) {
    return _nativeAds[adUnitId];
  }

  final Map<String, BannerAd?> _bannerAds = {};
  BannerAd? getBannerAdById(String adUnitId) {
    return _bannerAds[adUnitId];
  }

  final Map<String, AppOpenAd?> _appOpenAds = {};
  AppOpenAd? getAppOpenAdById(String adUnitId) {
    return _appOpenAds[adUnitId];
  }

  AdWithoutView? getSplashAdIfAvailable(String adUnitIdAppOpen, String adUnitIdInterstitial) {
    return _appOpenAds[adUnitIdAppOpen] ?? _interstitialAds[adUnitIdInterstitial];
  }

  /// Context for AdLoadingDialog
  BuildContext? _dialogContext;

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  void loadAppOpenAd(String adUnitId) {
    AppOpenAd.load(
      adUnitId: AdHelper.getAdUnitIdByType(adUnitId),
      orientation: AppOpenAd.orientationPortrait,
      request: AdRequest(nonPersonalizedAds: Utils.nonPersonalizedAds()),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          Debug.printLog('AppOpenAd [$adUnitId] loaded');
          _appOpenLoadTime = DateTime.now();
          _appOpenAds[adUnitId] = ad;
          _appOpenAds[adUnitId]?.onPaidEvent =
              (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
            _sendPaidEventToFirebase(valueMicros, currencyCode, precision.name, adUnitId,
                ad.responseInfo?.mediationAdapterClassName);
          };
          _appOpenAds[adUnitId]?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _isFullscreenAdShowing = true;
              Debug.printLog('$ad onAdShowedFullScreenContent');
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isFullscreenAdShowing = false;
              //if (_dialogContext != null) Navigator.pop(_dialogContext!);
              Get.back();
              ad.dispose();
              disposeAppOpenAd(adUnitId);
            },
            onAdDismissedFullScreenContent: (ad) {
              _isFullscreenAdShowing = false;
              //if (_dialogContext != null) Navigator.pop(_dialogContext!);
              Get.back();
              ad.dispose();
              disposeAppOpenAd(adUnitId);
              loadAppOpenAd(adUnitId);
            },
            onAdImpression: (Ad ad) {
              Preference.increaseAdsDisplayCount();
            },
          );
        },
        onAdFailedToLoad: (error) {
          Debug.printLog('AppOpenAd [$adUnitId] failed to load: $error');
        },
      ),
    );
  }

  void loadSplashAdWithAppOpenAndInter(String adUnitIdAppOpen, String adUnitIdInterstitial,
      {Function? onNextAction, Widget? nextScreen}) {
    AppOpenAd.load(
      adUnitId: AdHelper.getAdUnitIdByType(adUnitIdAppOpen),
      orientation: AppOpenAd.orientationPortrait,
      request: AdRequest(nonPersonalizedAds: Utils.nonPersonalizedAds()),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          Debug.printLog('Splash AppOpenAd [$adUnitIdAppOpen] loaded');
          _appOpenAds[adUnitIdAppOpen] = ad;
          _appOpenAds[adUnitIdAppOpen]?.onPaidEvent =
              (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
            _sendPaidEventToFirebase(valueMicros, currencyCode, precision.name, adUnitIdAppOpen,
                ad.responseInfo?.mediationAdapterClassName);
          };
          _appOpenAds[adUnitIdAppOpen]?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _isFullscreenAdShowing = true;
              Debug.printLog('$ad onAdShowedFullScreenContent');
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isFullscreenAdShowing = false;
              if (onNextAction != null) {
                Get.back();
                onNextAction();
              } else if (nextScreen != null) {
                Get.off(() => nextScreen);
              }
              ad.dispose();
              disposeAppOpenAd(adUnitIdAppOpen);
            },
            onAdDismissedFullScreenContent: (ad) {
              _isFullscreenAdShowing = false;
              if (onNextAction != null) {
                Get.back();
                onNextAction();
              } else if (nextScreen != null) {
                Get.off(() => nextScreen);
              }
              ad.dispose();
              disposeAppOpenAd(adUnitIdAppOpen);
              loadAppOpenAd(adUnitIdAppOpen);
            },
            onAdImpression: (Ad ad) {
              Preference.increaseAdsDisplayCount();
            },
          );
        },
        onAdFailedToLoad: (error) {
          Debug.printLog('Splash AppOpenAd [$adUnitIdAppOpen] failed to load: $error');
          Debug.printLog('Try to load Splash InterstitialAd [$adUnitIdInterstitial]');
          loadInterstitialAd(
            AdHelper.adsInterSplash,
            onNextAction: () {
              if (onNextAction != null) {
                onNextAction();
              }
            },
          );
        },
      ),
    );
  }

  void loadInterstitialAd(String adUnitId,
      {Function? onAdLoaded,
      Function? onAdFailedToLoad,
      Function? onAdShowed,
      Function? onNextAction,
      Widget? nextScreen}) {
    InterstitialAd.load(
      adUnitId: AdHelper.getAdUnitIdByType(adUnitId),
      request: AdRequest(nonPersonalizedAds: Utils.nonPersonalizedAds()),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAds[adUnitId] = ad;
          _interstitialAds[adUnitId]?.onPaidEvent =
              (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
            _sendPaidEventToFirebase(valueMicros, currencyCode, precision.name, adUnitId,
                ad.responseInfo?.mediationAdapterClassName);
          };
          _interstitialAds[adUnitId]?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              _isFullscreenAdShowing = true;
              if (onAdShowed != null) onAdShowed();
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              _isFullscreenAdShowing = false;
              if (onNextAction != null) {
                Get.back();
                onNextAction();
              } else if (nextScreen != null) {
                Get.off(() => nextScreen);
              }
              ad.dispose();
              disposeInterstitialAdById(adUnitId);
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError adError) {
              _isFullscreenAdShowing = false;
              if (onNextAction != null) {
                Get.back();
                onNextAction();
              } else if (nextScreen != null) {
                Get.off(() => nextScreen);
              }
              ad.dispose();
              disposeInterstitialAdById(adUnitId);
            },
            onAdImpression: (Ad ad) {
              Preference.increaseAdsDisplayCount();
            },
          );
          if (onAdLoaded != null) onAdLoaded();
          Debug.printLog('InterstitialAd [$adUnitId] loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isFullscreenAdShowing = false;
          _interstitialAds[adUnitId] = null;
          if (onAdFailedToLoad != null) onAdFailedToLoad();
          Debug.printLog('InterstitialAd [$adUnitId] failed to load: $error');
        },
      ),
    );
  }

  NativeAd? loadNativeAd(String adUnitId, Function onAdLoadedSuccess, Function onAdFailedToLoad,
      [int adType = 0]) {
    String adFactoryId = 'adFactoryNativeAd';
    switch (adType) {
      case 0:
        adFactoryId = 'adFactoryNativeAd';
        break;
      case 1:
        adFactoryId = 'adFactoryNativeAdMedium';
        break;
      case 2:
        adFactoryId = 'adFactoryNativeAdSmall';
        break;
    }
    _nativeAds[adUnitId] = NativeAd(
      adUnitId: AdHelper.getAdUnitIdByType(adUnitId),
      factoryId: adFactoryId,
      request: AdRequest(nonPersonalizedAds: Utils.nonPersonalizedAds()),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          onAdLoadedSuccess();
          Debug.printLog('NativeAd [$adUnitId] loaded.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          onAdFailedToLoad();
          // Dispose the ad here to free resources.
          ad.dispose();
          Debug.printLog('NativeAd [$adUnitId] failed to load: $error');
        },
        onPaidEvent: (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
          _sendPaidEventToFirebase(valueMicros, currencyCode, precision.name, adUnitId,
              ad.responseInfo?.mediationAdapterClassName);
        },
        onAdImpression: (Ad ad) {
          Preference.increaseAdsDisplayCount();
        },
      ),
    );
    _nativeAds[adUnitId]?.load();
    return _nativeAds[adUnitId];
  }

  BannerAd? loadBannerAd(String adUnitId, Function onBannerAdLoaded,
      Function onBannerAdFailedToLoad, bool isCollapsible,
      {String pos = BannerCollapsiblePos.bottom}) {
    Map<String, String>? extras;
    if (isCollapsible) {
      extras = {};
      extras['collapsible'] = pos;
    }
    _bannerAds[adUnitId] = BannerAd(
      adUnitId: AdHelper.getAdUnitIdByType(adUnitId, isCollapsibleBanner: isCollapsible),
      request: AdRequest(nonPersonalizedAds: Utils.nonPersonalizedAds(), extras: extras),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          Debug.printLog('BannerAd [$adUnitId] loaded.');
          onBannerAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          Debug.printLog('BannerAd [$adUnitId] failed to load: $error');
          onBannerAdFailedToLoad();
          ad.dispose();
        },
        onPaidEvent: (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
          _sendPaidEventToFirebase(valueMicros, currencyCode, precision.name, adUnitId,
              ad.responseInfo?.mediationAdapterClassName);
        },
        onAdImpression: (Ad ad) {
          Preference.increaseAdsDisplayCount();
        },
      ),
    );

    _bannerAds[adUnitId]?.load();
    return _bannerAds[adUnitId];
  }

  void _sendPaidEventToFirebase(double valueMicros, String currencyCode, String precisionName,
      String adUnitId, String? mediationAdapterClassName) {
    var params = {
      'valuemicros': valueMicros, // Log ad value in micros.
      // These values below won’t be used in ROAS recipe.
      // But log for purposes of debugging and future reference.
      'currency': currencyCode,
      'precision': precisionName,
      'adunitid': adUnitId,
      'network': mediationAdapterClassName,
    };

    FirebaseAnalytics.instance.logEvent(name: 'paid_ad_impression', parameters: params);

    // send ad revenue info to Adjust
    AdjustAdRevenue adRevenue = AdjustAdRevenue(AdjustConfig.AdRevenueSourceAdMob);
    adRevenue.setRevenue(valueMicros / 1000000, currencyCode);
    Adjust.trackAdRevenueNew(adRevenue);
  }

  void disposeAppOpenAd(String adUnitId) {
    _appOpenAds[adUnitId]?.dispose();
    _appOpenAds[adUnitId] = null;
  }

  void disposeInterstitialAdById(String adUnitId) {
    _interstitialAds[adUnitId]?.dispose();
    _interstitialAds[adUnitId] = null;
  }

  void disposeNativeAd(String adUnitId) {
    _nativeAds[adUnitId]?.dispose();
    _nativeAds[adUnitId] = null;
  }

  void disposeBannerAd(String adUnitId) {
    _bannerAds[adUnitId]?.dispose();
    _bannerAds[adUnitId] = null;
  }

  void showAppOpenAd(String adUnitId, {Function? onNextAction}) {
    // Skip showing new ad if there is already exist an ad.
    if (_isFullscreenAdShowing) {
      if (onNextAction != null) onNextAction();
      return;
    }
    if (_appOpenAds[adUnitId] == null) {
      loadAppOpenAd(adUnitId);
      return;
    }
    if (DateTime.now().subtract(_maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      Debug.printLog('Maximum cache duration exceeded. Loading another AppOpenAd.');
      disposeAppOpenAd(adUnitId);
      loadAppOpenAd(adUnitId);
      return;
    }

    // Show loading dialog first
    _showAdLoadingDialog();
    Timer(const Duration(milliseconds: 500), () {
      _showBlankDialog();
      _appOpenAds[adUnitId]?.show();
    });
  }

  void showAppOpenSplashAd(String adUnitId, {Function? onNextAction, Widget? nextScreen}) {
    // Skip showing new ad if there is already exist an ad.
    if (_isFullscreenAdShowing) {
      if (onNextAction != null) onNextAction();
      if (nextScreen != null) Get.to(() => nextScreen);
      return;
    }

    // Show loading dialog first
    _showAdLoadingDialog();
    Timer(const Duration(milliseconds: 500), () {
      _showBlankDialog();
      AppOpenAd? appOpenAd = _appOpenAds[adUnitId];

      if (appOpenAd != null && _readyToShowAds) {
        appOpenAd.show();
      } else {
        if (onNextAction != null) {
          Get.back();
          onNextAction();
        } else if (nextScreen != null) {
          Get.off(() => nextScreen);
        }
      }
      appOpenAd = null;
    });
  }

  void showInterstitialAd(String adUnitId, {Function? onNextAction, Widget? nextScreen}) {
    // Skip showing new ad if there is already exist an ad.
    if (_isFullscreenAdShowing) {
      if (onNextAction != null) onNextAction();
      if (nextScreen != null) Get.to(() => nextScreen);
      return;
    }
    // Show loading dialog first
    _showAdLoadingDialog();
    // Show Ads after 1 sec
    Timer(const Duration(seconds: 1), () {
      _showBlankDialog();
      InterstitialAd? interstitialAd = _interstitialAds[adUnitId];

      if (interstitialAd != null && _readyToShowAds) {
        interstitialAd.show();
      } else {
        if (onNextAction != null) {
          Get.back();
          onNextAction();
        } else if (nextScreen != null) {
          Get.off(() => nextScreen);
        }
      }
      interstitialAd = null;
    });
  }

  void _showAdLoadingDialog() {
    Get.to(() => const AdLoadingDialog());
    Get.put(AdLoadingController()).hideLoadingEffect(false);
  }

  void _showBlankDialog() {
    Get.put(AdLoadingController()).hideLoadingEffect(true);
  }

  List checkEnableBannerAd(String adUnitId) {
    bool isEnableBannerAd = false;
    bool isCollapsible = false;
    if (Debug.USE_COLLAPSIBLE_BANNER) {
      String configBannerAd =
          FirebaseRemoteConfig.instance.getString('${adUnitId}_collapsible').toUpperCase();
      isEnableBannerAd = (configBannerAd == 'TRUE' || configBannerAd == 'TRUE_COLLAPSIBLE');
      isCollapsible = configBannerAd == 'TRUE_COLLAPSIBLE';
    } else {
      isEnableBannerAd = FirebaseRemoteConfig.instance.getBool(adUnitId);
      isCollapsible = false;
    }
    return [isEnableBannerAd, isCollapsible];
  }
}
