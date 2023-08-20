
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'adds.dart';

class TranslationHistoryItem {
  final String englishText;
  final String spanishText;

  TranslationHistoryItem({required this.englishText, required this.spanishText});
}

class HistoryScreen extends StatefulWidget {
  final List<TranslationHistoryItem> translationHistory;


  const HistoryScreen({Key? key, required this.translationHistory, }) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}



class _HistoryScreenState extends State<HistoryScreen> {
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: testBannerAd,
      listener: BannerAdListener(onAdLoaded: (ad) {
        setState(() {
          isAdLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        ad.dispose();
        print(error);
      }),
      request: const AdRequest(),
    );
    bannerAd.load();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initBannerAd();
  }
  void clearHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text("Are you sure you want to delete the history?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.translationHistory.clear(); // Clear the history
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        title: const Text(
          "History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete,
              size: 25,
            ),
            onPressed: (){
              clearHistory();

            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: widget.translationHistory.length,

          itemBuilder: (context, index) {
            final item = widget.translationHistory[index];
            return Card(
              elevation: 5,
              shadowColor: Colors.white,
              child: ListTile(
                title: Text('English:  ${item.englishText}\nSpanish:  ${item.spanishText}',style:  const TextStyle(color: Colors.black, fontSize: 15),),
              ),
            );
          },
        ),
      ),
        bottomNavigationBar: isAdLoaded
            ? Container(
            height: bannerAd.size.height.toDouble(),
            width: bannerAd.size.width.toDouble(),
            child: AdWidget(ad: bannerAd))
            : const SizedBox(),
    );
  }
}
