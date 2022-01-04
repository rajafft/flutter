import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';

// ignore: implementation_imports
import 'package:easy_localization/src/public_ext.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:wean_app/services/firebaseServices.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/widgets/textViews.dart';

import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/routes.dart';
import 'package:wean_app/common/screenConfig.dart';
import 'package:wean_app/common/toastUtils.dart';
import 'package:wean_app/widgets/decorations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String otpCode = '';
  String countryCode = '+966';
  TextEditingController address = TextEditingController();
  TextEditingController email = TextEditingController();
  File? image;
  bool isCodeSend = false;

  // late ProgressDialog _progressDialog;

  bool isLoading = false;

  bool isResend = true;
  TextEditingController name = TextEditingController();
  String phoneNumber = '';
  int? resendToken;
  var url;
  String verifyId = '';

  final TextEditingController _phoneController = TextEditingController();
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  String userSelectedCountry = 'Saudi Arabia';
  late SharedPreferences _prefs;
  bool agreeTerms = false;

  @override
  void initState() {
    loadPrefs();
    super.initState();
  }

  loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  dismissProgress() {
    if (isLoading) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loginUser(String phone) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: countryCode + phone,
      timeout: Duration(seconds: 60),
      verificationCompleted: (AuthCredential credential) async {
        // print("verificationComplete onLogin");
      },
      verificationFailed: (FirebaseAuthException exception) {
        // print("authException $exception");
        Toast.showError(exception.message.toString());
        dismissProgress();
      },
      codeSent: (String verificationID, [int? forceResendingToken]) {
        verifyId = verificationID;
        dismissProgress();
        // setState(() {
        //   isCodeSend = true;
        // });
        otpPopup(countryCode + phone);
        if (forceResendingToken != null) {
          resendToken = forceResendingToken;
        }
      },
      codeAutoRetrievalTimeout: (String timeOut) {
        verifyId = timeOut;
        dismissProgress();
      },
    );
  }

  moveToNextScreen(context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(home, (Route<dynamic> route) => false);
  }

  Future<void> resendCode(String phone) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 60),
      verificationCompleted: (AuthCredential credential) {
        // print("verificationComplete onResend");
      },
      verificationFailed: (FirebaseAuthException exception) {
        // print("authException $exception");
        Toast.showError(LocaleKeys.failed_auth.tr());
        dismissProgress();
      },
      codeSent: (String verificationID, [int? forceResendingToken]) {
        verifyId = verificationID;
        dismissProgress();
        setState(() {
          isCodeSend = true;
        });
        if (forceResendingToken != null) {
          resendToken = forceResendingToken;
        }
      },
      codeAutoRetrievalTimeout: (String timeOut) {
        verifyId = timeOut;
      },
    );
  }

  showProgress() {
    setState(() {
      isLoading = true;
    });
  }

  Future<void> verifyOTP(
      String smsCode, String verificationId, BuildContext context) async {
    // print("smsCode $smsCode");
    // print("vCode $verificationId");
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      final userCredentail =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredentail.user;
      var isNew = userCredentail.additionalUserInfo!.isNewUser;
      if (user != null) {
        if (isNew) {
          String displayId = "User-${Uuid().v4().substring(0, 8)}";
          user.updateDisplayName(displayId);
          await submitEmptyUserDetails(user, displayId);
          FirebaseAuth.instance.currentUser!.updateDisplayName(displayId);
          dismissProgress();
          moveToNextScreen(context);
        } else {
          dismissProgress();
          moveToNextScreen(context);
        }
      } else {
        Toast.showError(LocaleKeys.failed_auth.tr());
        dismissProgress();
      }
    } catch (e) {
      // print("OTP error");
      // print(e);
      Toast.showError(LocaleKeys.wrong_otp.tr());
      dismissProgress();
    }
  }

  Future<void> submitEmptyUserDetails(User user, String displayId) async {
    var fcmToken = await FirebaseMessaging.instance.getToken();
    var faker = Faker.instance;
    _prefs.setString('city', 'All');
    await FirebaseDBServices().addEmptyDetails(data: {
      "name": displayId,
      "phone": user.phoneNumber,
      "email":
          "${faker.name.lastName()}${faker.name.firstName()}${faker.name.middleName()}@gmail.com",
      "address": faker.address.streetAddress(),
      "items": [],
      "FCM Tokens": [fcmToken],
      "photo_url":
          "https://firebasestorage.googleapis.com/v0/b/waen-f0eb7.appspot.com/o/static_images%2Fprofile_ph.jpeg?alt=media&token=c7498bbe-e49c-4cd9-890a-f9685d8e0af9",
      "ratings": [],
      "rating": 5,
      "uuid": user.uid,
      "selectedCategory": [],
      "selectedCountry": userSelectedCountry,
      "selectedLanguage": 'English',
      "showYardNotification": false,
      "showChatNotification": false,
    }, uid: user.uid);
  }

  otpPopup(String phone) {
    _pinPutController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/otp_lock.png'),
              SizedBox(
                height: 15,
              ),
              Text(
                LocaleKeys.otp_verification.tr(),
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                LocaleKeys.enter_otp_to.tr() + phone,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              PinPut(
                withCursor: false,
                fieldsCount: 6,
                autofocus: false,
                fieldsAlignment: MainAxisAlignment.spaceAround,
                textStyle: const TextStyle(fontSize: 25.0, color: Colors.black),
                eachFieldMargin: EdgeInsets.all(0),
                eachFieldWidth: 25.0,
                eachFieldHeight: 35.0,
                onSubmit: (String pin) async {
                  setState(() {
                    otpCode = pin;
                  });
                  showProgress();
                },
                focusNode: _pinPutFocusNode,
                controller: _pinPutController,
                submittedFieldDecoration: pinDecoration,
                selectedFieldDecoration: pinDecoration,
                followingFieldDecoration: pinDecoration,
                pinAnimationType: PinAnimationType.scale,
                obscureText: '●',
              ),
              SizedBox(
                height: 30,
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    AppTheme.primaryColor,
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () async {
                  await verifyOTP(otpCode, verifyId, context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 5,
                  ),
                  child: Text(
                    LocaleKeys.verify.tr(),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primaryStartColor,
                ),
                child: Center(
                  child: TextAppName(),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 80,
                  bottom: kBottomNavigationBarHeight,
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: isLoading
                          ? SizedBox(
                              height: SizeConfig.screenHeight - 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: AppTheme.layoutBg,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Text(
                                    LocaleKeys.enter_mobile.tr(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    LocaleKeys.enter_mobile_to_login.tr(),
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 100,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50),
                                    child: TextFormField(
                                      controller: _phoneController,
                                      autofocus: false,
                                      keyboardType: TextInputType.phone,
                                      scrollPadding: const EdgeInsets.all(5),
                                      textInputAction: TextInputAction.done,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        prefixIcon: CountryCodePicker(
                                          onChanged: (code) {
                                            countryCode = code.dialCode!;
                                            userSelectedCountry = code.name!;
                                            // print(countryCode);
                                          },
                                          initialSelection: 'SA',
                                          countryList: const [
                                            {
                                              "name": "Saudi Arabia",
                                              "code": "SA",
                                              "dial_code": "+966",
                                            }
                                          ],
                                          showFlag: true,
                                          showCountryOnly: false,
                                          showOnlyCountryWhenClosed: false,
                                          alignLeft: false,
                                          textStyle: TextStyle(
                                            color: AppTheme.greyText,
                                            fontSize: 14,
                                          ),
                                        ),
                                        hintText: LocaleKeys.mobile_number.tr(),
                                        isDense: true,
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.amber),
                                        ),
                                        hintStyle: TextStyle(
                                          color: AppTheme.greyText,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Center(
                                    child: TextTitle(
                                      text:
                                          'Example: +96655xxxxxx Or +96650xxxxxx',
                                      textColor: Colors.grey.shade500,
                                      textSize: 12,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                              text: 'I agree ',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600),
                                              children: <InlineSpan>[
                                                TextSpan(
                                                    text: 'Terms & conditions',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.blue),
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () async {
                                                            await launch(
                                                                'https://waenapp.com/term-and-condition/');
                                                          }),
                                                TextSpan(
                                                  text: ' and ',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.grey.shade600),
                                                ),
                                                TextSpan(
                                                    text: 'Privacy Policy.',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.blue),
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () async {
                                                            await launch(
                                                                'https://waenapp.com/privacy-policy/');
                                                          }),
                                              ]),
                                        ),
                                        Switch(
                                          value: agreeTerms,
                                          onChanged: (value) {
                                            setState(() {
                                              agreeTerms = value;
                                            });
                                          },
                                          activeColor: Colors.amber,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        AppTheme.primaryColor,
                                      ),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      // setState(() {
                                      //   isCodeSend = true;
                                      // });
                                      //TODO: this should be handled better .. too many ifs
                                      if (_phoneController.text == '') {
                                        Toast.showError(
                                            LocaleKeys.please_enter_phone.tr());
                                        return;
                                      } else if (_phoneController.text.length <
                                          9) {
                                        Toast.showError(LocaleKeys
                                            .please_enter_valid_phone
                                            .tr());
                                        return;
                                      } else if (!agreeTerms) {
                                        Toast.showError(
                                            'Please accept terms & conditions.');
                                        return;
                                      }
                                      setState(() {
                                        phoneNumber = _phoneController.text;
                                      });
                                      FocusScopeNode currentFocus =
                                          FocusScope.of(context);
                                      if (!currentFocus.hasPrimaryFocus) {
                                        currentFocus.unfocus();
                                      }
                                      showProgress();
                                      await loginUser(_phoneController.text);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 100,
                                        vertical: 5,
                                      ),
                                      child: Text(
                                        LocaleKeys.send_otp.tr(),
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    )),
              ),
            ],
          ),
        ));
  }
}
