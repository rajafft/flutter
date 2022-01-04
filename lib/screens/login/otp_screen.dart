// ignore: implementation_imports
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:pinput/pin_put/pin_put.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/routes.dart';
import 'package:wean_app/common/screenConfig.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/widgets/appBars.dart';
import 'package:wean_app/widgets/decorations.dart';

class OtpUI extends StatefulWidget {
  const OtpUI({Key? key}) : super(key: key);

  @override
  _OtpUIState createState() => _OtpUIState();
}

class _OtpUIState extends State<OtpUI> {
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  Future<String> validateOtp(String otp) async {
    await Future.delayed(Duration(milliseconds: 2000));
    if (otp == "0000") {
      return "";
    } else {
      return "The entered Otp is wrong";
    }
  }

  void moveToNextScreen(context) {
    _pinPutFocusNode.unfocus();
    Navigator.of(context).pushReplacementNamed(home);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: appBarWithCenterText(context, LocaleKeys.verify_otp.tr()),
          ),
          body: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(6),
              color: AppTheme.layoutBg,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    LocaleKeys.enter_otp.tr(),
                    style: AppTheme.h1,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  PinPut(
                    withCursor: false,
                    fieldsCount: 4,
                    autofocus: false,
                    fieldsAlignment: MainAxisAlignment.spaceAround,
                    textStyle:
                        const TextStyle(fontSize: 25.0, color: Colors.black),
                    eachFieldMargin: EdgeInsets.all(0),
                    eachFieldWidth: 45.0,
                    eachFieldHeight: 55.0,
                    onSubmit: (String pin) => moveToNextScreen(context),
                    focusNode: _pinPutFocusNode,
                    controller: _pinPutController,
                    submittedFieldDecoration: pinDecoration,
                    selectedFieldDecoration: pinDecoration,
                    followingFieldDecoration: pinDecoration,
                    pinAnimationType: PinAnimationType.scale,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LocaleKeys.sms_not_received.tr(),
                        style: AppTheme.body1.copyWith(color: Colors.black),
                      ),
                      GestureDetector(
                          onTap: () {},
                          child: Text(
                            LocaleKeys.resend_otp.tr(),
                            style: AppTheme.body1
                                .copyWith(color: AppTheme.primaryColor),
                          ))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
