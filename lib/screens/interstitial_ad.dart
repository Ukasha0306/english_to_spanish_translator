import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'adds.dart';




class InterstitialAdScreen extends StatefulWidget {
  const InterstitialAdScreen({super.key});

  @override
  State<InterstitialAdScreen> createState() => InterstitialAdScreenState();
}

class InterstitialAdScreenState extends State<InterstitialAdScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initInterstitialAd();
  }
  static late InterstitialAd interstitialAd;
  static bool isInAdLoaded = false;

  static initInterstitialAd(){
    InterstitialAd.load(
       // adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      adUnitId: testInterAd,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad){
              interstitialAd = ad;
                isInAdLoaded = true;
              interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad){
                  // ad.dispose();
                  initInterstitialAd();
                  // after that you can do whatever we require according to our needs
                },
                onAdFailedToShowFullScreenContent: (ad, error){
                  // ad.dispose();
                  initInterstitialAd();
                }
              );
            },
            onAdFailedToLoad: ((error){
              interstitialAd.dispose();
            })
        ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
                onPressed: (){
                  if(isInAdLoaded){
                    interstitialAd.show();
                  }
                },
                child: const Text('Interstitial Ad')),
          )

        ],
      ),
    );
  }
}
