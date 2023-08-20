import 'package:english_to_spanish_translator/splash_service.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashService service = SplashService();
  @override
  void initState() {
    service.splash(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
