import 'dart:async';

import 'package:flutter/material.dart';

import 'home_screen.dart';


class SplashService{

  void splash(BuildContext context){
    Timer(const Duration(seconds: 1), () {
      Navigator.push(context,
          MaterialPageRoute(builder: (_)=>const HomeScreen()));
    });
  }
}