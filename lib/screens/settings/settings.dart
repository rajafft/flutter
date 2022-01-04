import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wean_app/models/appPreferencesModel.dart';
import 'package:wean_app/screens/chat/feedback.dart';
import 'package:wean_app/screens/map/open_map.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/utils/util.dart';

import '../../blocs/preferences/preferences_bloc.dart';
import '../../common/appTheme.dart';
import '../../common/routes.dart';
import '../../common/screenConfig.dart';
import '../../common/toastUtils.dart';
import '../../models/userModel.dart';
import '../../services/cloud_storage_services.dart';
import '../../services/firebaseServices.dart';
import '../../services/firebase_messaging_services.dart';
import '../../services/image_picker_services.dart';
import '../../widgets/textViews.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? ProfileSource;
  List<CategoryCheckModel> categoriesList = [];
  CloudStorageServices cloudStorageServices = CloudStorageServices();
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool enableNotification = false;
  Faker faker = Faker.instance;
  FirebaseDBServices fbServices = FirebaseDBServices();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  File? image;
  bool isImageExists = false;
  bool isLoading = false;
  String? lastSelectedCategory;
  String? phone = FirebaseAuth.instance.currentUser!.phoneNumber;
  bool? showChatNotification;
  bool? showYardNotification;
  UserModel? user;
  Map<String, dynamic>? userMap;
  String userName = 'User';
  List<String>? userSelectedCategory;
  String? userSelectedCountry;
  String? userSelectedLanguage;
  String versionInfo = '1.0.0';
  late Future<UserModel> _userData;

  late PreferencesBloc _preferencesBloc;
  List<String> currentSelCategories = [];

  double ratingSum = 0.0;
  int ratingLength = 0;

  late AppPreferences preferences;

  String currentAddress = 'Pick from map';

  late SharedPreferences _prefs;

  @override
  void initState() {
    initBloc();
    super.initState();
  }

  pickImage() async {
    _prefs = await SharedPreferences.getInstance();
    ImagePickerServices pickerServices = ImagePickerServices();
    var file = await pickerServices.pickImage();
    if (file != null) {
      if (file.isNotEmpty) {
        setState(() {
          ProfileSource = File(file.first?.path ?? '');
        });
      }
      String imageUrl =
          await cloudStorageServices.uploadFile(ProfileSource ?? File(''));

      this.user?.photoUrl = imageUrl;
      await fbServices.updateBusinessCardInfo(user);
      ProfileSource = null;
      setState(() {});
    }
  }

  Future<UserModel> getUserData() async {
    QuerySnapshot snapshot = await firestore
        .collection('users')
        .where('uuid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    UserModel userModel = UserModel.fromSnapshot(snapshot);
    // print("got the userModel : " + userModel.email!);
    return userModel;
  }

  void signOut() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    FirebaseDBServices().updateFCMToken(
        _prefs.getString(FirebaseMessagingServices.FCM_TOKEN)!, false);
    await _prefs.remove(FirebaseMessagingServices.FCM_TOKEN);
    await _prefs.clear();
    await FirebaseAuth.instance.signOut();
    EasyLocalization.of(context)!.setLocale(Locale('en'));
    Toast.showInfo(LocaleKeys.please_login.tr());
    Navigator.of(context).pushNamedAndRemoveUntil(login, (route) => false);
  }

  initBloc() async {
    _preferencesBloc = BlocProvider.of<PreferencesBloc>(context);
    _preferencesBloc.add(GetPreferences());
    fbServices = FirebaseDBServices();
    user = await fbServices.loadBusinessCard();
    setState(() {
      _userData = getUserData();
    });
    // print("${user!.toJson()}");
    user!.selectedCountry!.isNotEmpty
        ? userSelectedCountry = user!.selectedCountry
        : userSelectedCountry = "";
    if (user!.selectedLanguage != null) {
      userSelectedLanguage = user!.selectedLanguage;
    }
    showYardNotification = user!.showYardNotification;
    showChatNotification = user!.showChatNotification;
    if (user!.address != null && user!.address!.isNotEmpty) {
      currentAddress = user!.address!;
    }
    lastSelectedCategory = user!.selectedCategory!.length == 0
        ? 'Select Categories'
        : user!.selectedCategory!.join(",");
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        versionInfo = "${value.version} Build ${value.buildNumber}";
      });
    });
    _prefs = await SharedPreferences.getInstance();
  }

  updateImage(BuildContext context, DocumentReference reference) {
    _showPicker(context, reference);
  }

  _imgFromCamera(context, DocumentReference reference) async {
    final pickedFile = await ImagePicker.platform
        .getImage(source: ImageSource.camera, imageQuality: 20);

    setState(() {
      image = File(pickedFile!.path);
    });

    String url = await cloudStorageServices.uploadFile(image!);
    currentUser!.updatePhotoURL(url);
    reference.update({'photo_url': url});
    setState(() {
      _userData = getUserData();
    });
  }

  _imgFromGallery(context, DocumentReference reference) async {
    final pickedFile = await ImagePicker.platform
        .getImage(source: ImageSource.gallery, imageQuality: 20);

    setState(() {
      image = File(pickedFile!.path);
    });
    String url = await cloudStorageServices.uploadFile(image!);
    currentUser!.updatePhotoURL(url);
    reference.update({'photo_url': url});
    setState(() {
      _userData = getUserData();
    });
  }

  void _showPicker(context, DocumentReference reference) {
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
                        _imgFromGallery(context, reference);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text(LocaleKeys.camera.tr()),
                    onTap: () {
                      _imgFromCamera(context, reference);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<bool> checkCategoryExist(String category) async {
    QuerySnapshot snapshot = await firestore
        .collection('users')
        .where('uuid', isEqualTo: currentUser!.uid)
        .where('selectedCategory', arrayContains: category)
        .get();
    if (snapshot.docs.length >= 1) {
      return true;
    }
    return false;
  }

  updateCategory(String category) async {
    bool isExist = await checkCategoryExist(category);
    if (!isExist) {
      // print("false");
      currentSelCategories.add(category);
      await firestore.collection('users').doc(currentUser!.uid).update({
        'selectedCategory': FieldValue.arrayUnion([category])
      });
    } else {
      // print("true");
      currentSelCategories.remove(category);
      await firestore.collection('users').doc(currentUser!.uid).update({
        'selectedCategory': FieldValue.arrayRemove([category])
      });
    }
    // print("cat ${currentSelCategories.join(",")}");
  }

  updateCountry(String country) async {
    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update({'selectedCountry': country});
    _prefs.setString('city', 'All');
  }

  updateAddress(String address) async {
    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update({'address': address});
  }

  updateLanguage(String language) async {
    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update({'selectedLanguage': language});
//get references, this help update the prefs state when language change
    _preferencesBloc.add(GetPreferences());
    if (language == 'English') {
      EasyLocalization.of(context)!.setLocale(Locale('en'));
    } else {
      EasyLocalization.of(context)!.setLocale(Locale('ar'));
    }
  }

  updateChatNotification(bool value) async {
    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update({'showChatNotification': value});
  }

  updateYardNotification(bool value) async {
    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update({'showYardNotification': value});
  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      callback();
    });
  }

  showLogoutAlert(context) {
    Widget cancelBtn = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: TextNormal(
          text: LocaleKeys.cancel.tr(),
          textColor: Colors.red,
        ));
    Widget okBtn = TextButton(
        onPressed: () {
          signOut();
          Navigator.pop(context);
        },
        child: TextNormal(
          text: LocaleKeys.ok.tr(),
          textColor: Colors.black,
        ));

    AlertDialog logoutAlert = AlertDialog(
      title: TextTitle(
        text: LocaleKeys.logout_confirmation.tr(),
      ),
      content: TextNormal(text: LocaleKeys.logout_confirmation_msg.tr()),
      actions: [okBtn, cancelBtn],
    );

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (
          BuildContext dlgContext,
        ) {
          return logoutAlert;
        });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      // backgroundColor: Colors.grey.shade200,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 100,
            alignment: Alignment.center,
            color: AppTheme.primaryStartColor,
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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: BlocBuilder<PreferencesBloc, PreferencesState>(
                  bloc: _preferencesBloc,
                  builder: (context, state) {
                    // print("currentState");
                    // print(state);

                    if (state is PreferencesLoading) {
                      isLoading = true;
                    } else if (state is PreferencesLoaded) {
                      categoriesList.clear();
                      ratingLength = state.ratingLength;
                      ratingSum = state.ratingSum;
                      preferences = state.preferences;
                      // print("len $ratingLength sum $ratingSum");
                      if (state.preferences.categories.isNotEmpty) {
                        state.preferences.categories.forEach((element) {
                          if (user!.selectedCategory!.contains(element)) {
                            categoriesList.add(CategoryCheckModel(
                                category: element, isChecked: true));
                            currentSelCategories.add(element);
                          } else {
                            categoriesList.add(CategoryCheckModel(
                                category: element, isChecked: false));
                          }
                        });
                        //mapping of user selected category to desired language. remove empty element, join the rest by comma
                        lastSelectedCategory =
                            user!.selectedCategory!.length == 0
                                ? 'select categories'
                                : user!.selectedCategory!
                                    .map((e) => translatedText(e, context))
                                    .where((element) => element != "")
                                    .join(",");
                      }
                      _preferencesBloc.add(PreferenceUpdateUI());
                    } else if (state is SettingsUIUpdated) {
                      if (isLoading) isLoading = false;
                    }
                    return isLoading
                        ? Container(
                            height: SizeConfig.screenHeight - 100,
                            alignment: Alignment.center,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(top: 10),
                            shrinkWrap: true,
                            children: [
                              //preferences
                              SizedBox(
                                height: 10,
                              ),
                              //preferences
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: SizeConfig.screenWidth - 20,
                                    padding:
                                        EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    child: Text(
                                      LocaleKeys.preferences.tr(),
                                      style: TextStyle(
                                        color: AppTheme.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  //interest category
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: InkWell(
                                      onTap: () async {
                                        await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return CategoriesDialog(
                                              category: categoriesList,
                                              user: user,
                                              selectedCategory:
                                                  (CategoryCheckModel
                                                      value) async {
                                                updateCategory(value.category);
                                              },
                                              updateCategory: () async {
                                                user = await fbServices
                                                    .loadBusinessCard();
                                                _preferencesBloc
                                                    .add(GetPreferences());
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  Color(0xFFF4F4F4),
                                              child: Image.asset(
                                                  'assets/list.png'),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  LocaleKeys.categories.tr(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: AppTheme.black,
                                                  ),
                                                ),
                                                Text(
                                                  lastSelectedCategory ?? '',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppTheme.greyText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              child: Icon(
                                                Icons
                                                    .keyboard_arrow_right_rounded,
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.38),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // DividerGrey(),
                                  //country
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: CircleAvatar(
                                            backgroundColor: Color(0xFFF4F4F4),
                                            child:
                                                Image.asset('assets/flag.png'),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: PopupMenuButton(
                                            onSelected: (String value) {
                                              // print('selected_country $value');
                                              setState(() {
                                                userSelectedCountry = value;
                                              });
                                              updateCountry(value);
                                            },
                                            itemBuilder: (context) {
                                              return preferences.countries
                                                  .map(
                                                    (e) =>
                                                        PopupMenuItem<String>(
                                                      child: Text(
                                                        translatedText(
                                                            e.name.toString(),
                                                            context),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              AppTheme.greyText,
                                                        ),
                                                      ),
                                                      value: e.name.toString(),
                                                    ),
                                                  )
                                                  .toList();
                                            },
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    LocaleKeys.country.tr(),
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: AppTheme.black,
                                                    ),
                                                  ),
                                                  Text(
                                                      userSelectedCountry !=
                                                                  null &&
                                                              userSelectedCountry!
                                                                  .isNotEmpty
                                                          ? translatedText(
                                                              userSelectedCountry!,
                                                              context)
                                                          : translatedText(
                                                              preferences
                                                                  .countries
                                                                  .first
                                                                  .name,
                                                              context),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            AppTheme.greyText,
                                                      )),
                                                ]),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons
                                                  .keyboard_arrow_right_rounded,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.38),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // DividerGrey(),
                                  //language
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: CircleAvatar(
                                            backgroundColor: Color(0xFFF4F4F4),
                                            child:
                                                Image.asset('assets/globe.png'),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: PopupMenuButton(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  LocaleKeys.language.tr(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: AppTheme.black,
                                                  ),
                                                ),
                                                Text(
                                                    userSelectedLanguage!
                                                            .isNotEmpty
                                                        ? userSelectedLanguage
                                                        : preferences
                                                            .languages.first,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: AppTheme.greyText,
                                                    )),
                                              ],
                                            ),
                                            onSelected: (String value) {
                                              setState(() {
                                                userSelectedLanguage = value;
                                              });
                                              updateLanguage(value);
                                            },
                                            itemBuilder: (context) {
                                              return preferences.languages
                                                  .map(
                                                    (e) =>
                                                        PopupMenuItem<String>(
                                                      child: Text(
                                                        e.toString(),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              AppTheme.greyText,
                                                        ),
                                                      ),
                                                      value: e.toString(),
                                                    ),
                                                  )
                                                  .toList();
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons
                                                  .keyboard_arrow_right_rounded,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.38),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // DividerGrey(),
                                  //yard notification
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       horizontal: 10, vertical: 5),
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       Expanded(
                                  //         flex: 2,
                                  //         child: CircleAvatar(
                                  //           backgroundColor: Color(0xFFF4F4F4),
                                  //           child:
                                  //               Image.asset('assets/bell.png'),
                                  //         ),
                                  //       ),
                                  //       Expanded(
                                  //         flex: 6,
                                  //         child: Text(
                                  //           'Yard Notifications',
                                  //           style: TextStyle(
                                  //             fontSize: 18,
                                  //             color: AppTheme.black,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       Switch(
                                  //         activeColor: AppTheme.primaryColor,
                                  //         value: showYardNotification ?? false,
                                  //         onChanged: (value) {
                                  //           setState(() {
                                  //             showYardNotification = value;
                                  //           });
                                  //           updateYardNotification(value);
                                  //         },
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  // DividerGrey(),
                                  //chat notification
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: CircleAvatar(
                                            backgroundColor: Color(0xFFF4F4F4),
                                            child:
                                                Image.asset('assets/bell.png'),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            LocaleKeys.chat_notification.tr(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: AppTheme.black,
                                            ),
                                          ),
                                        ),
                                        Switch(
                                            activeColor: AppTheme.primaryColor,
                                            value:
                                                showChatNotification ?? false,
                                            onChanged: (value) {
                                              setState(() {
                                                showChatNotification = value;
                                              });
                                              updateChatNotification(value);
                                            })
                                      ],
                                    ),
                                  ),
                                ],
                                mainAxisAlignment: MainAxisAlignment.end,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              //Business Card
                              FutureBuilder<UserModel>(
                                future: _userData,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                        AppTheme.primaryColor,
                                      ),
                                    ));
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      // print(snapshot.data!.email!);
                                      return Column(
                                        children: [
                                          Container(
                                            width: SizeConfig.screenWidth - 20,
                                            padding: EdgeInsets.fromLTRB(
                                                20, 10, 20, 10),
                                            child: Text(
                                              LocaleKeys.business_card.tr(),
                                              style: TextStyle(
                                                color: AppTheme.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          //profile pic
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    // pickImage();
                                                    updateImage(
                                                        context,
                                                        snapshot.data!
                                                            .documentReference!);
                                                  },
                                                  child: Card(
                                                    elevation: 2,
                                                    shape: CircleBorder(
                                                        side: BorderSide(
                                                      color: Colors.white,
                                                      width: 5,
                                                    )),
                                                    child: ClipOval(
                                                      child: snapshot.data!
                                                              .photoUrl!.isEmpty
                                                          ? Image.asset(
                                                              'assets/profile_ph.jpeg',
                                                              height: 80,
                                                              width: 80,
                                                            )
                                                          : Image.network(
                                                              snapshot.data!
                                                                  .photoUrl!,
                                                              fit: BoxFit.fill,
                                                              height: 80,
                                                              width: 80,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: InkWell(
                                                        onTap: () async {
                                                          await showDialog(
                                                            context: context,
                                                            builder: (ctx) =>
                                                                ProfileEditingDialog(
                                                              reference: snapshot
                                                                  .data!
                                                                  .documentReference,
                                                              value: snapshot
                                                                  .data!.name!,
                                                              type: 'Name',
                                                              user: this.user,
                                                            ),
                                                          ).then((value) => {
                                                                setState(() {
                                                                  _userData =
                                                                      getUserData();
                                                                }),
                                                              });
                                                        },
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              snapshot.data
                                                                      ?.name ??
                                                                  LocaleKeys
                                                                      .waen_user
                                                                      .tr(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontFamily:
                                                                      'avenir'),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            IgnorePointer(
                                                              child: RatingBar(
                                                                tapOnlyMode:
                                                                    true,
                                                                itemSize: 20,
                                                                ratingWidget:
                                                                    RatingWidget(
                                                                  full: Icon(
                                                                    Icons
                                                                        .star_rate_rounded,
                                                                    color: Colors
                                                                        .amber,
                                                                  ),
                                                                  half: Icon(
                                                                    Icons
                                                                        .star_half_rounded,
                                                                    color: Colors
                                                                        .amber,
                                                                  ),
                                                                  empty:
                                                                      SvgPicture
                                                                          .asset(
                                                                    'assets/svg/star.svg',
                                                                    width: 20,
                                                                    height: 20,
                                                                    fit: BoxFit
                                                                        .scaleDown,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0.6),
                                                                  ),
                                                                ),
                                                                onRatingUpdate:
                                                                    (value) {},
                                                                glow: false,
                                                                initialRating:
                                                                    ratingSum,
                                                                minRating: 1,
                                                                maxRating: 5,
                                                                allowHalfRating:
                                                                    true,
                                                                itemCount: 5,
                                                                itemPadding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            1.0),
                                                                direction: Axis
                                                                    .horizontal,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          //rating
                                          Visibility(
                                            visible: ratingLength > 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FeedbackScreen(
                                                      ownerId: user!.uuid!,
                                                      isProfile: false,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                color: Color.fromRGBO(
                                                    245, 188, 80, 0.1),
                                                margin: EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                height: 55,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Container(),
                                                    ),
                                                    // Spacer(),
                                                    Expanded(
                                                      child: Row(
                                                        // mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .star_rate_rounded,
                                                            color: Colors.amber,
                                                            size: 30,
                                                          ),
                                                          SizedBox(
                                                            width: 12,
                                                          ),
                                                          Text(
                                                            '${ratingSum.toStringAsFixed(1)}/5',
                                                            style: TextStyle(
                                                                fontSize: 24,
                                                                color: AppTheme
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            // softWrap: true,
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            LocaleKeys.based_on
                                                                    .tr() +
                                                                '$ratingLength' +
                                                                LocaleKeys
                                                                    .reviews
                                                                    .tr(),
                                                            // 'based on $ratingLength reviews ',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: AppTheme
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            // softWrap: true,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          //phone
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Color(0xFFF4F4F4),
                                                    child: Icon(
                                                      Icons.phone_outlined,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 6,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        LocaleKeys.phone.tr(),
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: AppTheme.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        currentUser!.phoneNumber !=
                                                                null
                                                            ? currentUser!
                                                                .phoneNumber!
                                                            : '',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              AppTheme.greyText,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          //mail
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Color(0xFFF4F4F4),
                                                    child: Icon(
                                                      Icons.mail_outline,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 6,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      await showDialog(
                                                        context: context,
                                                        builder: (ctx) =>
                                                            ProfileEditingDialog(
                                                          reference: snapshot
                                                              .data!
                                                              .documentReference,
                                                          value: snapshot
                                                              .data!.email!,
                                                          type: 'Email',
                                                          user: this.user,
                                                        ),
                                                      ).then((value) => {
                                                            setState(() {
                                                              _userData =
                                                                  getUserData();
                                                            }),
                                                          });
                                                    },
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          LocaleKeys.email.tr(),
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                AppTheme.black,
                                                          ),
                                                        ),
                                                        Text(
                                                          snapshot.data
                                                                  ?.email ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: AppTheme
                                                                .greyText,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          //address
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 20),
                                            child: InkWell(
                                              onTap: () async {
                                                var result =
                                                    await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                MapScreen()));
                                                if (result != null) {
                                                  updateAddress(result);
                                                }
                                                setState(() {
                                                  currentAddress = result;
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Color(0xFFF4F4F4),
                                                      child: Icon(
                                                        Icons.pin_drop_outlined,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    //TODO: follow this guide https://codelabs.developers.google.com/codelabs/google-maps-in-flutter/#0
                                                    flex: 6,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          LocaleKeys.address
                                                              .tr(),
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                AppTheme.black,
                                                          ),
                                                        ),
                                                        Text(
                                                          currentAddress,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: AppTheme
                                                                .greyText,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  CircleAvatar(
                                                    child: Image.asset(
                                                        'assets/target.png'),
                                                    backgroundColor:
                                                        Color(0xFFF5BC50)
                                                            .withOpacity(.1),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Center(
                                          child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                          AppTheme.primaryColor,
                                        ),
                                      ));
                                    }
                                  } else {
                                    return Center(
                                        child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                        AppTheme.primaryColor,
                                      ),
                                    ));
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: TextButton(
                                    onPressed: () {
                                      showLogoutAlert(context);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.power_settings_new,
                                          color: Color(0xffFF5656),
                                          size: 20,
                                        ),
                                        TextTitle(
                                          text: LocaleKeys.logout.tr(),
                                          textSize: 14,
                                          textColor: Color(0xffFF5656),
                                        ),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(255, 86, 86, 0.15),
                                      minimumSize:
                                          Size(SizeConfig.screenWidth - 30, 60),
                                    )),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              //version
                              Center(
                                child: TextTitle(
                                  text: 'Version $versionInfo',
                                  textColor: Colors.grey.shade500,
                                  textSize: 12,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                child: Text(
                                  LocaleKeys.want_delete_account.tr(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.black,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                                child: Text(
                                  LocaleKeys.GDRP_MSG.tr(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.black,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 100,
                              ),
                            ],
                          );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesDialog extends StatefulWidget {
  CategoriesDialog({
    required this.user,
    this.category,
    required this.selectedCategory,
    required this.updateCategory,
  });

  List<CategoryCheckModel>? category;
  final Function selectedCategory;
  final UserModel? user;
  final Function updateCategory;

  @override
  _CategoriesDialogState createState() => _CategoriesDialogState();
}

class _CategoriesDialogState extends State<CategoriesDialog> {
  String? selectedValue;

  Function get _selectedCategory => widget.selectedCategory;

  List<CategoryCheckModel> selected = [];

  @override
  void initState() {
    selected = widget.category!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: Text('Categories'),
      title: Center(
        child: TextTitle(
          text: LocaleKeys.categories.tr(),
          textSize: 18,
          textColor: AppTheme.primaryDarkColor,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.updateCategory();
            Navigator.of(context).pop();
          },
          child: TextTitle(
            text: LocaleKeys.UPDATE.tr(),
            textColor: AppTheme.primaryBColor,
          ),
        ),
      ],
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 400,
          minHeight: 100,
          maxWidth: 350,
          minWidth: 350,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              value: widget.category![index].isChecked,
              onChanged: (f) {
                setState(() {
                  widget.category![index].isChecked = f!;
                  selectedValue = widget.category![index].category;
                  _selectedCategory(widget.category![index]);
                });
              },
              checkColor: Colors.amber,
              title: TextNormal(
                text: translatedText(widget.category![index].category,
                    context), //translate user selected category to desired language
                textSize: 16,
                textColor: AppTheme.primaryDarkColor,
              ),
            );
          },
          itemCount: widget.category!.length,
        ),
      ),
    );
  }
}

class ProfileEditingDialog extends StatefulWidget {
  ProfileEditingDialog(
      {Key? key,
      required this.value,
      required this.type,
      required this.user,
      this.reference})
      : super(key: key);

  DocumentReference? reference;
  final String type;
  final UserModel? user;
  final String value;

  @override
  _ProfileEditingDialogState createState() => _ProfileEditingDialogState();
}

class _ProfileEditingDialogState extends State<ProfileEditingDialog> {
  late TextEditingController editingController;
  final fbServices = FirebaseDBServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    editingController = TextEditingController(
      text: widget.value,
    );
  }

  submitChanges() {
    var user = FirebaseAuth.instance.currentUser!;
    switch (widget.type) {
      case 'Name':
        widget.reference!.update({"name": editingController.text});
        user.updateDisplayName(editingController.text);
        FirebaseFirestore.instance
            .collection('conversations')
            .where('senderId', isEqualTo: user.uid)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            element.reference.update({"senderName": editingController.text});
          });
        });
        FirebaseFirestore.instance
            .collection('conversations')
            .where('ownerId', isEqualTo: user.uid)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            element.reference.update({"ownerName": editingController.text});
          });
        });
        break;
      case 'Email':
        widget.reference!.update({"email": editingController.text});
        user.updateEmail(editingController.text);
        break;
      case 'Phone':
        widget.user?.phone = editingController.text;
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocaleKeys.UPDATE.tr() + '${widget.type}'),
      content: TextField(
        controller: editingController,
        keyboardType:
            widget.type == 'Phone' ? TextInputType.phone : TextInputType.text,
      ),
      actions: [
        TextButton(
          child: Text(
            LocaleKeys.UPDATE.tr(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            submitChanges();
            //await fbServices.updateBusinessCardInfo(widget.user);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class CategoryCheckModel {
  CategoryCheckModel({required this.category, required this.isChecked});

  String category;
  bool isChecked;
}
