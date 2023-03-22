import 'dart:ui';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_attribution.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event_failure.dart';
import 'package:adjust_sdk/adjust_event_success.dart';
import 'package:adjust_sdk/adjust_session_failure.dart';
import 'package:adjust_sdk/adjust_session_success.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads/ad_helper.dart';
import 'app/app_lifecycle_reactor.dart';
import 'firebase_options.dart';
import 'localization/locale_constant.dart';
import 'localization/localizations_delegate.dart';
import 'ads/ads_repository.dart';
import 'ui/home/home_wizard_screen.dart';
import 'ui/splash_screen/splash_interstitial_ads.dart';
import 'utils/color_const.dart';
import 'utils/constant.dart';
import 'utils/preference.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initSharedPreference();

  await _initFirebase();
  await _initRemoteConfig();
  await _initGoogleMobileAds();

  _initAdjustSdk();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

Future<void> _initSharedPreference() async {
  await Preference().instance();
  Preference.shared.setBool(Preference.REVIEW_DISPLAYED, false);
  Preference.shared.setInt(Preference.ADS_DISPLAY_COUNT, 0);
}

Future<void> _initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> _initRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(minutes: 15),
  ));
  await remoteConfig.setDefaults({
    AdHelper.adsInterSplash: false,
    AdHelper.adsNativeLanguage: false,
    AdHelper.adsResume: false,
    AdHelper.adsInterClickRun: false,
    AdHelper.adsNativeHome: false,
    AdHelper.adsBannerHome: false,
  });
  try {
    await remoteConfig.fetchAndActivate();
  } on Exception catch (_) {}
}

Future<void> _initGoogleMobileAds() async {
  MobileAds.instance.initialize();
  if (Debug.DEBUG) {
    MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
        testDeviceIds: [
          '6193BF4850905CC9929CC4D64C85F00A',
          'B7B3A9F6A4689B08D3005BB570573949'
        ]));
  }
}

void _initAdjustSdk() {
  AdjustConfig config = AdjustConfig(Constant.ADJUST_ID,
      Debug.DEBUG ? AdjustEnvironment.sandbox : AdjustEnvironment.production);
  config.logLevel =
      Debug.DEBUG ? AdjustLogLevel.debug : AdjustLogLevel.suppress;

  config.attributionCallback = (AdjustAttribution attributionChangedData) {
    Debug.printLog('[Adjust]: Attribution changed!');

    if (attributionChangedData.trackerToken != null) {
      Debug.printLog(
          '[Adjust]: Tracker token: ${attributionChangedData.trackerToken!}');
    }
    if (attributionChangedData.trackerName != null) {
      Debug.printLog(
          '[Adjust]: Tracker name: ${attributionChangedData.trackerName!}');
    }
    if (attributionChangedData.campaign != null) {
      Debug.printLog('[Adjust]: Campaign: ${attributionChangedData.campaign!}');
    }
    if (attributionChangedData.network != null) {
      Debug.printLog('[Adjust]: Network: ${attributionChangedData.network!}');
    }
    if (attributionChangedData.creative != null) {
      Debug.printLog('[Adjust]: Creative: ${attributionChangedData.creative!}');
    }
    if (attributionChangedData.adgroup != null) {
      Debug.printLog('[Adjust]: Adgroup: ${attributionChangedData.adgroup!}');
    }
    if (attributionChangedData.clickLabel != null) {
      Debug.printLog(
          '[Adjust]: Click label: ${attributionChangedData.clickLabel!}');
    }
    if (attributionChangedData.adid != null) {
      Debug.printLog('[Adjust]: Adid: ${attributionChangedData.adid!}');
    }
    if (attributionChangedData.costType != null) {
      Debug.printLog(
          '[Adjust]: Cost type: ${attributionChangedData.costType!}');
    }
    if (attributionChangedData.costAmount != null) {
      Debug.printLog(
          '[Adjust]: Cost amount: ${attributionChangedData.costAmount!}');
    }
    if (attributionChangedData.costCurrency != null) {
      Debug.printLog(
          '[Adjust]: Cost currency: ${attributionChangedData.costCurrency!}');
    }
  };

  config.sessionSuccessCallback = (AdjustSessionSuccess sessionSuccessData) {
    Debug.printLog('[Adjust]: Session tracking success!');

    if (sessionSuccessData.message != null) {
      Debug.printLog('[Adjust]: Message: ${sessionSuccessData.message!}');
    }
    if (sessionSuccessData.timestamp != null) {
      Debug.printLog('[Adjust]: Timestamp: ${sessionSuccessData.timestamp!}');
    }
    if (sessionSuccessData.adid != null) {
      Debug.printLog('[Adjust]: Adid: ${sessionSuccessData.adid!}');
    }
    if (sessionSuccessData.jsonResponse != null) {
      Debug.printLog(
          '[Adjust]: JSON response: ${sessionSuccessData.jsonResponse!}');
    }
  };

  config.sessionFailureCallback = (AdjustSessionFailure sessionFailureData) {
    Debug.printLog('[Adjust]: Session tracking failure!');

    if (sessionFailureData.message != null) {
      Debug.printLog('[Adjust]: Message: ${sessionFailureData.message!}');
    }
    if (sessionFailureData.timestamp != null) {
      Debug.printLog('[Adjust]: Timestamp: ${sessionFailureData.timestamp!}');
    }
    if (sessionFailureData.adid != null) {
      Debug.printLog('[Adjust]: Adid: ${sessionFailureData.adid!}');
    }
    if (sessionFailureData.willRetry != null) {
      Debug.printLog('[Adjust]: Will retry: ${sessionFailureData.willRetry}');
    }
    if (sessionFailureData.jsonResponse != null) {
      Debug.printLog(
          '[Adjust]: JSON response: ${sessionFailureData.jsonResponse!}');
    }
  };

  config.eventSuccessCallback = (AdjustEventSuccess eventSuccessData) {
    Debug.printLog('[Adjust]: Event tracking success!');

    if (eventSuccessData.eventToken != null) {
      Debug.printLog('[Adjust]: Event token: ${eventSuccessData.eventToken!}');
    }
    if (eventSuccessData.message != null) {
      Debug.printLog('[Adjust]: Message: ${eventSuccessData.message!}');
    }
    if (eventSuccessData.timestamp != null) {
      Debug.printLog('[Adjust]: Timestamp: ${eventSuccessData.timestamp!}');
    }
    if (eventSuccessData.adid != null) {
      Debug.printLog('[Adjust]: Adid: ${eventSuccessData.adid!}');
    }
    if (eventSuccessData.callbackId != null) {
      Debug.printLog('[Adjust]: Callback ID: ${eventSuccessData.callbackId!}');
    }
    if (eventSuccessData.jsonResponse != null) {
      Debug.printLog(
          '[Adjust]: JSON response: ${eventSuccessData.jsonResponse!}');
    }
  };

  config.eventFailureCallback = (AdjustEventFailure eventFailureData) {
    Debug.printLog('[Adjust]: Event tracking failure!');

    if (eventFailureData.eventToken != null) {
      Debug.printLog('[Adjust]: Event token: ${eventFailureData.eventToken!}');
    }
    if (eventFailureData.message != null) {
      Debug.printLog('[Adjust]: Message: ${eventFailureData.message!}');
    }
    if (eventFailureData.timestamp != null) {
      Debug.printLog('[Adjust]: Timestamp: ${eventFailureData.timestamp!}');
    }
    if (eventFailureData.adid != null) {
      Debug.printLog('[Adjust]: Adid: ${eventFailureData.adid!}');
    }
    if (eventFailureData.callbackId != null) {
      Debug.printLog('[Adjust]: Callback ID: ${eventFailureData.callbackId!}');
    }
    if (eventFailureData.willRetry != null) {
      Debug.printLog('[Adjust]: Will retry: ${eventFailureData.willRetry}');
    }
    if (eventFailureData.jsonResponse != null) {
      Debug.printLog(
          '[Adjust]: JSON response: ${eventFailureData.jsonResponse!}');
    }
  };

  Adjust.start(config);
}

class MyApp extends StatefulWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static late AppLifecycleReactor appLifecycleReactor;

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    _locale = getLocale();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MyApp.appLifecycleReactor = AppLifecycleReactor()
      ..listenToAppStateChanges();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        Adjust.onResume();
        AdsRepository.instance.onResume();
        break;
      case AppLifecycleState.paused:
        Adjust.onPause();
        AdsRepository.instance.onPause();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        navigatorKey: MyApp.navigatorKey,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        theme: ThemeData(
          splashColor: Colur.transparent,
          highlightColor: Colur.transparent,
          fontFamily: 'Roboto',
          primarySwatch: Colur.primary,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(secondary: Colur.white, brightness: Brightness.light),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colur.transparent,
          ),
        ),
        debugShowCheckedModeBanner: false,
        locale: _locale,
        supportedLocales: const [
          Locale('en', ''),
          Locale('vi', ''),
          Locale('es', ''),
          Locale('hi', ''),
          Locale('pt', ''),
        ],
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode &&
                supportedLocale.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        home: const AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colur.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colur.common_bg_dark,
          ),
          child: SplashInterstitialAdsScreen(),
        ),
        routes: <String, WidgetBuilder>{
          '/splashScreen': (BuildContext context) =>
              const SplashInterstitialAdsScreen(),
          '/homeWizardScreen': (BuildContext context) =>
              const HomeWizardScreen(),
        });
  }
}
