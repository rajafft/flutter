import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/screenConfig.dart';
import 'package:wean_app/models/ratingsModel.dart';
import 'package:wean_app/models/userModel.dart';
import 'package:wean_app/services/firebaseServices.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/widgets/textViews.dart';
import 'package:easy_localization/easy_localization.dart';

class FeedbackScreen extends StatefulWidget {
  final String ownerId;
  final bool isProfile;

  FeedbackScreen({required this.ownerId, required this.isProfile});

  // LatLng latLng;
  // FeedbackScreen(this.latLng);
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final Faker faker = Faker.instance;
  bool isLoading = false;

  bool get _isProfile => widget.isProfile;
  final FirebaseDBServices _dbServices = FirebaseDBServices();
  late Future<UserModel> _userData;
  int wholeRating = 0;
  double ratingSum = 0.0;
  int ratingsLength = 0;

  @override
  void initState() {
    loadServices();
    super.initState();
  }

  loadServices() async {
    _userData = _dbServices.loadUser(widget.ownerId);
    await _dbServices.loadReview(widget.ownerId);
    await getSumOfReview(widget.ownerId);
    // print("rate $ratingSum");
  }

  Future getSumOfReview(String ownerId) async {
    int counter = 0;
    double rateSum = 0.0;
    FirebaseFirestore.instance
        .collection('ratings')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((data) {
      data.docs.forEach((element) {
        RatingsModel rate = RatingsModel.fromJson(element.data());
        counter += rate.rating!;
      });
      // print("totalRate ${counter} length ${ratingsLength}");
      // rateSum = counter/ratingsLength;
      ratingSum = counter.toDouble();
      // print("rateSum $rateSum");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 100,
              alignment: Alignment.center,
              color: AppTheme.primaryStartColor,
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     begin: Alignment.topCenter,
              //     end: Alignment.bottomCenter,
              //     colors: [
              //       Color(0xffFFC557),
              //       Color(0xffCE8700),
              //     ],
              //   ),
              // ),
              child: Center(
                child: TextAppName(),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 80,
                // bottom: kBottomNavigationBarHeight,
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
                  width: SizeConfig.screenWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    // alignment: Alignment.center,
                    children: [
                      // user model
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
                              return Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 50, 0, 20),
                                    child: CircleAvatar(
                                      radius: SizeConfig.screenWidth * .15,
                                      backgroundImage:
                                          snapshot.data!.photoUrl!.isEmpty
                                              ? NetworkImage(
                                                  faker.image.unsplash.food())
                                              : NetworkImage(
                                                  snapshot.data!.photoUrl!),
                                    ),
                                  ),
                                  // profile name
                                  Text(
                                    snapshot.data!.name!,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.black,
                                        fontWeight: FontWeight.w800),
                                    overflow: TextOverflow.ellipsis,
                                    // softWrap: true,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Visibility(
                                    visible:
                                        snapshot.data!.selectedCategory != null,
                                    child: IgnorePointer(
                                      child: GroupButton(
                                        buttons:
                                            snapshot.data!.selectedCategory!,
                                        onSelected: (index, isSelected) {},
                                        groupingType: GroupingType.wrap,
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        unselectedBorderColor: Colors.grey[200],
                                        unselectedColor: Colors.white,
                                        mainGroupAlignment:
                                            MainGroupAlignment.center,
                                        spacing: 12,
                                        direction: Axis.horizontal,
                                        unselectedTextStyle: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: Colors.black,
                                            letterSpacing: 1.0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  //phone number
                                  Visibility(
                                      visible: snapshot.data!.phone != null,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 20),
                                        child: Row(children: [
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
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  LocaleKeys.phone.tr(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: AppTheme.black,
                                                  ),
                                                ),
                                                Text(
                                                  snapshot.data?.phone ?? '',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppTheme.greyText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                      )),
                                  //email
                                  Visibility(
                                      visible: (snapshot.data!.email != null &&
                                          snapshot.data!.email!.isNotEmpty),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    LocaleKeys.email.tr(),
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: AppTheme.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    snapshot.data?.email ?? '',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: AppTheme.greyText,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                    height: 25,
                                  )
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
                          }),
                      // ratings
                      //stream
                      StreamBuilder<QuerySnapshot?>(
                          stream: _dbServices.ratingsDataStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              if (snapshot.data == null ||
                                  snapshot.data?.size == 0) {
                                return SizedBox(
                                  height: SizeConfig.screenHeight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(LocaleKeys.no_data_found.tr()),
                                    ],
                                  ),
                                );
                              } else {
                                return Column(
                                  children: [
                                Container(
                                  color: Color.fromRGBO(245, 188, 80, 0.1),
                                  height: 55,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Container(),
                                      ),
                                      // Spacer(),
                                      Expanded(
                                        child: Row(
                                          // mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Icon(
                                              Icons.star_rate_rounded,
                                              color: Colors.amber,
                                              size: 30,
                                            ),
                                            SizedBox(
                                              width: 12,
                                            ),
                                            Text(
                                              '${(ratingSum / snapshot.data!.docs.length).toStringAsFixed(1)}/5',
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  color: AppTheme.black,
                                                  fontWeight:
                                                      FontWeight.w500),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              // softWrap: true,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              LocaleKeys.based_on.tr() +'${snapshot.data!.docs.length}' + LocaleKeys.reviews.tr(),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.black,
                                                  fontWeight:
                                                      FontWeight.w400),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              // softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.separated(
                                  itemBuilder: (context, index) {
                                    var jsonData =
                                        snapshot.data?.docs[index];
                                    RatingsModel review =
                                        RatingsModel.fromSnapshot(
                                            jsonData!);
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FutureBuilder<UserModel>(
                                          builder: (context, snapshot) {
                                            if (snapshot
                                                    .connectionState ==
                                                ConnectionState.done) {
                                              // print("snapData ${snapshot.data!.toJson()}");
                                              return Padding(
                                                padding: const EdgeInsets
                                                        .fromLTRB(
                                                    15, 0, 15, 0),
                                                child: CircleAvatar(
                                                  radius: SizeConfig
                                                          .screenWidth *
                                                      .12,
                                                  backgroundImage: AssetImage("assets/profile_ph.jpeg"),
                                                ),
                                              );
                                            } else {
                                              return Padding(
                                                padding: const EdgeInsets
                                                        .fromLTRB(
                                                    15, 0, 15, 0),
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                    AppTheme.primaryColor,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          future: _dbServices
                                              .loadUser(review.buyerId!),
                                        ),
                                        // Spacer(),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets
                                                                .only(
                                                            left: 8.0),
                                                    child: Text(
                                                      '${review.rating}/5',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors
                                                              .black87,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w500),
                                                      overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                      // softWrap: true,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.only(
                                                            right: 8),
                                                    child: Text(
                                                      DateFormat(
                                                              'dd-MMM-yyyy')
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(review
                                                                  .updatedAt!
                                                                  .millisecondsSinceEpoch)),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .black87,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w400),
                                                      overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                      // softWrap: true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 8),
                                                child: Text(
                                                  review.buyerReview!,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.black87,
                                                      fontWeight:
                                                          FontWeight
                                                              .w600),
                                                  overflow:
                                                      TextOverflow.clip,
                                                  softWrap: true,
                                                  // softWrap: true,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              IgnorePointer(
                                                child: RatingBar(
                                                  tapOnlyMode: false,
                                                  ignoreGestures: false,
                                                  ratingWidget:
                                                      RatingWidget(
                                                    full: Icon(
                                                      Icons
                                                          .star_rate_rounded,
                                                      color: Colors.amber,
                                                    ),
                                                    half: Icon(Icons
                                                        .star_half_rounded),
                                                    empty: Icon(
                                                      Icons
                                                          .star_border_rounded,
                                                      color:
                                                          Color.fromRGBO(
                                                              0,
                                                              0,
                                                              0,
                                                              0.6),
                                                    ),
                                                  ),
                                                  onRatingUpdate:
                                                      (value) {},
                                                  glow: false,
                                                  initialRating: review
                                                      .rating!
                                                      .toDouble(),
                                                  minRating: 1,
                                                  maxRating: 5,
                                                  allowHalfRating: false,
                                                  itemCount: 5,
                                                  itemSize: 26,
                                                  wrapAlignment:
                                                      WrapAlignment.start,
                                                  direction:
                                                      Axis.horizontal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return Divider(
                                      color: Color(0xffEDEDED),
                                      endIndent: 20,
                                      indent: 20,
                                      thickness: 2,
                                    );
                                  },
                                  itemCount: snapshot.data!.docs.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                ),
                                  ],
                                );
                              }
                            }
                          }),
                    ],
                  ),
                ),
              ),
            ),
            // ic
            Positioned(
              top: 100,
              left: 20,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.greyText,
                  size: 15,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
