import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../ads/ad_helper.dart';
import '../../main.dart';
import '../../ads/ads_repository.dart';
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
    //AdsRepository.instance.disposeInterstitialAdById(AdHelper.adsInterSplash);
    super.dispose();
  }

  _isFirstTime() async {
    isFirstTimeUser = Preference.shared.getBool(Preference.IS_USER_FIRSTTIME, true);
    Debug.printLog(isFirstTimeUser.toString());
  }

  void _loadAds() {
    Debug.printLog('Started load SplashInterstitial Ad.');
    if (FirebaseRemoteConfig.instance.getBool(AdHelper.adsInterSplash)) {
      FirebaseAnalytics.instance.logEvent(name: 'inter_splash_request');
      AdsRepository.instance.loadInterstitialAd(
        AdHelper.adsInterSplash,
        onAdLoaded: () => FirebaseAnalytics.instance.logEvent(name: 'inter_splash_load_success'),
        onAdFailedToLoad: () => FirebaseAnalytics.instance.logEvent(name: 'inter_splash_load_fail'),
        onAdShowed: () => FirebaseAnalytics.instance.logEvent(name: 'inter_splash_show'),
        onNextAction: () => _navigateToHome(),
      );
      var countRetry = 20;
      Timer.periodic(const Duration(seconds: 1), (timer) {
        Debug.printLog('Try to show splash_interstitial_ad: ${timer.tick}');
        countRetry--;
        InterstitialAd? interstitialAd =
            AdsRepository.instance.getInterstitialAdById(AdHelper.adsInterSplash);
        if (countRetry == 0 || interstitialAd != null) {
          timer.cancel();
          _showInterstitialAd();
        }
      });
    } else {
      _navigateToHome();
    }
  }

  void _showInterstitialAd() {
    setState(() {
      _isShowAdSplashInterstitial = true;
    });

    AdsRepository.instance.showInterstitialAd(
      AdHelper.adsInterSplash,
      onNextAction: () => _navigateToHome(),
    );
  }

  void _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
            (isFirstTimeUser) ? const LanguageSelectionScreen() : const HomeWizardScreen()),
            (route) => false,
      );
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
