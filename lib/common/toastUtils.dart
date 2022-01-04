import 'package:flutter_easyloading/flutter_easyloading.dart';

class Toast{
  static showError(message){
    EasyLoading.showError(message, dismissOnTap: true, duration: Duration(seconds: 5),);
  }

  static showSuccess(message){
    EasyLoading.showSuccess(message, dismissOnTap: true, duration: Duration(seconds: 5));
  }

  static showInfo(message){
    EasyLoading.showToast(message, dismissOnTap: true, duration: Duration(seconds: 5));
  }
}