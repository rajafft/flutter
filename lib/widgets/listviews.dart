import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wean_app/common/routes.dart';
import 'package:wean_app/common/screenConfig.dart';
import 'package:wean_app/models/yardItemModel.dart';
import 'package:wean_app/screens/landing/home_screen.dart';
import 'package:wean_app/services/firebaseServices.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/widgets/textViews.dart';

class ListYardItems extends StatefulWidget {
  final YardItem item;
  final bool isHistory;
  final String? indexID;

  ListYardItems(
      {required this.item, required this.isHistory, required this.indexID});

  @override
  _ListYardItemsState createState() => _ListYardItemsState();
}

class _ListYardItemsState extends State<ListYardItems> {
  String get _imageUrl => widget.item.media.isNotEmpty
      ? widget.item.media.first
      : "https://firebasestorage.googleapis.com/v0/b/waen-f0eb7.appspot.com/o/items%2Fwaen_logo.png?alt=media&token=0f3b5b44-abee-426c-ac1a-4cdb68de2b6f";

  bool get _isHistory => widget.isHistory;

  String? get _indexID => widget.indexID;

  FirebaseDBServices dbServices = FirebaseDBServices();

  String hoursLeft = '';
  String minutesLeft = '';
  String secondsLeft = '';

  String durationLeft = '';

  int chatCount = 0;
  late Duration leftOutDuration;

  String getUpdateDate() {
    return DateFormat('dd-MMM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(
        widget.item.postedAt.millisecondsSinceEpoch));
  }

  String getDescription() {
    int length = widget.item.description.length > 140
        ? 140
        : widget.item.description.length;
    return widget.item.description.substring(0, length);
  }

  double calculateLimit() {
    DateTime _itemDate = widget.item.updatedAt.toDate();
    Duration fromCurrentDate = DateTime.now().difference(_itemDate);
    leftOutDuration = Duration(hours: 24) - fromCurrentDate;
    List<String> splittedString =
        leftOutDuration.toString().split('.')[0].split(':');
    durationLeft = '${splittedString[0]}:${splittedString[1]}';
    return leftOutDuration.inHours.toDouble() / 24;
  }

  getChatCount() async {
    if (_isHistory) {
      chatCount =
          await dbServices.getNumberOfChat(widget.item.ownerId, _indexID!);
    }
    if (chatCount == null) {
      chatCount = 0;
    }
  }

  Color setBGLimitColor() {
    double limit = calculateLimit();
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

  @override
  void initState() {
    calculateLimit();
    getChatCount();
    super.initState();
  }

  deleteConfirmation() {
    Widget cancelBtn = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: TextNormal(
          text: LocaleKeys.cancel.tr(),
          textSize: 15,
        ));
    Widget deleteBtn = TextButton(
        onPressed: () async {
          await dbServices.moveToDeleteItem(widget.item, _indexID);
          Navigator.of(context).pop();
        },
        child: TextNormal(
          text: LocaleKeys.delete.tr(),
          textSize: 15,
          textColor: Colors.red,
        ));
    AlertDialog deleteDialog = AlertDialog(
      title: TextTitle(
        text: LocaleKeys.delete_confirm.tr(),
        textSize: 17,
      ),
      content: TextNormal(
        text: LocaleKeys.delete_confirm_message.tr(),
        textSize: 15,
      ),
      actions: [cancelBtn, deleteBtn],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return deleteDialog;
        });
  }

  reappearConfirmation() {
    Widget cancelBtn = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: TextNormal(
          text: LocaleKeys.cancel.tr(),
          textSize: 15,
        ));
    Widget confirmBtn = TextButton(
        onPressed: () async {
          await dbServices.reappearYardItem(_indexID);
          Navigator.of(context).pop();
          Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => HomeScreen(setIndex: 2),
              transitionDuration: Duration(milliseconds: 150),
              transitionsBuilder:
                  (_, Animation<double> animation, __, Widget child) {
                return Opacity(
                  opacity: animation.value,
                  child: child,
                );
              }));
        },
        child: TextNormal(
          text: LocaleKeys.confirm.tr(),
          textSize: 15,
          textColor: Colors.green,
        ));
    AlertDialog confirmDialog = AlertDialog(
      title: TextTitle(
        text: LocaleKeys.rebrodcast_confirmation.tr(),
        textSize: 17,
      ),
      content: TextNormal(
        text: LocaleKeys.rebrodcast_confirmation_msg.tr(),
        textSize: 15,
      ),
      actions: [cancelBtn, confirmBtn],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return confirmDialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, yardDetail,
            arguments: YardItemInfo(item: widget.item, isHistory: _isHistory));
      },
      child: InkWell(
        child: Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: SizeConfig.screenWidth / 4,
                    height: SizeConfig.screenWidth / 4,
                    child: Stack(
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: SizeConfig.screenWidth / 4,
                              height: SizeConfig.screenWidth / 4,
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/placeholder.jpeg',
                                imageErrorBuilder: (BuildContext context,
                                    Object obj, StackTrace? trace) {
                                  return Image.asset(
                                    "assets/placeholder.jpeg",
                                  );
                                },
                                image: _imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        widget.item.is_auction
                            ? Container(
                                width: 18,
                                height: 18,
                                margin: EdgeInsets.all(10),
                                child:
                                    Image.asset('assets/auction_indicator.png'),
                              )
                            : Container()
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TextTitle(
                            //   text: _productTitle,
                            //   textSize: 16,
                            // ),
                            Text(
                              getDescription(),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  // height: 21.8,

                                  color: Colors.black87),
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 10),

                            if (!_isHistory)
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                alignment: Alignment.centerLeft,
                                child: TextTitle(
                                  text: durationLeft,
                                  textColor: Colors.grey.shade500,
                                  textSize: 14,
                                ),
                              ),
                            if (!_isHistory)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: calculateLimit(),
                                  color: setBGLimitColor(),
                                  backgroundColor: Colors.grey.shade300,
                                  minHeight: 5,
                                ),
                              ),
                            Visibility(
                              visible: _isHistory,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible:
                                            (leftOutDuration.inMinutes <= 0 &&
                                                !widget.item.is_auction),
                                        child: InkWell(
                                          onTap: reappearConfirmation,
                                          child: Container(
                                              width: 117,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Color(0xFF006C9A)
                                                    .withOpacity(.1),
                                              ),
                                              child: Center(
                                                  child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                      'assets/upload.png'),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    LocaleKeys.reboradcast.tr(),
                                                    style: TextStyle(
                                                        color: Color(0xFF006C9A)
                                                            .withOpacity(.87),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  )
                                                ],
                                              ))),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(4),
                        child: Visibility(
                          visible: _isHistory,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: CircleAvatar(
                                  child: Image.asset('assets/trash.png'),
                                  backgroundColor:
                                      Color(0xFFB00020).withOpacity(.05),
                                ),
                                onTap: deleteConfirmation,
                              ),
                              SizedBox(
                                height: SizeConfig.screenWidth / 12,
                              ),
                              Visibility(
                                visible: chatCount > 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/message_chat.png'),
                                    TextTitle(
                                      text: chatCount > 0 ? '$chatCount' : '3',
                                      textSize: 10,
                                      textColor: Colors.black.withOpacity(.6),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
