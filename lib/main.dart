import 'package:english_to_spanish_translator/home_screen.dart';
import 'package:english_to_spanish_translator/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'adds.dart';


AppOpenAd? appOpenAd;
loadAppOpenAd(){
  AppOpenAd.load(
    
    adUnitId: testOpenAd,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad){
            appOpenAd = ad;
            appOpenAd!.show();
          },
          onAdFailedToLoad: (error){
            print(error);
          }),
      orientation: AppOpenAd.orientationPortrait);
}
void main() async{
  //var devices = ["C44B352AB59CF22DCB33CE4C7013CACA"];
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  // RequestConfiguration requestConfiguration = RequestConfiguration(testDeviceIds: devices);
  // MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  loadAppOpenAd();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: SplashScreen()
    );
  }
}

