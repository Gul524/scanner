import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static String? bannerAdUnitId;
  static String? appOpenAdUnitId;
  static AppOpenAd? appOpenAd;
  static BannerAd? bannerAd;
  static bool isShowingAd = false;
  static bool isAppOpenAdLoaded = false;

  // Initialize Test Ad IDs
  static void initAdIds() {
    if (Platform.isAndroid) {
      // Test Ad Units for Android
      bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';  // Android Test Banner
      appOpenAdUnitId = 'ca-app-pub-3940256099942544/3419835294'; // Android Test App Open
    } else if (Platform.isIOS) {
      // Test Ad Units for iOS
      bannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';  // iOS Test Banner
      appOpenAdUnitId = 'ca-app-pub-3940256099942544/5662855259'; // iOS Test App Open
    }
  }

  // Load App Open Ad
  static Future<void> loadAppOpenAd() async {
    if (appOpenAdUnitId == null) {
      print('Ad unit ID is null. Make sure to call initAdIds() first');
      return;
    }

    await AppOpenAd.load(
      adUnitId: appOpenAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('App Open Ad loaded successfully');
          AdService.appOpenAd = ad;
          AdService.isAppOpenAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          print('App Open Ad failed to load: $error');
          AdService.isAppOpenAdLoaded = false;
        },
      ),
    );
  }

  // Show App Open Ad
  static Future<void> showAppOpenAd() async {
    if (!isAppOpenAdLoaded || appOpenAd == null) {
      print('Trying to show AppOpenAd before loaded.');
      return;
    }

    appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AdService.isShowingAd = true;
        print('App Open Ad showed full screen content');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('App Open Ad failed to show: $error');
        AdService.isShowingAd = false;
        ad.dispose();
        AdService.appOpenAd = null;
        AdService.isAppOpenAdLoaded = false;
        loadAppOpenAd(); // Reload the ad
      },
      onAdDismissedFullScreenContent: (ad) {
        print('App Open Ad was dismissed');
        AdService.isShowingAd = false;
        ad.dispose();
        AdService.appOpenAd = null;
        AdService.isAppOpenAdLoaded = false;
        loadAppOpenAd(); // Reload the ad
      },
    );

    await appOpenAd!.show();
  }

  // Create Banner Ad
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId!,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner Ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner Ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (ad) {
          print('Banner Ad opened');
        },
        onAdClosed: (ad) {
          print('Banner Ad closed');
        },
      ),
    );
  }

  // Dispose App Open Ad
  static void disposeAppOpenAd() {
    appOpenAd?.dispose();
    appOpenAd = null;
    isAppOpenAdLoaded = false;
  }
} 