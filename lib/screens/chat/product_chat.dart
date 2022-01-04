import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/public_ext.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wean_app/common/routes.dart';
import 'package:wean_app/common/toastUtils.dart';
import 'package:wean_app/models/ConversationModel.dart';
import 'package:wean_app/models/ratingsModel.dart';
import 'package:wean_app/models/yardItemModel.dart';
import 'package:wean_app/screens/chat/bid_widget.dart';
import 'package:wean_app/translations/locale_keys.g.dart';

import '../../blocs/chat/chat_bloc.dart';
import '../../common/appTheme.dart';
import '../../common/screenConfig.dart';
import '../../services/cloud_storage_services.dart';
import '../../services/firebaseServices.dart';
import '../../services/image_picker_services.dart';
import '../../widgets/textViews.dart';
import 'feedback.dart';

class ProductChat extends StatefulWidget {
  ProductChat({
    required this.chatReference,
    required this.isOwner,
    required this.isProductDeleted,
    this.sentById,
  });

  final DocumentReference<Object?> chatReference;
  final bool isOwner;
  final bool isProductDeleted;
  final String? sentById;

  @override
  _ProductChatState createState() => _ProductChatState();
}

class _ProductChatState extends State<ProductChat> {
  FirebaseAuth auth = FirebaseAuth.instance;
  double currentRating = 0;
  FirebaseDBServices dbServices = FirebaseDBServices();
  final Faker faker = Faker.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final messageTextController = TextEditingController();
  final reviewController = TextEditingController();
  bool showTempSelectedFileThumbnail = false, isUploading = false;
  String tempMessage = '';

  File? _attachedFile;
  final _controller = ScrollController();

  int ratingExist = 0;

  String get _ownerId => widget.sentById!;

  late double? new_bid;

  String? buyerId;

  @override
  void initState() {
    context.read<ChatBloc>().add(FetchChat(widget.chatReference.id));

    checkRating();
    setState(() {
      buyerId = auth.currentUser!.uid;
    });
    // print("buyerId ${auth.currentUser!.uid} ${auth.currentUser!.phoneNumber}");
    // print("ownerId ${widget.sentById}");
    super.initState();
  }

  checkRating() async {
    ratingExist = await dbServices.checkExist(_ownerId, auth.currentUser!.uid);
    // print("rate ${ratingExist}");
  }

  void sendMessage(BuildContext context) {
    final timestamp = Timestamp.now();
    setState(() {
      tempMessage = messageTextController.text.trim();
      messageTextController.clear();
    });
    if (_attachedFile != null) {
      String filePath = _attachedFile!.path;
      String fileExtension = filePath.split('.').last;
      String fileType = ImagePickerServices().checkFileType(fileExtension);
      String fileName =
          '${widget.chatReference.id}/file_$timestamp.$fileExtension';
      setState(() {
        isUploading = true;
      });
      CloudStorageServices()
          .uploadChatFile(_attachedFile!, fileName)
          .then((value) {
        if (value.contains('https://')) {
          FirebaseDBServices().sendMessage(widget.chatReference.id, {
            "message": tempMessage,
            "isRead": false,
            "dateTime": timestamp,
            "sentById": auth.currentUser!.uid,
            "type": fileType,
            "url": value.toString(),
          }).whenComplete(() {
            setState(() {
              showTempSelectedFileThumbnail = false;
              isUploading = false;
            });
            if (tempMessage.isNotEmpty) {
              FirebaseDBServices()
                  .saveLastMessage(widget.chatReference.id, tempMessage)
                  .whenComplete(() {
                setState(() {
                  tempMessage = '';
                  _attachedFile = null;
                });
              });
            } else {
              setState(() {
                tempMessage = '';
                _attachedFile = null;
              });
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value.toString()),
              duration: Duration(seconds: 1),
            ),
          );
        }
      });
    } else {
      if (tempMessage != '') {
        FirebaseDBServices().sendMessage(widget.chatReference.id, {
          "message": tempMessage,
          "isRead": false,
          "dateTime": timestamp,
          "sentById": auth.currentUser!.uid
        }).whenComplete(
          () => FirebaseDBServices()
              .saveLastMessage(widget.chatReference.id, tempMessage)
              .whenComplete(() {
            setState(() {
              tempMessage = '';
              _attachedFile = null;
            });
          }),
        );
      }
    }
  }

  showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return BidWidget(
            chatReference: widget.chatReference,
          );
        });
  }

  showRatingPopUp() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        isDismissible: true,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              height: SizeConfig.screenHeight / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          LocaleKeys.feedback.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RatingBar(
                    tapOnlyMode: true,
                    // itemSize: 25,
                    ratingWidget: RatingWidget(
                      full: Icon(
                        Icons.star_rate_rounded,
                        color: Colors.amber,
                      ),
                      half: Icon(Icons.star_half_rounded),
                      empty: SvgPicture.asset(
                        'assets/svg/star.svg',
                        width: 20,
                        height: 20,
                        fit: BoxFit.scaleDown,
                        color: Color.fromRGBO(0, 0, 0, 0.6),
                      ),
                      //     Icon(Icons.star_border_rounded,
                      //       size: 1, color: Color.fromRGBO(0, 0, 0, 0.6)
                      // ),
                    ),
                    onRatingUpdate: (value) {
                      setState(() {
                        currentRating = value;
                      });
                    },
                    glow: false,
                    initialRating: 0,
                    minRating: 1,
                    maxRating: 5,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    direction: Axis.horizontal,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextFormField(
                      maxLines: 3,
                      maxLength: 140,
                      controller: reviewController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          // border: normalBorder,
                          // enabledBorder: normalBorder,
                          // focusedBorder: focusBorder,
                          hintText: LocaleKeys.enter_description_msg.tr(),
                          hintStyle: AppTheme.body2.copyWith(
                            color: AppTheme.greyText,
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppTheme.primaryColor,
                    ),
                    margin: const EdgeInsets.all(6),
                    width: SizeConfig.screenWidth * .9,
                    child: ElevatedButton(
                        style: AppTheme.flatButtonStyle.copyWith(),
                        onPressed: () async {
                          // print("currentRate $currentRating");
                          // print("reviewText ${reviewController.text}");
                          if (currentRating == 0) {
                            Toast.showError(LocaleKeys.please_give_rating.tr());
                            return;
                          }
                          await dbServices.addReview(RatingsModel(
                            buyerReview: reviewController.text.isEmpty
                                ? ''
                                : reviewController.text,
                            rating: currentRating.toInt(),
                            createdAt: Timestamp.now(),
                            updatedAt: Timestamp.now(),
                            buyerId: auth.currentUser!.uid,
                            ownerId: widget.sentById,
                          ));
                          ratingExist = 1;
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          LocaleKeys.submit.tr(),
                          style: AppTheme.textTheme.button,
                        )),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var tempFileType;
    if (_attachedFile != null) {
      tempFileType = ImagePickerServices().checkFileType(
        _attachedFile!.path.split('.').last,
      );
    }
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 100,
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
                margin: const EdgeInsets.only(top: 80),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    width: SizeConfig.screenWidth,
                    child: BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        if (state is ChatFetchProgress) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                AppTheme.primaryColor,
                              ),
                            ),
                          );
                        } else if (state is ChatFetchSuccess) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                child: Row(
                                  children: [
                                    IconButton(
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
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 15, 0, 5),
                                      child: InkWell(
                                        onTap: () {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) => FeedbackScreen(
                                          //       isProfile: false,
                                          //       ownerId: widget.sentById!,
                                          //     ),
                                          //   ),
                                          // );
                                        },
                                        child: widget.isOwner
                                            ? CircleAvatar(
                                                radius: 26,
                                                backgroundImage: AssetImage(
                                                    'assets/profile_ph.jpeg'),
                                              )
                                            : FutureBuilder<DocumentSnapshot>(
                                                future: FirebaseFirestore
                                                    .instance
                                                    .collection('users')
                                                    .doc(widget.sentById)
                                                    .get(),
                                                builder: (_, userSnapshot) {
                                                  return userSnapshot.hasData
                                                      ? CircleAvatar(
                                                          radius: 26,
                                                          backgroundImage:
                                                              NetworkImage(
                                                            (userSnapshot.data!
                                                                            .data()
                                                                        as Map?)?[
                                                                    'photo_url'] ??
                                                                '',
                                                          ),
                                                        )
                                                      : Container();
                                                }),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FutureBuilder<DocumentSnapshot>(
                                              future:
                                                  widget.chatReference.get(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData &&
                                                    snapshot.data!.data() !=
                                                        null) {
                                                  final conversation =
                                                      ConversationModel
                                                          .fromDocSnapshot(
                                                              snapshot.data!);
                                                  return widget.isOwner
                                                      ? Text(LocaleKeys
                                                          .waen_user
                                                          .tr())
                                                      : Text(conversation
                                                              .senderName ??
                                                          LocaleKeys.waen_user
                                                              .tr());
                                                } else {
                                                  return Container();
                                                }
                                              }),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Spacer(),
                                    if (!widget.isOwner)
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 15.0),
                                                  child: SvgPicture.asset(
                                                    'assets/svg/star.svg',
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.6),
                                                  )),
                                              onTap: () {
                                                if (ratingExist > 0) {
                                                  Toast.showInfo(LocaleKeys
                                                      .already_reviewed
                                                      .tr());
                                                  return;
                                                }
                                                showRatingPopUp();
                                              },
                                            ),
                                            GestureDetector(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 15.0),
                                                child: SvgPicture.asset(
                                                  'assets/svg/alert-circle.svg',
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.6),
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FeedbackScreen(
                                                      ownerId: widget.sentById!,
                                                      isProfile: false,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                width: SizeConfig.screenWidth - 10,
                              ),

                              SizedBox(
                                height: 5,
                              ),
                              FutureBuilder<DocumentSnapshot>(
                                  future: widget.chatReference.get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      final conversation =
                                          ConversationModel.fromDocSnapshot(
                                              snapshot.data!);
                                      return StreamBuilder<DocumentSnapshot>(
                                        stream: conversation.productReference!
                                            .snapshots(),
                                        builder: (context, productSnapshot) {
                                          if (productSnapshot.hasData &&
                                              productSnapshot.data!.data() !=
                                                  null) {
                                            YardItem yardItem =
                                                YardItem.fromDocumentSnapshot(
                                                    productSnapshot.data!);
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  yardDetail,
                                                  arguments: YardItemInfo(
                                                    item: yardItem,
                                                    isHistory: true,
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 22,
                                                        vertical: 0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            yardItem
                                                                .description,
                                                            softWrap: true,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w100,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        for (var i in yardItem
                                                                    .media
                                                                    .length >
                                                                3
                                                            ? yardItem.media
                                                                .sublist(0, 3)
                                                            : yardItem.media)
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        5),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    NetworkImage(
                                                                        i),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            height: 35,
                                                            width: 35,
                                                          ),
                                                      ],
                                                    ),
                                                    (yardItem.is_auction)
                                                        ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              LocaleKeys
                                                                      .SAR
                                                                      .tr() +
                                                                  ' ' +
                                                                  yardItem
                                                                      .current_bid
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      21,
                                                                  color: AppTheme
                                                                      .primaryColor),
                                                            )
                                                          ],
                                                        )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else if (widget.isProductDeleted) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: Text(
                                                LocaleKeys.product_expired_msg
                                                    .tr(),
                                                softWrap: true,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w100,
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }),

                              Divider(
                                color: Colors.black12,
                              ),
                              Expanded(
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: state.chatStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                            AppTheme.primaryColor,
                                          ),
                                        ),
                                      );
                                    }
                                    if (snapshot.hasData) {
                                      FirebaseDBServices().updateReadStatus(
                                          widget.chatReference,
                                          widget.sentById!);
                                      Future.delayed(
                                          Duration(milliseconds: 100), () {
                                        _controller.animateTo(
                                            _controller
                                                .position.maxScrollExtent,
                                            duration:
                                                Duration(microseconds: 100),
                                            curve: Curves.easeIn);
                                      });
                                      return ListView.builder(
                                        controller: _controller,
                                        physics: BouncingScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: BuildMessageBubble(
                                              data: snapshot.data!.docs[index]
                                                      .data()
                                                  as Map<String, dynamic>,
                                              id: snapshot.data!.docs[index].id,
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              ),
                              // Divider(
                              //   height: 1,
                              // ),
                              if (showTempSelectedFileThumbnail &&
                                  _attachedFile != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.3),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: tempFileType == 'IMAGE'
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15),
                                                      topRight:
                                                          Radius.circular(15),
                                                    ),
                                                    child: Image.file(
                                                      File(_attachedFile!.path),
                                                      height: 200,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : tempFileType == 'VIDEO'
                                                    ? FutureBuilder(
                                                        future:
                                                            ImagePickerServices()
                                                                .tempFilePath(
                                                                    _attachedFile),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot.hasData) {
                                                            return ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        15),
                                                                topRight: Radius
                                                                    .circular(
                                                                        15),
                                                              ),
                                                              child: Image.file(
                                                                File(snapshot
                                                                        .data!
                                                                    as String),
                                                                height: 200,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.9,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          } else if (snapshot
                                                              .hasError) {
                                                            return Text(snapshot
                                                                .error
                                                                .toString());
                                                          } else {
                                                            return CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation(
                                                                AppTheme
                                                                    .primaryColor,
                                                              ),
                                                            );
                                                          }
                                                        })
                                                    : Icon(
                                                        Icons.file_present,
                                                        size: 90,
                                                        color: Colors
                                                            .grey.shade400,
                                                      ),
                                          ),
                                          if (isUploading &&
                                              _attachedFile != null)
                                            Center(
                                              child: SpinKitThreeBounce(
                                                color: AppTheme.primaryColor,
                                                size: 30,
                                              ),
                                            ),
                                          if (showTempSelectedFileThumbnail &&
                                              _attachedFile != null &&
                                              !isUploading)
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _attachedFile = null;
                                                    showTempSelectedFileThumbnail =
                                                        false;
                                                  });
                                                },
                                                child: Container(
                                                  height: 30,
                                                  width: 30,
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white54,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 20,
                                                    color: AppTheme.black,
                                                  ),
                                                ),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (!widget.isProductDeleted)
                                AbsorbPointer(
                                  absorbing: isUploading,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 0, 10, 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                        ),
                                        child: Row(
                                          children: [
                                            Transform.rotate(
                                              angle: pi / 4,
                                              child: PopupMenuButton(
                                                itemBuilder:
                                                    (BuildContext context) {
                                                  return [
                                                    PopupMenuItem(
                                                      value: 0,
                                                      child: Text(LocaleKeys
                                                          .image
                                                          .tr()),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 1,
                                                      child: Text(LocaleKeys
                                                          .document
                                                          .tr()),
                                                    ),
                                                  ];
                                                },
                                                icon: Icon(
                                                  Icons.attach_file,
                                                  color: AppTheme.greyText,
                                                  size: 24,
                                                ),
                                                onSelected: (int value) async {
                                                  switch (value) {
                                                    case 0:
                                                      await ImagePickerServices()
                                                          .pickFile(
                                                              context,
                                                              _attachedFile,
                                                              FileType.media)
                                                          .then((value) {
                                                        setState(() {
                                                          _attachedFile = value;
                                                          showTempSelectedFileThumbnail =
                                                              true;
                                                        });
                                                      });
                                                      break;
                                                    case 1:
                                                      await ImagePickerServices()
                                                          .pickFile(
                                                              context,
                                                              _attachedFile,
                                                              FileType.custom)
                                                          .then((value) {
                                                        setState(() {
                                                          _attachedFile = value;
                                                          showTempSelectedFileThumbnail =
                                                              true;
                                                        });
                                                      });
                                                      break;
                                                    case 2:
                                                      await ImagePickerServices()
                                                          .pickFile(
                                                              context,
                                                              _attachedFile,
                                                              FileType.any)
                                                          .then((value) {
                                                        setState(() {
                                                          _attachedFile = value;
                                                          showTempSelectedFileThumbnail =
                                                              true;
                                                        });
                                                      });
                                                      break;
                                                  }
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                    messageTextController,
                                                maxLength: 145,
                                                maxLengthEnforcement:
                                                    MaxLengthEnforcement
                                                        .enforced,
                                                textInputAction:
                                                    TextInputAction.done,
                                                style: TextStyle(
                                                  color: AppTheme.black,
                                                  fontSize: 16,
                                                ),
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 10.0,
                                                          horizontal: 20.0),
                                                  hintText: LocaleKeys
                                                      .type_in_msg
                                                      .tr(),
                                                  border: InputBorder.none,
                                                ),
                                                autofocus: false,
                                                onSubmitted: (value) =>
                                                    sendMessage(context),
                                                onChanged: (value) {},
                                              ),
                                            ),

                                            FutureBuilder<DocumentSnapshot>(
                                                future:
                                                    widget.chatReference.get(),
                                                builder: (context, snapshot) {
                                                  if ((snapshot.hasData &&
                                                      !snapshot.hasError)) {
                                                    final conversation =
                                                        ConversationModel
                                                            .fromDocSnapshot(
                                                                snapshot.data!);
                                                    return StreamBuilder<
                                                        DocumentSnapshot>(
                                                      stream: conversation
                                                          .productReference!
                                                          .snapshots(),
                                                      builder: (context,
                                                          productSnapshot) {
                                                        if (productSnapshot
                                                                .hasData &&
                                                            productSnapshot
                                                                    .data !=
                                                                null &&
                                                            productSnapshot
                                                                    .data!
                                                                    .data() !=
                                                                null) {
                                                          YardItem yardItem = YardItem
                                                              .fromDocumentSnapshot(
                                                                  productSnapshot
                                                                      .data!);

                                                          if (yardItem
                                                                  .is_auction) {
                                                            return Visibility(
                                                              visible: yardItem
                                                                      .ownerId !=
                                                                  buyerId,
                                                              child: InkWell(
                                                                onTap: () =>
                                                                    showBottomSheet(
                                                                        context),
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  width: 40,
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .all(8),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Color(
                                                                        0xffF5BC50),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child:
                                                                      ImageIcon(
                                                                    AssetImage(
                                                                        'assets/dollar.png'),
                                                                    color: Colors
                                                                        .white,
                                                                    size: 28,
                                                                  ) /*Icon(
                                                          Icons
                                                              .send_rounded,
                                                          color: AppTheme
                                                              .black,
                                                          size: 20,
                                                        )*/
                                                                  ,
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            return Container();
                                                          }
                                                        } else {
                                                          return Container();
                                                        }
                                                      },
                                                    );
                                                  } else {
                                                    return Container();
                                                  }
                                                }),

                                            // StreamBuilder<DocumentSnapshot>(
                                            //   stream: null,
                                            //   builder: (context, snapshot) {
                                            //     return InkWell(
                                            //       onTap: () => showBottomSheet(context),
                                            //       child: Transform.rotate(
                                            //         angle: -pi / 4,
                                            //         child: Container(
                                            //           height: 40,
                                            //           width: 40,
                                            //           margin: const EdgeInsets.all(8),
                                            //           decoration: BoxDecoration(
                                            //             color: Color(0xffF5BC50),
                                            //             shape: BoxShape.circle,
                                            //           ),
                                            //           child: Icon(
                                            //             Icons.send_rounded,
                                            //             color: AppTheme.black,
                                            //             size: 20,
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     );
                                            //   }
                                            // ),

                                            InkWell(
                                              onTap: () => sendMessage(context),
                                              child: Transform.rotate(
                                                angle: -pi / 4,
                                                child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  margin:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffF5BC50),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.send_rounded,
                                                    color: AppTheme.black,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class BuildMessageBubble extends StatefulWidget {
  const BuildMessageBubble({Key? key, required this.data, required this.id})
      : super(key: key);

  final Map<String, dynamic> data;
  final String id;

  @override
  _BuildMessageBubbleState createState() => _BuildMessageBubbleState();
}

class _BuildMessageBubbleState extends State<BuildMessageBubble> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? fileName;
  String? thumbnailFilePath;
  String? type;
  String? url;

  @override
  void initState() {
    url = widget.data['url'];
    type = widget.data['type'];
    super.initState();
  }

  Future<String?> getThumbnailFilePath() async {
    Directory dir = await getTemporaryDirectory();
    fileName = await VideoThumbnail.thumbnailFile(
      video: url!,
      thumbnailPath: dir.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 64,
      quality: 75,
    );
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.data['sentById'] == auth.currentUser!.uid
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Material(
        borderRadius: widget.data['sentById'] == auth.currentUser!.uid
            ? BorderRadius.only(
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              )
            : BorderRadius.only(
                topRight: Radius.circular(15.0),
                topLeft: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
        elevation: 0.0,
        color: widget.data['sentById'] != auth.currentUser!.uid
            ? Colors.grey.shade300
            : Color(0xffF5BC50),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment:
                  widget.data['sentById'] == auth.currentUser!.uid
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                if (url != null)
                  Card(
                    // elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadowColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: url != null
                          ? type == 'IMAGE'
                              ? InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      DialogRoute(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              InteractiveViewer(
                                                clipBehavior: Clip.none,
                                                maxScale: 5,
                                                child: SizedBox(
                                                  height:
                                                      SizeConfig.screenHeight *
                                                          0.8,
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        widget.data['url'],
                                                    placeholder: (context,
                                                            url) =>
                                                        Image.asset(
                                                            'assets/waen_logo.png'),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 5, 0, 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10,
                                                    ),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    icon: Icon(
                                                      Icons.arrow_back_ios,
                                                      color: Colors.white60,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: widget.data['url'],
                                    placeholder: (context, url) =>
                                        Image.asset('assets/waen_logo.png'),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : type == 'DOCUMENT'
                                  ? InkWell(
                                      onTap: () async {
                                        await launch(widget.data['url']);
                                      },
                                      child: Icon(
                                        Icons.file_present,
                                        size: 90,
                                        color: Colors.black,
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        await launch(widget.data['url']);
                                      },
                                      child: Icon(
                                        Icons.file_copy,
                                        size: 90,
                                        color: Colors.black,
                                      ),
                                    )
                          : SizedBox.shrink(),
                    ),
                  ),
                if (widget.data['message'] != null &&
                    widget.data['message'] != '')
                  TextNormal(
                    text: widget.data['message'],
                    textSize: 14,
                    textColor: Colors.black,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
