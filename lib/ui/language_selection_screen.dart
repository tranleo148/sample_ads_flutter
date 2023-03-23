import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads/ad_helper.dart';
import '../ads/ads_repository.dart';
import '../ads/native_ad_holder.dart';
import '../custom/gradient_button_small.dart';
import '../localization/language/languages.dart';
import '../localization/language_data.dart';
import '../localization/locale_constant.dart';
import '../utils/color_const.dart';
import '../utils/preference.dart';
import 'home/home_wizard_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelectionScreen> {
  bool _loadedLanguage = false;
  late LanguageData _languagesChosenValue; // = LanguageData.languageList()[0];
  late List<LanguageData> languages; // = LanguageData.languageList();
  bool _showLanguageList = false;
  String? prefLanguage;

  int _nativeAdLoaded = -1;
  NativeAd? _nativeAd;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) afterFirstLayout(context);
      },
    );
  }

  @override
  void didChangeDependencies() {
    if (!_loadedLanguage) {
      _getLanguages();
      _loadedLanguage = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    AdsRepository.instance.disposeNativeAd(AdHelper.adsNativeLanguage);
    super.dispose();
  }

  FutureOr<void> afterFirstLayout(BuildContext context) {
    // Get remoteConfig and load ADs process will take a time, so we will process them after the
    // build() is completed to prevent delay when rendering the 1st frame
    if (FirebaseRemoteConfig.instance.getBool(AdHelper.adsNativeLanguage)) {
      setState(() {
        _nativeAdLoaded = 0; // loading
      });
      _nativeAd = AdsRepository.instance.loadNativeAd(AdHelper.adsNativeLanguage, () {
        setState(() {
          _nativeAdLoaded = 1; // show ads
        });
      }, () {
        setState(() {
          _nativeAdLoaded = -1; // hide ads
        });
      });
    }
    // Show language listView
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _showLanguageList = true;
      });
    });
  }

  void _getLanguages() {
    List<LanguageData> newList = LanguageData.languageBaseList();
    Locale myLocale = Localizations.localeOf(context);
    List<LanguageData> tempList = LanguageData.languageBaseList();
    List<LanguageData> tempList2 = LanguageData.languageList();
    var filterList = tempList.where((element) => element.languageCode == myLocale.languageCode);
    if (filterList.isNotEmpty) {
      var idx = tempList.indexOf(filterList.first);
      var temp = tempList[0];
      newList[0] = filterList.first;
      newList[idx] = temp;
    } else {
      var filterList2 = tempList2.where((element) => element.languageCode == myLocale.languageCode);
      if (filterList2.isNotEmpty) {
        newList[0] = filterList2.first;
      }
    }
    languages = newList;

    prefLanguage = Preference.shared.getString(Preference.LANGUAGE);
    if (prefLanguage == null) {
      _languagesChosenValue = languages[0];
    } else {
      _languagesChosenValue =
          languages.where((element) => (element.languageCode == prefLanguage)).toList()[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colur.common_bg_dark,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        Languages.of(context)!.txtLanguageTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colur.txt_dark,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: Colur.txt_dark,
                      ),
                      iconSize: 30,
                      onPressed: () async {
                        Preference.shared.setBool(Preference.IS_USER_FIRSTTIME, false);
                        Get.to(() => const HomeWizardScreen());
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 5, left: 20),
                alignment: Alignment.centerLeft,
                child: Text(
                  Languages.of(context)!.txtSelectLanguage,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, color: Colur.txt_grey, fontSize: 15),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: (_showLanguageList) ? _languagesList() : const SizedBox(),
              ),
              NativeAdHolder(
                loaded: _nativeAdLoaded,
                nativeAd: _nativeAd,
                adSize: 250,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languagesList() {
    return ListView.separated(
      itemCount: languages.length,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return _languageView(context, index);
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 10);
      },
    );
  }

  int selectedIdx = 0;
  Widget _languageView(BuildContext context, int index) {
    return GradientButtonSmall(
      width: double.infinity,
      height: 40,
      radius: 50.0,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          selectedIdx == index ? Colur.green_gradient_color_new1 : Colors.white,
          selectedIdx == index ? Colur.green_gradient_color_new2 : Colors.white,
        ],
      ),
      onPressed: () async {
        setState(() {
          selectedIdx = index;
          _languagesChosenValue = languages[index];
          Preference.shared.setString(Preference.LANGUAGE, _languagesChosenValue.languageCode);
          changeLanguage(context, _languagesChosenValue.languageCode);
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          children: [
            /*Flag.fromString(
              languages[index].flag,
              height: 20,
              width: 20,
              replacement: const SizedBox(width: 20, height: 20),
            ),*/
            Text(
              languages[index].flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Text(
                languages[index].name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: selectedIdx == index ? Colur.white_txt : Colur.txt_grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0),
              ),
            ),
            if (selectedIdx == index)
              Image.asset(
                'assets/icons/dot_select.png',
                width: 20,
                height: 20,
              ),
          ],
        ),
      ),
    );
  }
}
