import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'adds.dart';



class FavouriteItem{
  final String engText;
  final String spaText;

  FavouriteItem( {required this.engText, required this.spaText});


}


class FavouriteScreen extends StatefulWidget {
  final List<FavouriteItem> favouriteItems;
  const FavouriteScreen({Key? key, required this.favouriteItems}) : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  var adUnit = testBannerAd;
  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnit,
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
    super.initState();
    initBannerAd();
  }
  void deleteFavouriteItems() {
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
                  widget.favouriteItems.clear(); // Clear the history
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
          "Favourite",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete,
              size: 25,
            ),
            onPressed: (){
              deleteFavouriteItems();

            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: widget.favouriteItems.length,
          itemBuilder: (context, index) {
            final item = widget.favouriteItems[index];
            return Card(
              shadowColor: Colors.white,
              elevation: 5,
              child: ListTile(
                title: Text('${item.engText}\n${item.spaText}',style: const TextStyle(color: Colors.black, fontSize: 15),),
              ),
            );
          },
        ),
      ),
    );
  }
}
