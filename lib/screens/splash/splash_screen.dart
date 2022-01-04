import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/routes.dart';
import 'package:wean_app/common/screenConfig.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLogin = false;
  bool isNewUser = false;

  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    getFirebaseUser();
    super.initState();
    moveToLogin();
  }

  getFirebaseUser() async {
    if (_user != null) {
      // print("uuid ${_user!.uid}");
      // print("email ${_user!.email}");
    }
    setState(() {
      if (_user == null) {
        isLogin = false;
      } else {
        isLogin = true;
        if (_user!.email == null || _user!.displayName == null) {
          isNewUser = true;
        } else {
          isNewUser = false;
        }
      }
    });
  }

  void moveToLogin() {
    Timer(Duration(seconds: 1), () {
      // if (isLogin && isNewUser) {
      //   Navigator.of(context).pushNamedAndRemoveUntil(
      //       userDetail, (Route<dynamic> route) => false,
      //       arguments: [_user, FirebaseFirestore.instance]);
      // } else if (isLogin && !isNewUser) {
      //   Navigator.of(context)
      //       .pushNamedAndRemoveUntil(home, (Route<dynamic> route) => false);
      // } else {
      //   Navigator.of(context).pushReplacementNamed(login);
      // }
      if (isLogin) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(home, (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushReplacementNamed(login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        color: AppTheme.white,
        child: Center(
          child: Image.asset('assets/waen_bglogo.png'),
        ),
      ),
    );
  }
}
