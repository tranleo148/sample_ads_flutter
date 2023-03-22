
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../ads/ad_helper.dart';
import '../../custom/common_top_bar.dart';
import '../../ads/native_ad_holder.dart';
import '../../interfaces/top_bar_click_listener.dart';
import '../../localization/language/languages.dart';
import '../../localization/locale_constant.dart';
import '../../ads/ads_repository.dart';
import '../../utils/color_const.dart';
import '../../utils/constant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements TopBarClickListener {
  int _nativeAdLoaded = 0;
  NativeAd? _nativeAd;

  var currentDate = DateTime.now();
  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    _loadAds();
    initializeDateFormatting(getLocale().languageCode);

    super.initState();
  }

  void _loadAds() {
    Debug.printLog('Started load NativeAds for HomeScreen.');
    if (FirebaseRemoteConfig.instance.getBool(AdHelper.adsNativeHome)) {
      _nativeAd = AdsRepository.instance.loadNativeAd(AdHelper.adsNativeHome, () {
        setState(() {
          _nativeAdLoaded = 1;
        });
      }, () {
        setState(() {
          _nativeAdLoaded = -1;
        });
      }, 2);
    } else {
      _nativeAdLoaded = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    var fullWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colur.common_bg_dark,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: EdgeInsets.only(left: fullWidth * 0.05),
            child: CommonTopBar(
              Languages.of(context)!.txtRunTracker,
              this,
              isShowSubheader: true,
              subHeader: Languages.of(context)!.txtGoFasterSmarter,
              isInfo: true,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  NativeAdHolder(
                    loaded: _nativeAdLoaded,
                    nativeAd: _nativeAd,
                    adSize: 180,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onTopBarClick(String name, {bool value = true}) {
  }
}
