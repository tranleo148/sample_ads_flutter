import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads/ad_helper.dart';
import '../custom/gradient_button_small.dart';
import '../ads/native_ad_holder.dart';
import '../localization/language/languages.dart';
import '../localization/language_data.dart';
import '../localization/locale_constant.dart';
import '../ads/ads_repository.dart';
import '../utils/color_const.dart';
import '../utils/preference.dart';
import '../utils/utils.dart';

class LanguageSelectionScreen extends StatefulWidget {

  const LanguageSelectionScreen(
      {Key? key})
      : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelectionScreen> {
  bool _loadedLanguage = false;
  late LanguageData _languagesChosenValue; // = LanguageData.languageList()[0];
  late List<LanguageData> languages; // = LanguageData.languageList();
  String? prefLanguage;
  int _nativeAdLoaded = 0;
  NativeAd? _nativeAd;

  @override
  void initState() {
    if (FirebaseRemoteConfig.instance.getBool(AdHelper.adsNativeLanguage)) {
      _nativeAd = AdsRepository.instance.loadNativeAd(AdHelper.adsNativeLanguage, () {
        setState(() {
          _nativeAdLoaded = 1;
        });
      }, () {
        setState(() {
          _nativeAdLoaded = -1;
        });
      });
    } else {
      _nativeAdLoaded = -1;
    }
    super.initState();
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
    var fullHeight = MediaQuery.of(context).size.height;
    var fullWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colur.common_bg_dark,
        child: SafeArea(
          child: Container(
            height: fullHeight,
            width: fullWidth,
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
                    style:
                    const TextStyle(fontWeight: FontWeight.w400, color: Colur.txt_grey, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _languagesList(fullHeight),
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
      ),
    );
  }

  Widget _languagesList(double fullHeight) {
    return ListView.separated(
      itemCount: languages.length,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return _languageView(context, index, fullHeight);
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 10);
      },
    );
  }

  int selectedIdx = 0;
  Widget _languageView(BuildContext context, int index, double fullheight) {
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
          Preference.shared.setString(Preference.LANGUAGE, _languagesChosenValue!.languageCode);
          changeLanguage(context, _languagesChosenValue!.languageCode);
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

  Widget _languageSelector(double fullHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(padding: EdgeInsets.only(bottom: fullHeight * 0.025), child: Utils.getRightArrow()),
        SizedBox(
          width: 260,
          height: fullHeight * 0.25,
          child: CupertinoPicker(
            useMagnifier: true,
            magnification: 1.05,
            selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
              background: Colur.transparent,
            ),
            looping: true,
            scrollController: FixedExtentScrollController(initialItem: 2),
            onSelectedItemChanged: (value) {
              setState(() {
                _languagesChosenValue = languages[value];
                Preference.shared
                    .setString(Preference.LANGUAGE, _languagesChosenValue!.languageCode);
                changeLanguage(context, _languagesChosenValue!.languageCode);
              });
            },
            itemExtent: 60.0,
            children: languages
                .map((e) => Text(
                      e.name,
                      style: const TextStyle(
                          color: Colur.txt_white, fontSize: 28, fontWeight: FontWeight.bold),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}
