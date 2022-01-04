// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

ConversationModel userModelFromJson(String str) =>
    ConversationModel.fromJson(json.decode(str));

String userModelToJson(ConversationModel data) => json.encode(data.toJson());

class ConversationModel {
  ConversationModel(
      {this.lastMessage,
      this.lastMessageAt,
      this.ownerId,
      this.productId,
      this.productReference,
      this.senderId,
      this.senderName,
      this.isProductDeleted,
      this.ownerName});

  String? lastMessage;
  String? ownerName;
  DateTime? lastMessageAt;
  String? ownerId;
  String? productId;
  DocumentReference? productReference;
  String? senderId;
  String? senderName;
  bool? isProductDeleted;
  DocumentReference? documentReference;

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        lastMessage: json["lastMessage"] == null ? null : json["lastMessage"],
        lastMessageAt: json['lastMessageAt'] == null
            ? null
            : (json["lastMessageAt"] as Timestamp).toDate(),
        ownerId: json["ownerId"],
        ownerName: json["ownerName"],
        productId: json["productId"],
        productReference: json["productReference"],
        senderId: json["senderId"],
        senderName: json["senderName"],
        isProductDeleted: json["isProductDeleted"]
      );

  factory ConversationModel.fromSnapshot(QueryDocumentSnapshot snapshot) {
    ConversationModel conversation =
        ConversationModel.fromJson(snapshot.data() as Map<String, dynamic>);
    conversation.documentReference = snapshot.reference;
    return conversation;
  }

  factory ConversationModel.fromDocSnapshot(DocumentSnapshot snapshot) {
    ConversationModel conversation =
        ConversationModel.fromJson(snapshot.data() as Map<String, dynamic>);
    conversation.documentReference = snapshot.reference;
    return conversation;
  }

  Map<String, dynamic> toJson() => {
        "lastMessage": lastMessage,
        "lastMessageAt": lastMessageAt,
        "ownerId": ownerId,
        "productId": productId,
        "productReference": productReference,
        "senderId Tokens": senderId,
        "senderName": senderName,
        "isProductDeleted":isProductDeleted
      };
}
