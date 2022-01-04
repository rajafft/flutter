import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wean_app/models/chatModel.dart';
import 'package:wean_app/models/productModel.dart';
import 'package:wean_app/models/yardItemModel.dart';
import 'package:wean_app/screens/ask/ask_screen.dart';
import 'package:wean_app/screens/chat/chat_screen.dart';
import 'package:wean_app/screens/history/productDetailsScreen.dart';
import 'package:wean_app/screens/landing/home_screen.dart';
import 'package:wean_app/screens/login/login.dart';
import 'package:wean_app/screens/login/otp_screen.dart';
import 'package:wean_app/screens/login/user_details.dart';
import 'package:wean_app/screens/signup/signup.dart';
import 'package:wean_app/screens/splash/splash_screen.dart';
import 'package:wean_app/screens/yard/cityFilter.dart';
import 'package:wean_app/screens/yard/yardInfoScreen.dart';

class RouteFinding{
  Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){
      case splashScreen:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen(setIndex: 0,));
      case otpScreen:
        return MaterialPageRoute(builder: (_)=> OtpUI());
      case order:
        final item = settings.arguments as ProductModel?;
        return MaterialPageRoute(builder: (_) => OrderScreen(item: item,));
      case yardDetail:
        final item = settings.arguments as YardItemInfo;
        return MaterialPageRoute(builder: (_) => YardInfoScreen(item: item));
      case cityFilter:
        final items = settings.arguments as List<String>?;
        return MaterialPageRoute(builder: (_) => CityFilter(cities: items!,));
      case productDetail:
        final item = settings.arguments as ProductModel;
        return MaterialPageRoute(builder: (_) => ProductDetailsUI(item: item));
      case chatView:
        final item = settings.arguments as ChatModel;
        return MaterialPageRoute(builder: (_) => ChatScreen(model: item));
      case userDetail:
        List item = settings.arguments as List;
        return MaterialPageRoute(builder:(_) => UserDetails(user: item[0], firestore: item[1],));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

const splashScreen = '/';
const login = '/login';
const signup = '/signup';
const home = '/home';
const otpScreen = "/otpscreen";
const order = "/order";
const cityFilter = "/cityFilter";
const yardDetail = "/yardDetail";
const productDetail = "/productDetail";
const chatView = '/chatView';
const userDetail = "/userDetal";
const productChatView = "/productChatView";
