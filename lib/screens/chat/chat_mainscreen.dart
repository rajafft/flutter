import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wean_app/common/toastUtils.dart';
import 'package:wean_app/models/userModel.dart';
import 'package:wean_app/models/yardItemModel.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/widgets/textViews.dart';

import '../../common/appTheme.dart';
import '../../models/ConversationModel.dart';
import '../../models/chatItemModel.dart';
import '../../models/chatModel.dart';
import 'product_chat.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatMainScreen extends StatefulWidget {
  @override
  _ChatMainScreenState createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  List<ChatModel> chats = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference? reference;

  @override
  void initState() {
    addChat();
    getChatList();
    super.initState();
  }

  Stream<List<ConversationModel>> getChatList() {
    return FirebaseFirestore.instance
        .collection('conversations')
        .snapshots()
        .map<List<ConversationModel>>((event) {
      return event.docs
          .map<ConversationModel>((e) => ConversationModel.fromSnapshot(e))
          .toList();
    });
  }

  void addChat() {
    chats.add(ChatModel(
        chatRoomName: 'Ark Enterprise',
        chatId: '234567',
        clientProfileImage: '',
        lastChatMessage: 'Please send details of USB HardDisk',
        lastChatTime: DateTime.parse('2021-07-01 10:50:00.000'),
        items: [
          ChatItemModel(
              chatText: 'Hi',
              isSeller: false,
              chatTime: DateTime.parse('2021-07-01 10:45:00.000')),
          ChatItemModel(
              chatText: 'Thanks for contact us, how may I help you?',
              isSeller: true,
              chatTime: DateTime.parse('2021-07-01 10:46:00.000')),
          ChatItemModel(
              chatText: 'Please send details of USB HardDisk',
              isSeller: false,
              chatTime: DateTime.parse('2021-07-01 10:50:00.000'))
        ]));
    chats.add(ChatModel(
        chatRoomName: 'JJ Electronics',
        chatId: '234568',
        clientProfileImage: '',
        lastChatMessage: 'Product details send your whatsapp.',
        lastChatTime: DateTime.parse('2021-06-24 07:50:00.000'),
        items: [
          ChatItemModel(
              chatText: 'Hi',
              isSeller: false,
              chatTime: DateTime.parse('2021-06-24 07:45:00.000')),
          ChatItemModel(
              chatText: 'Please send details of Lenovo 7 Inch Tab',
              isSeller: false,
              chatTime: DateTime.parse('2021-06-24 07:46:00.000')),
          ChatItemModel(
              chatText:
                  'Thanks for contact JJ Electronics, can you please send your whatsapp number to send picture?',
              isSeller: true,
              chatTime: DateTime.parse('2021-06-24 07:47:00.000')),
          ChatItemModel(
              chatText: 'yeah sure, +971563899009',
              isSeller: false,
              chatTime: DateTime.parse('2021-06-24 07:47:00.000')),
          ChatItemModel(
              chatText: 'Product details send your whatsapp.',
              isSeller: true,
              chatTime: DateTime.parse('2021-06-24 07:50:00.000')),
        ]));
  }

  checkMessage(Map data) {
    // print("into the methoda checkMessage");
    if (data['ownerId'] == auth.currentUser!.uid) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey.shade200,
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.only(
              bottom: kBottomNavigationBarHeight,
            ),
            margin: const EdgeInsets.only(top: 80),
            child: StreamBuilder<List<ConversationModel>>(
                stream: getChatList(),
                builder: (context, snapshot) {
                  List<ConversationModel> list = [];

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          AppTheme.primaryColor,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    list.clear();
                    var sentByMe = snapshot.data!
                        .where((element) =>
                            element.senderId == auth.currentUser!.uid)
                        .toList();
                    // var sentByMe = snapshot.data!.docs.where((element) {
                    //   return (element.data() as Map)['senderId'] ==
                    //       auth.currentUser!.uid;
                    // });
                    var rcvToMe = snapshot.data!
                        .where((element) =>
                            element.ownerId == auth.currentUser!.uid)
                        .toList();
                    // var rcvToMe = snapshot.data!.docs.where((element) {
                    //   return (element.data() as Map)['ownerId'] ==
                    //       auth.currentUser!.uid;
                    // });

                    list.addAll(sentByMe);
                    list.addAll(rcvToMe);
                    if (list.length > 1) {
                      list.sort((a, b) {
                        return (b.lastMessageAt)!.compareTo(a.lastMessageAt!);
                      });
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20, left: 18.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              LocaleKeys.chats.tr(),
                              style: TextStyle(
                                color: AppTheme.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 30),
                              separatorBuilder: (context, index) {
                                return Divider(
                                  color: AppTheme.progressGrey,
                                  thickness: 1,
                                  indent: 20,
                                  endIndent: 20,
                                );
                              },
                              itemCount: list.length,
                              itemBuilder: (BuildContext context, int index) {
                                // context.read<ChatBloc>().add(FetchChat(list[index].id));
                                var conversationModel = list[index];
                                //Message received to me or on my product
                                if (conversationModel.senderId !=
                                    auth.currentUser!.uid) {
                                  return buildMessagesReceived(
                                      context, conversationModel, index);
                                } else {
                                  return buildSentMessages(
                                      conversationModel, index);
                                }
                              }),
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
                }),
          ),
        ],
      ),
    );
  }

  FutureBuilder<DocumentSnapshot<Object?>> buildSentMessages(
      ConversationModel conversationModel, int index) {
    return FutureBuilder<DocumentSnapshot>(
        future: conversationModel.productReference!.get(),
        builder: (context, productSnapshot) {
          if (productSnapshot.hasData && productSnapshot.data != null) {
            log(productSnapshot.data.toString(), name: 'product sent');
            YardItem? product;
            if (productSnapshot.data?.data() != null) {
              product = YardItem.fromDocumentSnapshot(productSnapshot.data!);
            }
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductChat(
                      chatReference: conversationModel.documentReference!,
                      sentById: conversationModel.ownerId,
                      isOwner: true,
                      isProductDeleted: product == null,
                    ),
                  ),
                );
              },
              child: FutureBuilder<QuerySnapshot>(
                future: conversationModel.documentReference!
                    .collection('messages')
                    .where('sentById',
                        isEqualTo:
                            conversationModel.ownerId == auth.currentUser!.uid
                                ? conversationModel.senderId
                                : conversationModel.ownerId)
                    .where('isRead', isEqualTo: false)
                    .get(),
                builder: (_, msgSnapshot) {
                  if (product != null) {
                    return ConversationTile(
                        isOwner: true,
                        senderName: LocaleKeys.waen_user.tr(),
                        description: product.description,
                        mediaList: product.media,
                        lastMessageAt: conversationModel.lastMessageAt,
                        lastMessage: conversationModel.lastMessage,
                        isUnread: msgSnapshot.hasData &&
                            msgSnapshot.data!.docs.isNotEmpty,
                        isProductDeleted: false,
                        index: index,
                        conversationModel: conversationModel);
                  } else {
                    return ConversationTile(
                      isOwner: true,
                      senderName: LocaleKeys.waen_user.tr(),
                      description: product?.description,
                      mediaList: product?.media,
                      lastMessageAt: conversationModel.lastMessageAt,
                      lastMessage: conversationModel.lastMessage,
                      isUnread: msgSnapshot.hasData &&
                          msgSnapshot.data!.docs.isNotEmpty,
                      isProductDeleted: true,
                      conversationModel: conversationModel,
                      index: index,
                    );
                  }
                },
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        });
  }

  Widget buildMessagesReceived(
      BuildContext context, ConversationModel conversationModel, int index) {
    return FutureBuilder<DocumentSnapshot>(
        future: conversationModel.productReference!.get(),
        builder: (context, productSnapshot) {
          if (productSnapshot.hasData && productSnapshot.data != null) {
            YardItem? product;
            if (productSnapshot.data?.data() != null) {
              product = YardItem.fromDocumentSnapshot(productSnapshot.data!);
            }
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductChat(
                        chatReference: conversationModel.documentReference!,
                        sentById: conversationModel.senderId,
                        isOwner: false,
                        isProductDeleted: product == null,
                      ),
                    ));
              },
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(conversationModel.senderId)
                    .get(),
                builder: (_, senderSnapshot) {
                  if (senderSnapshot.hasData) {
                    UserModel user =
                        UserModel.fromDocSnapshot(senderSnapshot.data!);
                    log(user.toJson().toString(), name: "userModel");
                    return FutureBuilder<QuerySnapshot>(
                        future: conversationModel.documentReference!
                            .collection('messages')
                            .where('sentById',
                                isEqualTo: conversationModel.ownerId ==
                                        auth.currentUser!.uid
                                    ? conversationModel.senderId
                                    : conversationModel.ownerId)
                            .where('isRead', isEqualTo: false)
                            .get(),
                        builder: (_, msgSnapshot) {
                          if (product != null) {
                            return ConversationTile(
                                isOwner: false,
                                senderName: user.name ?? LocaleKeys.no_name.tr(),
                                lastMessageAt: conversationModel.lastMessageAt,
                                lastMessage: conversationModel.lastMessage,
                                isUnread: msgSnapshot.hasData &&
                                    msgSnapshot.data!.docs.isNotEmpty,
                                description: product.description,
                                photoUrl: user.photoUrl ?? '',
                                mediaList: product.media,
                                isProductDeleted: false,
                                index: index,
                                conversationModel: conversationModel);
                          } else {
                            return ConversationTile(
                                isOwner: false,
                                senderName: user.name ?? LocaleKeys.no_name.tr(),
                                lastMessageAt: conversationModel.lastMessageAt,
                                lastMessage: conversationModel.lastMessage,
                                isUnread: msgSnapshot.hasData &&
                                    msgSnapshot.data!.docs.isNotEmpty,
                                description: product?.description,
                                photoUrl: user.photoUrl ?? '',
                                mediaList: product?.media,
                                isProductDeleted: true,
                                index: index,
                                conversationModel: conversationModel);
                          }
                        });
                  } else {
                    return Container();
                  }
                },
              ),
            );
          } else {
            log('else', name: "check");
            return SizedBox.shrink();
          }
        });
  }
}

class ConversationTile extends StatelessWidget {
  ConversationTile({Key? key,
    this.lastMessage,
    this.lastMessageAt,
    required this.senderName,
    required this.isUnread,
    required this.isProductDeleted,
    this.description,
    this.mediaList,
    required this.isOwner,
    required this.index,
    required this.conversationModel,
    this.photoUrl,
  }) : super(key: key);

  final FirebaseAuth auth = FirebaseAuth.instance;
  final String? description;
  final bool isOwner;
  final bool isUnread;
  final bool isProductDeleted;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final List? mediaList;
  final String? photoUrl;
  final String senderName;
  final int index;
  final ConversationModel conversationModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: isOwner || photoUrl!.isEmpty
              ? CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage(
                    "assets/profile_ph.jpeg",
                  ),
                )
              : CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(
                    photoUrl!,
                  ),
                ),
          horizontalTitleGap: 5,
          title: Text(
            senderName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            lastMessage ?? '',
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
          trailing: Text(
            lastMessageAt == null
                ? ''
                : DateTime.now().difference(lastMessageAt!).inHours >= 24
                    ? DateFormat('dd-MM-yyyy').format(lastMessageAt!)
                    : DateFormat.jm().format(lastMessageAt!),
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 12,
            ),
          ),
        ),
        if (description != null && mediaList != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i in mediaList!.length > 3
                    ? mediaList!.sublist(0, 3)
                    : mediaList!)
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: PhotoView(
                              tightMode: true,
                              imageProvider: NetworkImage(i),
                              heroAttributes: const PhotoViewHeroAttributes(
                                tag: "someTag",
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          image: NetworkImage(i),
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: 35,
                      width: 35,
                    ),
                  ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    description ?? "",
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: TextTitle(text: LocaleKeys.delete_chat.tr()),
                          content: TextNormal(
                              text:
                                  LocaleKeys.delete_chat_msg.tr()),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: TextNormal(
                                text: LocaleKeys.cancel.tr(),
                                textColor: Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                conversationModel.documentReference
                                    ?.delete()
                                    .then((value) {
                                  Toast.showSuccess(
                                      LocaleKeys.chat_deleted_msg.tr());

                                  Navigator.pop(context);
                                });
                              },
                              child: TextNormal(
                                text: LocaleKeys.delete.tr(),
                                textColor: Colors.red,
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    child: Image.asset('assets/trash.png'),
                    backgroundColor: Color(0xFFB00020).withOpacity(.05),
                  ),
                )
              ],
            ),
          ),
        if (description == null && mediaList == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
            child: Row(
              children: [
                Text(
                  LocaleKeys.product_expired_msg.tr(),
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: TextTitle(text: LocaleKeys.delete_chat.tr()),
                          content: TextNormal(
                              text:
                                  LocaleKeys.delete_chat_msg.tr()),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: TextNormal(
                                text: LocaleKeys.cancel.tr(),
                                textColor: Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                conversationModel.documentReference
                                    ?.delete()
                                    .then((value) {
                                  Toast.showSuccess(
                                      LocaleKeys.chat_deleted_msg.tr());

                                  Navigator.pop(context);
                                });
                              },
                              child: TextNormal(
                                text: 'Delete',
                                textColor: Colors.red,
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    child: Image.asset('assets/trash.png'),
                    backgroundColor: Color(0xFFB00020).withOpacity(.05),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
}
