import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:wean_app/screens/camera/camera.dart';
import 'package:wean_app/screens/nav_bar/nav_bar.dart';
import 'package:wean_app/services/notification_services.dart';
import 'package:wean_app/translations/locale_keys.g.dart';

import 'package:wean_app/blocs/preferences/preferences_bloc.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/screenConfig.dart';
import 'package:wean_app/main.dart';
import 'package:wean_app/screens/chat/chat_mainscreen.dart';
import 'package:wean_app/screens/history/history_screen.dart';
import 'package:wean_app/screens/settings/settings.dart';
import 'package:wean_app/screens/yard/yard_screen.dart';

class HomeScreen extends StatefulWidget {
  final int setIndex;

  HomeScreen({required this.setIndex});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  int get _setIndex => widget.setIndex;
  DateTime? _lastQuitTime;
  List items = [
    YardScreen(),
    ChatMainScreen(),
    HistoryScreen(),
    SettingsScreen()
  ];

  @override
  void initState() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    getIt<NotificationServices>().setContext(context);
    getIt<NotificationServices>().foregroundNotificaitonStreamSubscription();
    getIt<NotificationServices>().backgroundNotification();
    if (_setIndex != null) {
      currentIndex = _setIndex;
    }
    super.initState();
  }

  promptPermissionSettingToRedirect(List<CameraDescription> cameras) async {
    var storageStatus = await Permission.storage.request();
    var cameraStatus = await Permission.camera.request();
    PermissionStatus? photoStatus;
    if (Platform.isIOS) photoStatus = await Permission.photos.request();
    // print("storageStatus $storageStatus");
    // print("cameraStatus $cameraStatus");
    // print("photoStatus $photoStatus");
    if (Platform.isAndroid &&
        storageStatus == PermissionStatus.granted &&
        cameraStatus == PermissionStatus.granted) {
      /// Getting Album lists from device
      List<Album> albums =
          await PhotoGallery.listAlbums(mediumType: MediumType.image);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => PhotoPicker(albums.first),
      //   ),
      // );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CameraScreen(
            cameras: cameras,
            album: albums.first,
          ),
        ),
      );
    } else if (Platform.isIOS) {
      List<Album> albums =
          await PhotoGallery.listAlbums(mediumType: MediumType.image);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => PhotoPicker(albums.first),
      //   ),
      // );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CameraScreen(
            cameras: cameras,
            album: albums.first,
          ),
        ),
      );
    }

    /*else if (Platform.isIOS &&
        storageStatus == PermissionStatus.granted &&
        photoStatus == PermissionStatus.granted &&
        cameraStatus == PermissionStatus.granted) {
      // Navigator.pushNamed(context, order, arguments: null);

      /// Getting Album lists from device
      List<Album> albums =
          await PhotoGallery.listAlbums(mediumType: MediumType.image);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PhotoPicker(albums.first),
        ),
      );
    }*/
    else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(LocaleKeys.required_permission.tr()),
            content: Text(
              LocaleKeys.please_grant_photos_permission.tr(),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  promptPermissionSettingToRedirect(cameras);
                },
                icon: Icon(Icons.check),
                label: Text(LocaleKeys.ok.tr()),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
                label: Text(LocaleKeys.close.tr()),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = MyInheritedWidget.of(context)!.camera;
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        if (_lastQuitTime == null ||
            DateTime.now().difference(_lastQuitTime!).inSeconds > 1) {
          // print(LocaleKeys.press_back_exit.tr());
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(LocaleKeys.press_back_exit.tr())));
          _lastQuitTime = DateTime.now();
          return false;
        } else {
          if (Platform.isIOS) {
            exit(0);
          } else {
            SystemNavigator.pop();
          }
          return true;
        }
      },
      child: Directionality( // add this
      textDirection: TextDirection.rtl, // set this property
      child:
      Scaffold(
        extendBody: true,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primaryColor,
          onPressed: () async {
            promptPermissionSettingToRedirect(camera);
          },
          elevation: 2,
          child: Icon(
            Icons.add,
            size: 25,
            color: AppTheme.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: 60,
            child: TopBorderNavBarEdit(
                currentIndex: currentIndex,
                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                    if (index == 3) {
                      BlocProvider.of<PreferencesBloc>(context)
                          .add(GetPreferences());
                    }
                  });
                },
                selectedItemColor: AppTheme.primaryColor,
                unselectedItemColor: Color.fromRGBO(0, 0, 0, 0.6),
                dotIndicatorColor: AppTheme.primaryColor,
                items: [
                  TopBorderNavBarItemEdit(
                    icon: currentIndex == 0
                        ? SizedBox(
                            width: 32,
                            child:
                                Center(child: Image.asset('assets/home.png')))
                        : SizedBox(
                            width: 32,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/svg/home0.svg',
                                color: currentIndex == 0
                                    ? AppTheme.primaryColor
                                    : Color.fromRGBO(0, 0, 0, 0.6),
                              ),
                              heightFactor: 50,
                            ),
                          ),
                  ),
                  TopBorderNavBarItemEdit(
                    icon: SizedBox(
                      width: 32,
                      child: Center(
                        child: currentIndex == 1
                            ? Image.asset('assets/message.png')
                            : SvgPicture.asset(
                                'assets/svg/message.svg',
                                color: Color.fromRGBO(0, 0, 0, 0.6),
                              ),
                        heightFactor: 50,
                      ),
                    ),
                  ),
                  TopBorderNavBarItemEdit(
                    icon: SizedBox(
                      width: 32,
                      child: Center(
                        child: currentIndex == 2
                            ? Image.asset('assets/clock.png')
                            : SvgPicture.asset(
                                'assets/svg/clock.svg',
                                color: Color.fromRGBO(0, 0, 0, 0.6),
                              ),
                        heightFactor: 50,
                      ),
                    ),
                  ),
                  TopBorderNavBarItemEdit(
                    icon: SizedBox(
                      width: 32,
                      child: Center(
                        child: currentIndex == 3
                            ? Image.asset('assets/filter.png')
                            : SvgPicture.asset(
                                'assets/svg/filter.svg',
                                color: Color.fromRGBO(0, 0, 0, 0.6),
                              ),
                        heightFactor: 50,
                      ),
                    ),
                  ),
                ]),
          ),
        ),
        body: items[currentIndex],
      ),
    ));
  }
}
