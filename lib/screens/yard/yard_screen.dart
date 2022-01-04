import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:group_button/group_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wean_app/blocs/cubit/yard_cubit.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/routes.dart';
import 'package:wean_app/common/screenConfig.dart';
import 'package:wean_app/models/appPreferencesModel.dart';
import 'package:wean_app/models/userModel.dart';
import 'package:wean_app/models/yardItemModel.dart';
import 'package:wean_app/services/firebaseServices.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/utils/util.dart';
import 'package:wean_app/widgets/listviews.dart';
import 'package:wean_app/widgets/others.dart';
import 'package:wean_app/widgets/textViews.dart';

import 'cityFilter.dart';

class YardScreen extends StatefulWidget {
  const YardScreen({Key? key}) : super(key: key);

  @override
  _YardScreenState createState() => _YardScreenState();
}

class _YardScreenState extends State<YardScreen> {
  List<YardItemModel> items = [];
  bool isListMode = true;

  FirebaseDBServices dbServices = FirebaseDBServices();

  List<String> categories = [];

  List<Country> countries = [];

  bool isFilterSelected = false;

  List<String> selectedCategories = [];

  List<int> indexes = [];

  late UserModel currentUser;

  List<String> cities = [];

  List<String> userSelectedCategory = [];

  late Country userSelectedCountry;

  String userCountry = '';

  String userSelectedCity = 'Select City';

  int lastSelectedCityIndex = 0;

  late SharedPreferences _prefs;

  @override
  void initState() {
    categories.add('All');
    loadServices();
    super.initState();
  }

  loadServices() async {
    currentUser =
        await dbServices.loadUser(FirebaseAuth.instance.currentUser!.uid);
    _prefs = await SharedPreferences.getInstance();
    AppPreferences preferences = await dbServices.loadPreferences();
    for (var element in preferences.categories) {
      setState(() {
        categories.add(element.toString());
      });
    }
    for (var element in preferences.countries) {
      setState(() {
        countries.add(element);
      });
    }
    userSelectedCategory = currentUser.selectedCategory!;
    setState(() {
      userCountry = currentUser.selectedCountry!;
    });
    for (int i = 0; i < countries.length; i++) {
      if (countries[i].name == currentUser.selectedCountry) {
        userSelectedCountry = countries[i];
        cities = countries[i].cities.cast<String>();
        break;
      }
    }
    for (int i = 0; i < categories.length; i++) {
      for (int j = 0; j < userSelectedCategory.length; j++) {
        if (categories[i] == userSelectedCategory[j]) {
          indexes.add(i);
        }
      }
    }

    cities.insert(0, 'All');

    if (_prefs.getString('city') == null ||
        _prefs.getString('city')!.isEmpty ||
        _prefs.getString('city') == 'All') {
      userSelectedCity = 'All';
      dbServices.loadYardBy(
          userSelectedCountry.name, userSelectedCategory, 'All');
    } else {
      userSelectedCity = _prefs.getString('city')!;
      dbServices.loadYardBy(
          userSelectedCountry.name, userSelectedCategory, userSelectedCity);
    }

    if (currentUser.selectedLanguage == null ||
        currentUser.selectedLanguage!.isEmpty) {
      EasyLocalization.of(context)!.setLocale(Locale('en'));
    } else {
      if (currentUser.selectedLanguage == 'English') {
        EasyLocalization.of(context)!.setLocale(Locale('en'));
      } else {
        EasyLocalization.of(context)!.setLocale(Locale('ar'));
      }
    }
    //
    // print("city $userSelectedCity");
    // print("prefCity ${_prefs.getString('city')}");
    // print("++ ${indexes.join(",")}");
    // print("index ${userSelectedCategory.join(",")}");
  }

  showFilter() async {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          bool isRadio = false;
          return AlertDialog(
            title: Center(
              child: TextTitle(
                text: LocaleKeys.filter.tr(),
                textSize: 18,
                textColor: AppTheme.black,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: TextTitle(
                  text: LocaleKeys.submit.tr(),
                  textColor: AppTheme.primaryDarkColor,
                  textSize: 16,
                ),
              ),
            ],
            content: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: SizeConfig.screenHeight / 1.6,
                  maxWidth: SizeConfig.screenWidth - 50),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextTitle(
                      text: LocaleKeys.by_city.tr(),
                      textSize: 14,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GroupButton(
                        buttons: cities,
                        groupingType: GroupingType.wrap,
                        selectedColor: AppTheme.primaryDarkColor,
                        unselectedColor: Colors.white,
                        selectedBorderColor: AppTheme.primaryDarkColor,
                        mainGroupAlignment: MainGroupAlignment.start,
                        unselectedBorderColor: Colors.grey[200],
                        isRadio: true,
                        selectedButton: lastSelectedCityIndex,
                        selectedTextStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        unselectedTextStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                        selectedShadow: const <BoxShadow>[
                          BoxShadow(color: Colors.transparent)
                        ],
                        unselectedShadow: const <BoxShadow>[
                          BoxShadow(color: Colors.transparent)
                        ],
                        spacing: 10,
                        onSelected: (index, isSelected) {
                          setState(() {
                            lastSelectedCityIndex = index;
                            userSelectedCity = cities[index];
                          });
                        }),
                    SizedBox(
                      height: 10,
                    ),
                    DividerGrey(),
                    SizedBox(
                      height: 10,
                    ),
                    TextTitle(
                      text: LocaleKeys.by_category.tr(),
                      textSize: 14,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GroupButton(
                        buttons: categories,
                        groupingType: GroupingType.wrap,
                        selectedColor: AppTheme.primaryDarkColor,
                        unselectedColor: Colors.white,
                        selectedBorderColor: AppTheme.primaryDarkColor,
                        mainGroupAlignment: MainGroupAlignment.start,
                        unselectedBorderColor: Colors.grey[200],
                        isRadio: isRadio,
                        selectedButtons: indexes,
                        selectedTextStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        unselectedTextStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                        selectedShadow: const <BoxShadow>[
                          BoxShadow(color: Colors.transparent)
                        ],
                        unselectedShadow: const <BoxShadow>[
                          BoxShadow(color: Colors.transparent)
                        ],
                        spacing: 10,
                        onSelected: (index, isSelected) {
                          if (index == 0 && isSelected) {
                            setState(() {
                              isRadio = true;
                            });
                            selectedCategories.clear();
                            indexes.clear();
                            selectedCategories.add(categories[index]);
                            indexes.add(index);
                          } else if (index == 0 && !isSelected) {
                            setState(() {
                              isRadio = false;
                            });
                            selectedCategories.clear();
                            indexes.clear();
                            selectedCategories.remove(categories[index]);
                            indexes.remove(index);
                          }

                          if (index != 0) {
                            setState(() {
                              isRadio = false;
                            });
                            if (selectedCategories.isEmpty) {
                              selectedCategories.add(categories[index]);
                              indexes.add(index);
                            } else {
                              if (selectedCategories.contains('All')) {
                                selectedCategories.removeAt(0);
                                indexes.removeAt(0);
                              }

                              if (selectedCategories
                                  .contains(categories[index])) {
                                selectedCategories.remove(categories[index]);
                                indexes.remove(index);
                              } else {
                                selectedCategories.add(categories[index]);
                                indexes.add(index);
                              }
                            }
                          }
                        }),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          //appbar
          Container(
            height: 100,
            // color: AppTheme.primaryBColor,

            padding: const EdgeInsets.only(),
            color: AppTheme.primaryStartColor,
            child: Center(
              child: TextAppName(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 25),
            child: Align(
              alignment: Alignment.topRight,
              child: BlocBuilder<YardCubit, YardState>(
                builder: (context, state) {
                  return IconButton(
                    tooltip: state is YardList ? 'Grid mode' : 'List mode',
                    onPressed: () {
                      BlocProvider.of<YardCubit>(context).toggleYardMode();
                    },
                    icon: state is YardList
                        ? SizedBox(
                            width: 32,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/svg/grid.svg',
                                color: AppTheme.white,
                              ),
                              heightFactor: 50,
                            ),
                          ) //assets/svg/list.svg
                        : SizedBox(
                            width: 32,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/svg/list.svg',
                                color: AppTheme.white,
                              ),
                              heightFactor: 50,
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            bottom: kBottomNavigationBarHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                width: SizeConfig.screenWidth,
                height: SizeConfig.screenHeight,
                child: Column(
                  children: [
                    Container(
                      child: GestureDetector(
                        onTap: () async {
                          var selectedCity = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CityFilter(cities: cities)));
                          if (selectedCity != null) {
                            // filter.
                            dbServices.loadYardBy(userSelectedCountry.name,
                                userSelectedCategory, selectedCity);
                            setState(() {
                              isFilterSelected = true;
                              userSelectedCity = selectedCity;
                            });
                            _prefs.setString('city', selectedCity);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppTheme.primaryDarkColor,
                                  size: 24,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: TextNormal(
                                    text: translatedText(
                                        userSelectedCity, context),
                                    textSize: 12,
                                    textColor: AppTheme.warmGrey,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  Icon(
                                    Icons.my_location,
                                    color: AppTheme.primaryDarkColor,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      width: SizeConfig.screenWidth,
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      margin: EdgeInsets.all(5.0),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: BlocBuilder<YardCubit, YardState>(
                        builder: (context, state) {
                          return StreamBuilder<QuerySnapshot?>(
                            stream: dbServices.yardDataStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  snapshot.connectionState ==
                                      ConnectionState.none) {
                                return SizedBox(
                                  height: 400,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                        AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return SizedBox(
                                    height: 300,
                                    child: Center(
                                        child: Column(
                                      children: [
                                        TextNormal(
                                            text: LocaleKeys.something_wrong
                                                .tr()),
                                      ],
                                    )));
                              }

                              if (snapshot.connectionState ==
                                      ConnectionState.active ||
                                  snapshot.connectionState ==
                                      ConnectionState.done) {
                                if (snapshot.data == null ||
                                    snapshot.data?.size == 0) {
                                  return Container(
                                    height: 500,
                                    padding: EdgeInsets.only(left: 8, right: 8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        TextNormal(
                                            text: LocaleKeys.stay_tuned.tr()),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Visibility(
                                          visible: isFilterSelected,
                                          child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  isFilterSelected = false;
                                                  selectedCategories.clear();
                                                  indexes.clear();
                                                  userSelectedCity = 'All';
                                                });
                                                _prefs.setString('city', 'All');
                                                dbServices.loadYardBy(
                                                    userSelectedCountry.name,
                                                    userSelectedCategory,
                                                    'All');
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .arrow_back_ios_outlined,
                                                    color: AppTheme
                                                        .primaryDarkColor,
                                                  ),
                                                  TextTitle(
                                                    text:
                                                        LocaleKeys.go_back.tr(),
                                                    textColor: AppTheme
                                                        .primaryDarkColor,
                                                  ),
                                                ],
                                              )),
                                        ),
                                        Image.asset(
                                          "assets/camel_img.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }

                              return state is YardList
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                      child: ListView.separated(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7),
                                        separatorBuilder: (context, index) {
                                          return Divider(
                                            color: Color(0xffEDEDED),
                                            endIndent: 20,
                                            indent: 20,
                                            thickness: 2,
                                          );
                                        },
                                        itemBuilder: (context, index) {
                                          var jsonData =
                                              snapshot.data?.docs[index];
                                          String? indexId =
                                              snapshot.data?.docs[index].id;
                                          YardItem product =
                                              YardItem.fromSnapshot(jsonData!);
                                          return ListYardItems(
                                            item: product,
                                            isHistory: false,
                                            indexID: indexId,
                                          );
                                        },
                                        itemCount: snapshot.data!.docs.length,
                                        shrinkWrap: true,
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 1, vertical: 1),
                                      child: ClipRRect(
                                        child: GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 0,
                                            mainAxisSpacing: 0,
                                          ),
                                          itemBuilder: (context, index) {
                                            var jsonData =
                                                snapshot.data?.docs[index];
                                            YardItem product =
                                                YardItem.fromSnapshot(
                                                    jsonData!);
                                            return InkWell(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    yardDetail,
                                                    arguments: YardItemInfo(
                                                        item: product,
                                                        isHistory: true),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white)),
                                                  child: Stack(
                                                    children: [
                                                      SizedBox(
                                                          height: SizeConfig
                                                                  .screenWidth /
                                                              2.5,
                                                          width: SizeConfig
                                                                  .screenWidth /
                                                              3,
                                                          child: FadeInImage
                                                              .assetNetwork(
                                                            placeholder:
                                                                'assets/placeholder.jpeg',
                                                            imageErrorBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    Object obj,
                                                                    StackTrace?
                                                                        trace) {
                                                              return Image
                                                                  .asset(
                                                                "assets/placeholder.jpeg",
                                                              );
                                                            },
                                                            image: product.media
                                                                    .isNotEmpty
                                                                ? product
                                                                    .media.first
                                                                : "https://firebasestorage.googleapis.com/v0/b/waen-f0eb7.appspot.com/o/items%2Fwaen_logo.png?alt=media&token=0f3b5b44-abee-426c-ac1a-4cdb68de2b6f",
                                                            fit: BoxFit.cover,
                                                          )),
                                                      product.is_auction
                                                          ? Container(
                                                              width: 18,
                                                              height: 18,
                                                              margin: EdgeInsets
                                                                  .all(10),
                                                              child: Image.asset(
                                                                  'assets/auction_indicator.png'),
                                                            )
                                                          : Container()
                                                    ],
                                                  ),
                                                ));
                                          },
                                          itemCount: snapshot.data?.docs.length,
                                          shrinkWrap: true,
                                        ),
                                      ),
                                    );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
