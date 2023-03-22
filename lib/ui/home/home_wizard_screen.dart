import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../ads/ad_helper.dart';
import '../../ads/banner_ad_holder.dart';
import '../../ads/ads_repository.dart';
import '../../utils/color_const.dart';
import '../../utils/constant.dart';
import '../../utils/preference.dart';
import 'home_screen.dart';

class HomeWizardScreen extends StatefulWidget {
  const HomeWizardScreen({Key? key}) : super(key: key);

  @override
  State<HomeWizardScreen> createState() => _HomeWizardScreenState();
}

class _HomeWizardScreenState extends State<HomeWizardScreen> {
  final PageController _myPage = PageController(initialPage: 0);
  int? num;

  late BannerAd? _bannerAd;
  int _isBannerAdReady = 0;
  bool _isHideBanner = false;

  @override
  void initState() {
    Preference.shared.remove(Preference.IS_PAUSE);
    _loadAds();
    super.initState();
    num = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadAds({isBannerOnly = false}) {
    Debug.printLog('Started load Interstitial Ads for HomeWizardScreen.');
    if (!isBannerOnly && FirebaseRemoteConfig.instance.getBool(AdHelper.adsInterClickRun)) {
      InterstitialAd? interAdClickRun =
          AdsRepository.instance.getInterstitialAdById(AdHelper.adsInterClickRun);
      if (interAdClickRun == null) {
        AdsRepository.instance.loadInterstitialAd(
          AdHelper.adsInterClickRun,
          //onNextAction: _navigateByPermissionResult,
        );
      }
    }

    List result = AdsRepository.instance.checkEnableBannerAd(AdHelper.adsBannerHome);
    bool isEnableBannerAd = result[0];
    bool isCollapsible = result[1];
    if (isEnableBannerAd) {
      _bannerAd = AdsRepository.instance.loadBannerAd(
        AdHelper.adsBannerHome,
        () => setState(() {
          _isBannerAdReady = 1;
        }),
        () => setState(() {
          _isBannerAdReady = -1;
        }),
        isCollapsible,
      );
    } else {
      _isBannerAdReady = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    List result = AdsRepository.instance.checkEnableBannerAd(AdHelper.adsBannerHome);
    bool isEnableBannerAd = result[0];

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colur.rounded_rectangle_color,
        bottomNavigationBar: BottomAppBar(
          color: Colur.rounded_rectangle_color,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              num = 0;
                              _myPage.jumpToPage(0);
                              _isHideBanner = false;
                            });
                            _loadAds(isBannerOnly: true);
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: Image.asset(
                              (num == 0)
                                  ? 'assets/icons/ic_selected_home_bottombar.webp'
                                  : 'assets/icons/ic_unselected_home_bottombar.webp',
                              scale: 3.5,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              num = 1;
                              _myPage.jumpToPage(1);
                              _isHideBanner = true;
                              _isBannerAdReady = 0;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: Image.asset(
                              (num == 1)
                                  ? 'assets/icons/ic_selected_profile_bottombar.webp'
                                  : 'assets/icons/ic_unselected_profile_bottombar.webp',
                              scale: 3.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isEnableBannerAd)
                  Visibility(
                    visible: !_isHideBanner,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      color: Colur.common_bg_dark,
                      child: BannerAdHolder(
                        loaded: _isBannerAdReady,
                        bannerAd: _bannerAd,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: InkWell(
          onTap: () async {
          },
          child: SizedBox(
            height: 75,
            width: 75,
            child: Image.asset(
              'assets/icons/ic_person_bottombar.webp',
              height: 45,
              width: 45,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colur.common_bg_dark,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 9,
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _myPage,
                  onPageChanged: (pos) {
                    if (pos == 0) {
                      setState(() {
                        num = 0;
                      });
                    } else if (pos == 1) {
                      setState(() {
                        num = 1;
                      });
                    } else {
                      setState(() {
                        num = 0;
                      });
                    }
                    Debug.printLog('Page changed to: $pos');
                  },
                  children: const <Widget>[
                    HomeScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
