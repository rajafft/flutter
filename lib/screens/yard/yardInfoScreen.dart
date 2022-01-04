import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_slider/carousel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wean_app/blocs/conversation/conversation_bloc.dart';
import 'package:wean_app/blocs/report_product_bloc/report_product_bloc.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/screenConfig.dart';
import 'package:wean_app/common/toastUtils.dart';
import 'package:wean_app/models/yardItemModel.dart';
import 'package:wean_app/screens/chat/product_chat.dart';
import 'package:wean_app/screens/yard/gellery_screen.dart';
import 'package:wean_app/services/firebaseServices.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/widgets/textViews.dart';

class YardInfoScreen extends StatefulWidget {
  const YardInfoScreen({required this.item});

  final YardItemInfo item;

  @override
  _YardInfoScreenState createState() => _YardInfoScreenState();
}

class _YardInfoScreenState extends State<YardInfoScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  Color favColor = Colors.red;
  IconData favIcon = Icons.favorite_border_outlined;
  String hoursLeft = '';
  List<String> imageUrls = [];
  int numberOfFav = 0;
  final toolTipKey = GlobalKey<State<Tooltip>>();
  String durationLeft = '';

  final reasonNotifier = ValueNotifier<String?>(null);
  final noteController = TextEditingController();
  final reasons = [];

  @override
  void initState() {
    calculateLimit();
    getImageUrls();
    // if(_items.numberOfFavorites!=null){
    numberOfFav = 4; //?? _items.numberOfFavorites!;
    // }
    FirebaseDBServices().loadPreferences().then((value) {
      reasons.addAll(value.reportReasons.map((e) => e.toString()));
    });
    super.initState();
  }

  YardItem get _items => widget.item.item;

  bool get _isHistory => widget.item.isHistory;

  bool get _isOwner => widget.item.item.ownerId == auth.currentUser!.uid;

  // int plusFavorites() {
  //   if (_items.numberOfFavorites != null) {
  //     return _items.numberOfFavorites! + 1;
  //   } else {
  //     return 1;
  //   }
  // }

  int minusFavorites() {
    if (numberOfFav != 0) {
      return numberOfFav - 1;
    } else {
      return 0;
    }
  }

  double calculateLimit() {
    DateTime _itemDate = widget.item.item.updatedAt.toDate();
    Duration fromCurrentDate = DateTime.now().difference(_itemDate);
    final leftOutDuration = Duration(hours: 24) - fromCurrentDate;
    List<String> splittedString =
        leftOutDuration.toString().split('.')[0].split(':');
    durationLeft = '${splittedString[0]}:${splittedString[1]}';
    return leftOutDuration.inHours.toDouble() / 24;
  }

  Color setBGLimitColor() {
    double limit = calculateLimit();
    // print("limit $limit");
    if (limit >= 0.90) {
      return Colors.green;
    } else if (limit >= 0.80 && limit < 0.89) {
      return Colors.orangeAccent.shade200;
    } else if (limit >= 0.70 && limit < 0.79) {
      return Colors.orangeAccent.shade400;
    } else if (limit >= 0.50 && limit < 0.69) {
      return Colors.orangeAccent.shade700;
    } else {
      return Colors.red;
    }
  }

  List<String> getImageUrls() {
    if (_items.media.isNotEmpty) {
      imageUrls = _items.media;
    } else {
      if (_items.media.isNotEmpty) {
        imageUrls.add("${_items.media}");
      } else {
        imageUrls.add("assets/waen_bglogo.png");
      }
    }
    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
    preferredSize: Size.fromHeight(50),
    child: AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0.0,
      centerTitle: true,
      automaticallyImplyLeading: true,
      title: TextAppName(),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(
          Icons.arrow_back,
          color: AppTheme.white,
        ),
      ),
    ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Container(
      //   child: (_isOwner)
      //       ? SizedBox()
      //       : InkWell(
      //           onTap: () async {
      //             log(" on tap ", name: 'on tap ');
      //             await FirebaseFirestore.instance
      //                 .collection('users')
      //                 .doc(widget.item.item.ownerId)
      //                 .get()
      //                 .then((value) async {
      //               var ownerName = (value.data() as Map)['name'];
      //               await FirebaseFirestore.instance
      //                   .collection('users')
      //                   .doc(auth.currentUser!.uid)
      //                   .get()
      //                   .then((value) {
      //                 log((value.data() as Map)['name']);
      //                 var senderName = (value.data() as Map)['name'];
      //                 ownerName != null &&
      //                         (ownerName as String).isNotEmpty &&
      //                         senderName != null &&
      //                         (senderName as String).isNotEmpty
      //                     ? context.read<ConversationBloc>().add(
      //                           CreateConversation(
      //                             widget.item.item.ownerId,
      //                             ownerName,
      //                             widget.item.item.documentReference!.id,
      //                             auth.currentUser!.uid,
      //                             senderName,
      //                             widget.item.item.documentReference!,
      //                           ),
      //                         )
      //                     : Toast.showError(
      //                         'Something went wrong, please try again.',
      //                       );
      //               });
      //             });
      //           },
      //           child: Container(
      //               width: 124,
      //               height: kBottomNavigationBarHeight,
      //               decoration: BoxDecoration(
      //                 borderRadius: BorderRadius.circular(10),
      //                 color: AppTheme.primaryColor,
      //               ),
      //               child: Center(
      //                   child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 children: [
      //                   //assets/messageblack.png
      //                   Image.asset('assets/messageblack.png'),
      //                   SizedBox(
      //                     width: 5,
      //                   ),
      //                   BlocConsumer<ConversationBloc, ConversationState>(
      //                     listener: (context, state) {
      //                       if (state is ConversationCreationSuccess) {
      //                         state.documentReference.get().then((value) {
      //                           var ownerId = (value.data() as Map)['ownerId'];
      //                           Navigator.pushReplacement(
      //                             context,
      //                             MaterialPageRoute(
      //                               builder: (context) => ProductChat(
      //                                 chatReference: state.documentReference,
      //                                 sentById: ownerId,
      //                                 isOwner: true,
      //                               ),
      //                             ),
      //                           );
      //                         });
      //                       } else if (state is ConversationCreationFailure) {
      //                         ScaffoldMessenger.of(context).showSnackBar(
      //                             SnackBar(
      //                                 content: Text("Something went wrong")));
      //                       }
      //                     },
      //                     builder: (context, state) {
      //                       if (state is ConversationCreationProgress) {
      //                         return Center(
      //                           child: CircularProgressIndicator(
      //                             valueColor: AlwaysStoppedAnimation(
      //                               AppTheme.primaryColor,
      //                             ),
      //                           ),
      //                         );
      //                       } else
      //                         return Text(
      //                           'Reply',
      //                           style: TextStyle(
      //                               fontSize: 14, fontWeight: FontWeight.w500),
      //                         );
      //                     },
      //                   ),
      //                 ],
      //               ))),
      //         ),

      //   // Row(
      //   //   children: [
      //   //
      //   //     // Expanded(
      //   //     //   child: Container(
      //   //     //     height: kBottomNavigationBarHeight,
      //   //     //     color: Color(0xffE4A328),
      //   //     //     child: Center(
      //   //     //       child: Text(
      //   //     //         'Buy Now',
      //   //     //         style: TextStyle(fontSize: 16),
      //   //     //       ),
      //   //     //     ),
      //   //     //   ),
      //   //     // )
      //   //   ],
      //   // ),
      // ),

      // floatingActionButton: Visibility(
      //   visible: !_isOwner,
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       context.read<ConversationBloc>().add(CreateConversation(
      //           widget.item.item.ownerId,
      //           widget.item.item.documentReference!.id,
      //           auth.currentUser!.uid,
      //           auth.currentUser!.displayName!,
      //           widget.item.item.documentReference!));
      //     },
      //     shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.all(
      //       Radius.circular(30),
      //     )),
      //     child: BlocConsumer<ConversationBloc, ConversationState>(
      //       listener: (context, state) {
      //         if (state is ConversationCreationSuccess) {
      //           state.documentReference.get().then((value) {
      //             var ownerId = (value.data() as Map)['ownerId'];
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => ProductChat(
      //                   chatReference: state.documentReference,
      //                   sentById: ownerId,
      //                 ),
      //               ),
      //             );
      //           });
      //         } else if (state is ConversationCreationFailure) {
      //           ScaffoldMessenger.of(context).showSnackBar(
      //               SnackBar(content: Text("Something went wrong")));
      //         }
      //       },
      //       builder: (context, state) {
      //         if (state is ConversationCreationProgress) {
      //           return Center(
      //             child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(
      //                 AppTheme.primaryColor,
      //               ),
      //             ),
      //           );
      //         } else {
      //           return Icon(
      //             Icons.chat_bubble,
      //             color: AppTheme.white,
      //           );
      //         }
      //       },
      //     ),
      //     elevation: 0,
      //     backgroundColor: AppTheme.primaryColor,
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: ListView(
    physics: BouncingScrollPhysics(),
    // shrinkWrap: true,
    // crossAxisAlignment: CrossAxisAlignment.start,
    children: [
        Carousel(
            height: SizeConfig.screenHeight * .7,
            indicatorBarColor: Colors.white,
            autoScrollDuration: Duration(seconds: 2),
            animationPageDuration: Duration(milliseconds: 500),
            activateIndicatorColor: AppTheme.primaryColor,
            animationPageCurve: Curves.bounceInOut,
            indicatorBarHeight: 35,
            indicatorHeight: 20,
            indicatorWidth: 10,
            unActivatedIndicatorColor: Colors.grey.shade200,
            stopAtEnd: true,
            autoScroll: false,
            scrollAxis: Axis.horizontal,
            isCircle: true,
            items: List.generate(
                imageUrls.length,
                (index) => ClipRect(
                      child: imageUrls[index].startsWith("assets")
                          ? InkWell(
                              onTap: () {},
                              child: Image.asset(
                                imageUrls[index],
                                width: SizeConfig.screenWidth - 10,
                                height: SizeConfig.screenHeight * 0.7,
                                fit: BoxFit.cover,
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GalleryView(
                                            imageUrls: imageUrls,
                                            currentPosition: index,
                                          )),
                                );
                              },
                              child: Image.network(imageUrls[index],
                                  width: SizeConfig.screenWidth - 10,
                                  height: SizeConfig.screenHeight * 0.7,
                                  fit: BoxFit.cover),
                            ),
                    ))),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    widget.item.item.is_auction
                        ? Text(
                          LocaleKeys.SAR.tr() +
                              ' ' +
                              widget.item.item.current_bid.toString(),
                          style: TextStyle(
                              fontSize: 21, color: AppTheme.primaryColor),
                        )
                        : Container(),
                    Expanded(child: Container()),
                    Visibility(
                      visible: (!_isHistory && !_isOwner),
                      child: GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.0))),
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 20),
                              child: Container(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextTitle(text: LocaleKeys.report.tr()),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ValueListenableBuilder<String?>(
                                        valueListenable: reasonNotifier,
                                        builder:
                                            (_, reasonNotiferValue, child) {
                                          return DropdownButton<String>(
                                            isExpanded: true,
                                            items: reasons.map<
                                                    DropdownMenuItem<String>>(
                                                (e) {
                                              return DropdownMenuItem<String>(
                                                child: Text(
                                                  e.toString(),
                                                ),
                                                value: e.toString(),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              reasonNotifier.value = value;
                                            },
                                            hint: Text(LocaleKeys
                                                .select_reason
                                                .tr()),
                                            value: reasonNotiferValue,
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      TextField(
                                        controller: noteController,
                                        decoration: InputDecoration(
                                          enabled: true,
                                          hintText:
                                              LocaleKeys.enter_reason.tr(),
                                          enabledBorder:
                                              UnderlineInputBorder(),
                                          focusedBorder:
                                              UnderlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      BlocConsumer<ReportProductBloc,
                                          ReportProductState>(
                                        listener: (context, state) {
                                          if (state is ReportProductSuccess) {
                                            reasonNotifier.value = null;
                                            noteController.clear();
                                            Navigator.pop(context);
                                          }
                                        },
                                        builder: (context, state) {
                                          if (state is ReportProductProgress) {
                                            return Align(
                                                alignment: Alignment.center,
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          return SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (reasonNotifier.value !=
                                                        null &&
                                                    reasonNotifier
                                                        .value!.isNotEmpty) {
                                                  context
                                                      .read<
                                                          ReportProductBloc>()
                                                      .add(ReportProduct({
                                                        'item_id': widget
                                                                .item
                                                                .item
                                                                .documentReference
                                                                ?.id ??
                                                            '',
                                                        'item_owner_id':
                                                            widget.item.item
                                                                .ownerId,
                                                        'reason':
                                                            reasonNotifier
                                                                .value,
                                                        'note': noteController
                                                            .text,
                                                        'user_id': FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid ??
                                                            '',
                                                        'created_at':
                                                            Timestamp.now()
                                                      }));
                                                } else {
                                                  Toast.showError(LocaleKeys
                                                      .please_select_reason
                                                      .tr());
                                                }
                                              },
                                              child: Text(
                                                  LocaleKeys.submit.tr()),
                                              style: ElevatedButton.styleFrom(
                                                primary:
                                                    AppTheme.primaryColor,
                                                onPrimary: Colors.black,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                  )),
                            );
                          },
                        ),
                        child: SizedBox(
                          height: 45,
                          width: 75,
                          child: SvgPicture.asset(
                            'assets/svg/report.svg',
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ])),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Visibility(
              visible: !_isHistory,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                alignment: Alignment.centerLeft,
                child: TextTitle(
                  text: durationLeft,
                  textColor: Colors.grey.shade500,
                  textSize: 14,
                ),
              ),
            ),
            Visibility(
              visible: !_isHistory,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: calculateLimit(),
                  color: setBGLimitColor(),
                  backgroundColor: Colors.grey.shade300,
                  minHeight: 5,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextTitle(
                    text: _items.name,
                    textSize: 24,
                  ),
                ),
                // GestureDetector(
                //   onTap: (){
                //     setState(() {
                //       if(favIcon== Icons.favorite_border_outlined) {
                //         favIcon = Icons.favorite;
                //         favColor = Colors.white;
                //         numberOfFav = plusFavorites();
                //       }else{
                //         favIcon = Icons.favorite_border_outlined;
                //         favColor = Colors.red;
                //         numberOfFav = minusFavorites();
                //       }
                //     });
                //   },
                //   child: Stack(
                //     alignment: AlignmentDirectional.center,
                //     children: [
                //       Align(child: Icon(favIcon, color: Colors.red, size: 42,), alignment: Alignment.center,),
                //     ],
                //   ),
                // )
              ],
            ),
            // Row(
            //   children: [
            //     Icon(
            //       Icons.timelapse_rounded,
            //       color: setBGLimitColor(),
            //     ),
            //     TextTitle(
            //         text: 'Expired within next $hoursLeft hrs.'),
            //   ],
            // ),
            // SizedBox(
            //   height: 10,
            // ),
            // Row(
            //   children: [
            //     TextNormal(text: "$numberOfFav likes",),
            //     TextNormal(text: '5 Comments'),
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Row(
                //   children: [
                //     Icon(
                //       Icons.person,
                //       color: Colors.green.shade800,
                //     ),
                //     TextTitle(
                //       text: _items.sellerName,
                //       textSize: 16,
                //       textColor: AppTheme.primaryDarkColor,
                //     ),
                //   ],
                // ),
                Row(
                  children: const [
                    // InkWell(
                    //   child: Icon(
                    //     Icons.phone,
                    //     color: Colors.blue,
                    //   ),
                    // ),
                    // SizedBox(
                    //   width: 40,
                    // ),
                    // Tooltip(
                    //   key: toolTipKey,
                    //   message: _items.sellerAddress,
                    //   child: GestureDetector(
                    //     child:
                    //         Icon(Icons.place, color: Colors.red),
                    //     onTap: () => _onTapAddress(toolTipKey),
                    //     behavior: HitTestBehavior.opaque,
                    //   ),
                    // ),
                    // SizedBox(
                    //   width: 10,
                    // ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              _items.description,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1.5),
              // textSize: 21,
            ),
            // TextNormal(
            //   text: "${_items.description}",
            //   textSize: 14,
            // ),
            SizedBox(
              height: 35,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                  child: (_isOwner)
                      ? SizedBox()
                      : InkWell(
                          onTap: () async {
                            log(" on tap ", name: 'on tap ');
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.item.item.ownerId)
                                .get()
                                .then((value) async {
                              var ownerName = (value.data() as Map)['name'];
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(auth.currentUser!.uid)
                                  .get()
                                  .then((value) {
                                log((value.data() as Map)['name']);
                                var senderName =
                                    (value.data() as Map)['name'];
                                ownerName != null &&
                                        (ownerName as String).isNotEmpty &&
                                        senderName != null &&
                                        (senderName as String).isNotEmpty
                                    ? context.read<ConversationBloc>().add(
                                          CreateConversation(
                                            widget.item.item.ownerId,
                                            ownerName,
                                            widget.item.item
                                                .documentReference!.id,
                                            auth.currentUser!.uid,
                                            senderName,
                                            widget
                                                .item.item.documentReference!,
                                          ),
                                        )
                                    : Toast.showError(
                                        LocaleKeys.something_wrong_try_again
                                            .tr(),
                                      );
                              });
                            });
                          },
                          child: Container(
                              width: 124,
                              height: kBottomNavigationBarHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppTheme.primaryColor,
                              ),
                              child: Center(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //assets/messageblack.png
                                  Image.asset('assets/messageblack.png'),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  BlocConsumer<ConversationBloc,
                                      ConversationState>(
                                    listener: (context, state) {
                                      if (state
                                          is ConversationCreationSuccess) {
                                        state.documentReference
                                            .get()
                                            .then((value) {
                                          var ownerId = (value.data()
                                              as Map)['ownerId'];
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductChat(
                                                chatReference:
                                                    state.documentReference,
                                                sentById: ownerId,
                                                isOwner: true,
                                                isProductDeleted: false,
                                              ),
                                            ),
                                          );
                                        });
                                      } else if (state
                                          is ConversationCreationFailure) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(LocaleKeys
                                                    .something_wrong
                                                    .tr())));
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state
                                          is ConversationCreationProgress) {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation(
                                              AppTheme.primaryColor,
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Text(
                                          LocaleKeys.reply.tr(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ))),
                        )),
            )
          ]),
        ),
    ],
        ),
      ),
    );
  }
}
