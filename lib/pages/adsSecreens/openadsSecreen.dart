import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scanner/pages/homepage/homepage.dart';
import 'package:scanner/services/ad_service.dart';

class OpenAdsScreen extends StatefulWidget {
  const OpenAdsScreen({super.key});

  @override
  State<OpenAdsScreen> createState() => _OpenAdsScreenState();
}

class _OpenAdsScreenState extends State<OpenAdsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAdAndNavigate();
    });
  }

  void _showAdAndNavigate() async {
    if (AdService.isAppOpenAdLoaded && AdService.appOpenAd != null) {
      AdService.appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _navigateToHome();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _navigateToHome();
        },
      );
      await AdService.appOpenAd!.show();
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}