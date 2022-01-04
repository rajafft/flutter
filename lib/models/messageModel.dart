// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  MessageModel(
      {this.dateTime,
      required this.isRead,
      this.message,
      required this.sentById});

  DateTime? dateTime;
  bool isRead;
  String? message;
  String sentById;
  DocumentReference? documentReference;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        isRead: json["isRead"],
        dateTime: json["dateTime"],
        message: json["message"],
        sentById: json["sentById"],
      );

  factory MessageModel.fromSnapshot(QueryDocumentSnapshot snapshot) {
    MessageModel conversation =
        MessageModel.fromJson(snapshot.data() as Map<String, dynamic>);
    conversation.documentReference = snapshot.reference;
    return conversation;
  }

  // Map<String, dynamic> toJson() => {
  //       "lastMessage": lastMessage,
  //       "lastMessageAt": lastMessageAt,
  //       "ownerId": ownerId,
  //       "productId": productId,
  //       "productReference": productReference,
  //       "senderId Tokens": senderId,
  //       "senderName": senderName,
  //     };
}
