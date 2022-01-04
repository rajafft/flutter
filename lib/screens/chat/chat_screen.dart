import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/models/chatItemModel.dart';
import 'package:wean_app/models/chatModel.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/widgets/textViews.dart';
import 'package:easy_localization/src/public_ext.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel model;
  const ChatScreen({required this.model});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String get _sellerName => widget.model.chatRoomName;
  final messageTextController = TextEditingController();
  List<ChatItemModel>? get _chats => widget.model.items;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBar(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0.0,
              centerTitle: false,
              automaticallyImplyLeading: true,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: AppTheme.white,
                ),
              ),
              title: TextTitle(
                text: _sellerName,
                textSize: 18,
                textColor: AppTheme.white,
              ),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    itemBuilder: (context, index) {
                      ChatItemModel currentData = _chats![index];
                      return Padding(
                        padding: const EdgeInsets.all(2),
                        child: Column(
                          crossAxisAlignment: currentData.isSeller
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            //seller
                            Visibility(
                              child: Material(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(30.0),
                                  bottomRight: Radius.circular(30.0),
                                  topRight: Radius.circular(30.0),
                                ),
                                elevation: 5.0,
                                color: Colors.grey.shade300,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: TextNormal(
                                    text: currentData.chatText,
                                    textColor: Colors.black,
                                    textSize: 14,
                                  ),
                                ),
                              ),
                              visible: currentData.isSeller,
                            ),
                            //user
                            Visibility(
                              child: Material(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30.0),
                                  bottomLeft: Radius.circular(30.0),
                                  bottomRight: Radius.circular(30.0),
                                ),
                                elevation: 5.0,
                                color: Colors.green.shade700,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: TextNormal(
                                    text: currentData.chatText,
                                    textSize: 14,
                                    textColor: Colors.white,
                                  ),
                                ),
                              ),
                              visible: !currentData.isSeller,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 4, 4, 4),
                              child: TextNormal(
                                text: DateFormat('hh:mm a')
                                    .format(currentData.chatTime),
                                textSize: 12,
                                textColor: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 25,
                      );
                    },
                    itemCount: _chats!.length,
                  ),
                ),
              ),
              Divider(
                height: 1,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.primaryColor, width: 2.0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(
                          color: AppTheme.black,
                          fontSize: 16,
                        ),
                        maxLength: 145,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          hintText: LocaleKeys.type_in_msg.tr(),
                          border: InputBorder.none,
                        ),
                        autofocus: false,
                        onSubmitted: (value) {},
                        onChanged: (value) {},
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.send,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    )
                  ],
                ),
              )
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
