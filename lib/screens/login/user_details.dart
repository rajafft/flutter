import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wean_app/translations/locale_keys.g.dart';

import '../../blocs/user_details/user_details_bloc.dart';
import '../../common/appTheme.dart';
import '../../common/routes.dart';
import '../../common/toastUtils.dart';
import '../../widgets/textViews.dart';

class UserDetails extends StatefulWidget {
  UserDetails({this.user, this.firestore});

  final FirebaseFirestore? firestore;
  final User? user;

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  TextEditingController address = new TextEditingController();
  TextEditingController email = new TextEditingController();
  String? fcmToken;
  File? image;
  TextEditingController name = new TextEditingController();
  var url;

  @override
  void initState() {
    super.initState();
    getFcmToken();
  }

  _imgFromCamera() async {
    final pickedFile = await ImagePicker.platform.getImage(
      source: ImageSource.camera,
    );

    setState(() {
      image = File(pickedFile!.path);
    });
  }

  _imgFromGallery() async {
    final pickedFile = await ImagePicker.platform.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      image = File(pickedFile!.path);
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text(LocaleKeys.photo_library.tr()),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text(LocaleKeys.camera.tr()),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  bool validateFields() {
    if (name.text.isEmpty) {
      Toast.showError('Please enter the name.');
      return false;
    } else if (email.text.isEmpty) {
      Toast.showError('Please enter the email.');
      return false;
    } else if (address.text.isEmpty) {
      Toast.showError('Please enter the address.');
      return false;
    } else if (image == null) {
      Toast.showError('Please pick your profile picture.');
      return false;
    }
    return true;
  }

  void getFcmToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TextTitle(
            text: 'User Details',
            textColor: Colors.white,
            textSize: 18,
          ),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: BlocConsumer<UserDetailsBloc, UserDetailsState>(
          listener: (context, state) {
            if (state is UserDetailsSuccess) {
              Navigator.pushReplacementNamed(context, home);
            } else if (state is UserDetailsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Something went wrong")));
            }
          },
          builder: (context, state) {
            if (state is UserDetailsProgress) {
              return Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  AppTheme.primaryColor,
                ),
              ));
            } else {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      onTap: () {
                        _showPicker(context);
                      },
                      child: image != null
                          ? ClipOval(
                              child: Image.file(
                                image!,
                                fit: BoxFit.fill,
                                height: 100,
                                width: 100,
                              ),
                            )
                          : ClipOval(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(50)),
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                    ),
                    Container(
                      height: 50,
                      child: TextField(
                        controller: email,
                        decoration: InputDecoration(
                            hintText: "Enter email",
                            contentPadding: EdgeInsets.all(8),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 50,
                      child: TextField(
                        controller: name,
                        decoration: InputDecoration(
                            hintText: "Enter name",
                            contentPadding: EdgeInsets.all(8),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50,
                      child: TextField(
                        controller: address,
                        decoration: InputDecoration(
                            hintText: "Enter address",
                            contentPadding: EdgeInsets.all(8),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MaterialButton(
                        onPressed: () async {
                          if (validateFields()) {
                            /// TODO: Uncomment or update when necessary
                            /// refering to code in [yardInfoScreen.dart]
                            /// search for CreateConversation model class

                            // context
                            //     .read<UserDetailsBloc>()
                            //     .add(SubmitUserDetails(
                            //         image!,
                            //         {
                            //           "name": name.text,
                            //           "phone": widget.user!.phoneNumber,
                            //           "email": email.text,
                            //           "address": address.text,
                            //           "items": [],
                            //           "FCM Tokens": [fcmToken],
                            //           "rating": 5,
                            //           "uuid": widget.user!.uid,
                            //           "selectedCategory": [],
                            //           "selectedCountry": '',
                            //           "selectedLanguage": '',
                            //           "showYardNotification": false,
                            //           "showChatNotification": false,
                            //         },
                            //         widget.user!.uid));
                            // widget.user!.updateDisplayName(name.text);
                            // widget.user!.updateEmail(email.text);
                          }
                          // Navigator.pushReplacementNamed(context, home);
                        },
                        child: Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: AppTheme.primaryColor)
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
