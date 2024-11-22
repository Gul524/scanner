import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scanner/config/navigation.dart';
import 'package:scanner/pages/adsSecreens/openadsSecreen.dart';
import 'package:scanner/pages/homepage/allfileTab/oldFiles.dart';
import 'package:scanner/pages/homepage/homepage.dart';
import 'package:scanner/pages/splashpage/splashwidgets.dart';
import 'package:scanner/services/ad_service.dart';
import 'package:scanner/sevices/data.dart';
import 'package:scanner/sevices/permissionfunctions.dart';
import 'package:scanner/utils/assets.dart';
import 'package:scanner/utils/colors.dart';
import 'package:scanner/utils/size.dart';

class Splashpage extends StatefulWidget {
  const Splashpage({super.key});

  @override
  State<Splashpage> createState() => _SplashpageState();
}

class _SplashpageState extends State<Splashpage> {
  Navigations nav = Navigations();

  checkPermission() async {
    await DataPermission.checkStoragePermissions();
    await DataPermission.checkCameraPermissions();
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
    AdService.loadAppOpenAd();
    
    Timer(const Duration(seconds: 2), () {
      nav.replace(context, const HomePage());
    });
  }
  @override
void dispose() {
  if(AdService.bannerAd != null){
    AdService.bannerAd!.dispose();
  }
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.themeColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 100, 
            width: 100, 
            child: Image.asset(myImages.Logo)
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Easy",
                style: TextStyle(
                  fontSize: sizes.texth3,
                  color: colors.InvrsethemeColor,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                " Scan",
                style: TextStyle(
                  fontSize: sizes.texth1,
                  color: colors.primary,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const LoadingAnimation()
        ],
      )
    );
  }
}
