import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../ads/ad_helper.dart';
import '../../ads/ads_repository.dart';
import '../../main.dart';
import '../../utils/constant.dart';
import '../../utils/preference.dart';
import '../home/home_wizard_screen.dart';
import '../language_selection_screen.dart';

class SplashInterstitialAdsScreen extends StatefulWidget {
  const SplashInterstitialAdsScreen({Key? key}) : super(key: key);

  @override
  State<SplashInterstitialAdsScreen> createState() => _SplashInterstitialAdsState();
}

class _SplashInterstitialAdsState extends State<SplashInterstitialAdsScreen>
    with WidgetsBindingObserver {
  bool isFirstTimeUser = true;
  bool _isShowAdSplashInterstitial = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    MyApp.appLifecycleReactor.setOnSplashScreen(true);
    _isFirstTime();
    _loadAds();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _isFirstTime() async {
    isFirstTimeUser = Preference.shared.getBool(Preference.IS_USER_FIRSTTIME, true);
    Debug.printLog(isFirstTimeUser.toString());
  }

  void _loadAds() {
    Debug.printLog('Started load SplashInterstitial Ad.');
    if (FirebaseRemoteConfig.instance.getBool(AdHelper.adsAppOpenHigh)) {
      AdsRepository.instance.loadSplashAdWithAppOpenAndInter(
        AdHelper.adsAppOpenHigh,
        AdHelper.adsInterSplash,
        onNextAction: () => _navigateToHome(),
      );
      var countRetry = 20;
      Timer.periodic(const Duration(seconds: 1), (timer) {
        Debug.printLog('Try to show splash ads with AppOpen and Interstitial: ${timer.tick}');
        countRetry--;
        AdWithoutView? splashAd = AdsRepository.instance.getSplashAdIfAvailable(
          AdHelper.adsAppOpenHigh,
          AdHelper.adsInterSplash,
        );
        if (countRetry == 0 || splashAd != null) {
          timer.cancel();
          _showSplashAd(splashAd is AppOpenAd);
        }
      });
    } else {
      _navigateToHome();
    }
  }

  void _showSplashAd(bool isAppOpenAd) {
    setState(() {
      _isShowAdSplashInterstitial = true;
    });

    if (isAppOpenAd) {
      AdsRepository.instance.showAppOpenSplashAd(
        AdHelper.adsAppOpenHigh,
        onNextAction: () => _navigateToHome(),
      );
      // Dispose interAd if available
      AdsRepository.instance.disposeInterstitialAd(AdHelper.adsInterSplash);
    } else {
      AdsRepository.instance.showInterstitialAd(
        AdHelper.adsInterSplash,
        onNextAction: () => _navigateToHome(),
      );
      // Dispose appOpenAd if available
      AdsRepository.instance.disposeAppOpenAd(AdHelper.adsAppOpenHigh);
    }
  }

  void _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.to(() => (isFirstTimeUser) ? const LanguageSelectionScreen() : const HomeWizardScreen());
      MyApp.appLifecycleReactor.setOnSplashScreen(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_isShowAdSplashInterstitial
          ? Stack(
              children: [
                Image.asset(
                  'assets/images/ic_splash.png',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                ),
                Center(
                  child: Column(
                    children: const [
                      Expanded(child: SizedBox()),
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'This action can contain ads...',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const SizedBox(),
    );
  }
}
