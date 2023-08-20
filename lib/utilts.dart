
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils{
  static toastMesg(String mesg){
    Fluttertoast.showToast(
        msg: mesg,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 15,

    );

  }
}
