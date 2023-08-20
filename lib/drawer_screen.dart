import 'package:english_to_spanish_translator/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'drawer_list.dart';
import 'favourite_screen.dart';
import 'history.dart';


class DrawerScreen extends StatelessWidget {
  const DrawerScreen({
    super.key,
    required this.translationHistory,
    required this.favouriteItems,
  });

  final List<TranslationHistoryItem> translationHistory;
  final List<FavouriteItem> favouriteItems;

  void _privacyPolicy() async {
    const link = 'https://theazsoft.com/privacy-policy/';
    if (await launchUrl(Uri.parse(link))) {
      await launchUrl(Uri.parse(link));
    } else {
      throw 'Could not launch $link';
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height*1;
    final width  = MediaQuery.sizeOf(context).width*1;
    return InkWell(
        onTap: () {
          final FocusScopeNode currentScope = FocusScope.of(context);
          if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
      },
      child: Drawer(
        width: width*0.6,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/icon.jpg',),
                    radius: 40,
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  const Text(
                    "English to Spanish Translator",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>const HomeScreen()));
              },
              child: const DrawerList(
                title: 'Home',
                icon: (Icons.home),
                index: 1,

              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => HistoryScreen(
                          translationHistory: translationHistory,
                        )));
              },
              child: const DrawerList(
                title: 'History',
                icon: (Icons.access_time_filled_outlined),
                index: 0,
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (_)=>
                        FavouriteScreen(favouriteItems: favouriteItems,)));
              },
              child: const DrawerList(
                title: 'Favourite',
                icon: (Icons.favorite),
                index: 0,
              ),
            ),
            const Divider(
              thickness: 1,
            ),
            InkWell(
              onTap: (){},
              child: const DrawerList(
                title: 'Share',
                icon: (Icons.share),
                index: 0,
              ),
            ),
            const DrawerList(
              title: 'Rate Us',
              icon: (Icons.star),
              index: 0,
            ),
            const Divider(
              thickness: 1,
            ),
             const DrawerList(
              title: 'Feedback',
              icon: (Icons.mail),
               index: 0,
            ),
            InkWell(
              onTap: (){
                _privacyPolicy();
              },
              child: const DrawerList(
                title: 'Privacy Policy',
                icon: (Icons.lock),
                index: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}