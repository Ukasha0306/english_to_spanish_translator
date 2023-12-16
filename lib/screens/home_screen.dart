import 'package:avatar_glow/avatar_glow.dart';
import 'package:english_to_spanish_translator/res/utilts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gdpr_dialog/gdpr_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../res/component/my_button.dart';
import 'adds.dart';
import 'drawer_screen.dart';
import 'favourite_screen.dart';
import 'history.dart';
import 'interstitial_ad.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

  AnimationController? _animationController;

  List<TranslationHistoryItem> translationHistory = [];
  List<FavouriteItem> favouriteItems = [];

  List<String> languages = ["English", "Spanish"];
  int currentLanguageIndex = 0;

  final textController = TextEditingController();

  GoogleTranslator translator = GoogleTranslator();
  String translatedText = '';
  bool isListening = false;
  SpeechToText speechToText = SpeechToText();

  static final _speech = SpeechToText();

  Future<bool> toggleRecording({
    required Function(String text) onResult,
    required ValueChanged<bool> onListening,
  }) async {
    if (_speech.isListening) {
      _speech.stop();
      return true;
    }

    final isAvailable = await _speech.initialize(
      onStatus: (status) => onListening(
        _speech.isListening,
      ),
      onError: (e) => print('Error: $e'),
    );

    if (isAvailable) {
      _speech.listen(onResult: (value) {
        onResult(value.recognizedWords);
        translate();
      });
    }
    return isAvailable;
  }

  //for share direct to whatsapp

  void _shareDirectToWhatsapp() async {
    final link = 'whatsapp://send?text=$translatedText';
    if (await launchUrl(Uri.parse(link.toString()))) {
      await launchUrl(Uri.parse(link.toString()));
    } else {
      throw 'Could not launch $link';
    }
  }

  void translate() {
    String targetLanguage = (currentLanguageIndex == 0) ? "es" : "en";

    translator.translate(textController.text, to: targetLanguage).then((value) {
      setState(() {
        translatedText = value.toString();
        if (kDebugMode) {
          print(value);
        }

        if (currentLanguageIndex == 0) {
          // Translated from English to Spanish
          translationHistory.add(TranslationHistoryItem(
            englishText: textController.text,
            spanishText: translatedText,
          ));
        } else {
          // Translated from Spanish to English
          translationHistory.add(TranslationHistoryItem(
            spanishText: textController.text,
            englishText: translatedText, // Swap English and Spanish text
          ));
        }
      });
    });
  }

  void shareSpanishText() {
    Share.share(translatedText);
  }

  void _clearTranslatedText() {
    setState(() {
      translatedText = '';
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 100), // Decreased duration for faster rotation
    );
    const Text('Show Dialog');
    GdprDialog.instance.resetDecision();
    GdprDialog.instance
        .showDialog(isForTest: false, testDeviceId: '')
        .then((onValue) {
      setState(() {
        status = 'dialog result == $onValue';
      });
    });
    InterstitialAdScreenState.initInterstitialAd();
    initBannerAd();
  }

  void _toggleIconRotation() {
    if (!_animationController!.isAnimating) {
      _animationController!.forward(from: 0.0).then((_) {
        setState(() {
          currentLanguageIndex = (currentLanguageIndex + 1) % languages.length;
        });
      });
    }
  }

  void _onContainerTap() {
    _toggleIconRotation();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: textController.text));
  }

  void _copyToClipboardForSpanish() {
    Clipboard.setData(ClipboardData(text: translatedText));
  }

  void _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        textController.text = data.text!;
        translate();
      });
    }
  }

  FlutterTts flutterTts = FlutterTts();

  Future<void> _textToEnglishSpeech() async {
    flutterTts.setLanguage('en');
    await flutterTts.speak(textController.text);
  }

  Future<void> _textToSpanishSpeech() async {
    flutterTts.setLanguage('es');
    await flutterTts.speak(translatedText);
  }

  String status = 'none';
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  //var adUnit = 'ca-app-pub-3940256099942544/6300978111';

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
        if (kDebugMode) {
          print(error);
        }
      }),
      request: const AdRequest(),
    );
    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: buildAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            var h = constraints.maxHeight;
            var w = constraints.maxWidth;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    height: h * 0.43,
                    width: w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 0,
                            blurRadius: 5,
                            offset: Offset(0, 0),
                          )
                        ],
                        borderRadius: BorderRadius.circular(7)),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: w * .7,
                                child: TextFormField(
                                  autofocus: false,
                                  maxLines: null,
                                  scrollPhysics: const AlwaysScrollableScrollPhysics(),
                                  controller: textController,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText:
                                        "Enter text in ${languages[(currentLanguageIndex) % languages.length]} or click on mic",
                                    hintStyle: const TextStyle(
                                      overflow: TextOverflow.visible,
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 7, left: 30),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (textController.text.isEmpty) {
                                          Utils.toastMesg(
                                              "Please Enter the text");
                                        } else {
                                          Utils.toastMesg('Reading text...');
                                          _textToEnglishSpeech();
                                        }
                                        if (InterstitialAdScreenState
                                            .isInAdLoaded) {
                                          await InterstitialAdScreenState
                                              .interstitialAd
                                              .show();
                                        }
                                      },
                                      child: const Icon(
                                        Icons.volume_up,
                                        size: 35,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(
                                      height: h * 0.02,
                                    ),
                                    InkWell(
                                      onTap: () async{
                                        if (textController.text.isEmpty) {
                                          Utils.toastMesg(
                                              'please enter the text');
                                        } else {
                                          Utils.toastMesg(
                                              "Copied text to clipboard");
                                          _copyToClipboard();
                                        }
                                        if (InterstitialAdScreenState
                                            .isInAdLoaded) {
                                          await InterstitialAdScreenState
                                              .interstitialAd
                                              .show();
                                        }
                                      },
                                      child: const Icon(
                                        Icons.content_copy,
                                        size: 35,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(
                                      height: h * 0.02,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        if (textController.text.isNotEmpty) {
                                          Utils.toastMesg('clear');
                                          textController.clear();
                                          _clearTranslatedText();
                                        } else if (textController
                                            .text.isEmpty) {
                                          Utils.toastMesg(
                                              'There is no text to clear');
                                        }
                                        if (InterstitialAdScreenState
                                            .isInAdLoaded) {
                                          await InterstitialAdScreenState
                                              .interstitialAd
                                              .show();
                                        }
                                      },
                                      child: const Icon(
                                        FontAwesomeIcons.xmark,
                                        size: 35,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: h * 0.09,
                          color: Colors.white,
                          child: Row(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Button(
                                  title: 'Paste',
                                  onPress: () async {
                                    _pasteFromClipboard();
                                    Utils.toastMesg('Translating...');
                                    if (InterstitialAdScreenState
                                        .isInAdLoaded) {
                                      await InterstitialAdScreenState
                                          .interstitialAd
                                          .show();
                                    }
                                  }),
                              AvatarGlow(
                                endRadius: 40,
                                animate: isListening,
                                duration: const Duration(seconds: 3),
                                glowColor: Colors.blue,
                                repeat: true,
                                showTwoGlows: false,
                                repeatPauseDuration:
                                    const Duration(milliseconds: 100),
                                child: GestureDetector(
                                  onTap: () {
                                    toggleRecording(
                                      onResult: (result) => setState(
                                        () => textController.text = result,
                                      ),
                                      onListening: (isListening) async {
                                        setState(() =>
                                            this.isListening = isListening);

                                        if (InterstitialAdScreenState
                                            .isInAdLoaded) {
                                          await InterstitialAdScreenState
                                              .interstitialAd
                                              .show();
                                        }
                                      },
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isListening
                                        ? Colors.green
                                        : Colors.blue,
                                    child: Icon(
                                      isListening
                                          ? Icons.mic
                                          : Icons.mic_none_outlined,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                              Button(
                                  title: 'Translate',
                                  onPress: () async {
                                    if (textController.text.isEmpty) {
                                      Utils.toastMesg("Enter the text");
                                    } else {
                                      Utils.toastMesg('Translating...');
                                      translate();
                                    }
                                    if (InterstitialAdScreenState
                                        .isInAdLoaded) {
                                      await InterstitialAdScreenState
                                          .interstitialAd
                                          .show();
                                    }
                                  })
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration:
                      const BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 5,
                      spreadRadius: 0,
                      offset: Offset(0, 0),
                    )
                  ]),
                  height: 70,
                  width: double.infinity,
                  child: isAdLoaded
                      ? SizedBox(
                          height: bannerAd.size.height.toDouble(),
                          width: bannerAd.size.width.toDouble(),
                          child: AdWidget(ad: bannerAd))
                      : const SizedBox(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      height: h * 0.5,
                      width: w,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 0,
                              blurRadius: 5,
                              offset: Offset(0, 0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(7)),
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(9.0),
                                      child: Text(
                                        textController.text.isEmpty
                                            ? "Translated text in ${languages[(currentLanguageIndex - 1) % languages.length]}"
                                            : translatedText,
                                        style: TextStyle(
                                          color: textController.text.isEmpty
                                              ? Colors.grey
                                              : Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: h * 0.09,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      if (translatedText.isEmpty) {
                                        Utils.toastMesg("There is no text");
                                      } else {
                                        Utils.toastMesg('reading text');
                                        _textToSpanishSpeech();
                                      }
                                      if (InterstitialAdScreenState
                                          .isInAdLoaded) {
                                        await InterstitialAdScreenState
                                            .interstitialAd
                                            .show();
                                      }
                                    },
                                    child: const Icon(
                                      Icons.volume_up,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async{
                                      if (translatedText.isEmpty) {
                                        Utils.toastMesg(
                                            "There is no text to share");
                                      } else {
                                        shareSpanishText();
                                      }
                                      if (InterstitialAdScreenState
                                          .isInAdLoaded) {
                                        await InterstitialAdScreenState
                                            .interstitialAd
                                            .show();
                                      }
                                    },
                                    child: const Icon(
                                      Icons.share,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async{
                                      if (translatedText.isEmpty) {
                                        Utils.toastMesg("There is no text");
                                      } else {
                                        _shareDirectToWhatsapp();
                                      }
                                      if (InterstitialAdScreenState
                                          .isInAdLoaded) {
                                        await InterstitialAdScreenState
                                            .interstitialAd
                                            .show();
                                      }
                                    },
                                    child: const Icon(
                                      FontAwesomeIcons.whatsapp,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async{
                                      if (translatedText.isEmpty) {
                                        Utils.toastMesg("There is no text");
                                      } else {
                                        _copyToClipboardForSpanish();
                                        Utils.toastMesg(
                                            'Copied text to clipboard');
                                      }
                                      if (InterstitialAdScreenState
                                          .isInAdLoaded) {
                                        await InterstitialAdScreenState
                                            .interstitialAd
                                            .show();
                                      }
                                    },
                                    child: const Icon(
                                      Icons.content_copy,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      if (favouriteItems.contains(FavouriteItem(
                                          engText: textController.text,
                                          spaText: translatedText))) {
                                        favouriteItems.remove(FavouriteItem(
                                            engText: textController.text,
                                            spaText: translatedText));
                                      } else {
                                        favouriteItems.add(
                                          FavouriteItem(
                                              engText: textController.text,
                                              spaText: translatedText),
                                        );
                                        if (translatedText.isEmpty) {
                                          Utils.toastMesg("There is no text");
                                        } else {
                                          Utils.toastMesg(
                                              "Added to favourite screen");
                                        }
                                        if (InterstitialAdScreenState
                                            .isInAdLoaded) {
                                          await InterstitialAdScreenState
                                              .interstitialAd
                                              .show();
                                        }
                                      }
                                    },
                                    child: const Icon(
                                      Icons.favorite_border,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async{
                                      if (translatedText.isNotEmpty) {
                                        Utils.toastMesg("clear");
                                        _clearTranslatedText();
                                      } else if (translatedText.isEmpty) {
                                        Utils.toastMesg('There is no text');
                                      }
                                      if (InterstitialAdScreenState
                                          .isInAdLoaded) {
                                        await InterstitialAdScreenState
                                            .interstitialAd
                                            .show();
                                      }
                                    },
                                    child: const Icon(
                                      FontAwesomeIcons.xmark,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        drawer: DrawerScreen(
            translationHistory: translationHistory,
            favouriteItems: favouriteItems),
      ),
    );
  }

  AppBar buildAppBar() {
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.blueAccent,
      actions: [
        Row(
          children: [
            Text(
              languages[currentLanguageIndex], // Use the current language
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            SizedBox(width: width * 0.10),
            GestureDetector(
              onTap: _onContainerTap,
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(
                  CurvedAnimation(
                    parent: _animationController!,
                    curve: Curves.linear,
                  ),
                ),
                child: Container(
                  height: height * .045,
                  width: width * .11,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(width: 2, color: Colors.white),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.arrowRightArrowLeft,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.09),
            Text(
              languages[(currentLanguageIndex + 1) %
                  languages.length], // Use the next language
              style: const TextStyle(fontSize: 17, fontWeight:  FontWeight.w600, color: Colors.white),
            ),
            SizedBox(width: width * .15),
          ],
        )
      ],
    );
  }
}
