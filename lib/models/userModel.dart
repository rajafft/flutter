// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel({
    this.address,
    this.phone,
    this.name,
    this.rating,
    this.ratings,
    this.photoUrl,
    this.fcmTokens,
    this.items,
    this.uuid,
    this.email,
    this.selectedCategory,
    this.selectedCountry,
    this.selectedLanguage,
    this.showYardNotification,
    this.showChatNotification,
  });

  String? address;
  String? phone;
  String? name;
  int? rating;
  List<String>? ratings;
  String? photoUrl;
  List<dynamic>? fcmTokens;
  List<dynamic>? items;
  String? uuid;
  String? email;
  List<String>? selectedCategory;
  String? selectedCountry;
  String? selectedLanguage;
  bool? showYardNotification;
  bool? showChatNotification;
  DocumentReference? documentReference;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        address: json["address"],
        phone: json["phone"],
        name: json["name"],
        rating: json["rating"],
        ratings: List<String>.from((json["ratings"] ?? []).map((x) => x)),
        photoUrl: json["photo_url"],
        fcmTokens: List<dynamic>.from(json["FCM Tokens"].map((x) => x)),
        items: List<dynamic>.from(json["items"].map((x) => x)),
        uuid: json["uuid"],
        email: json["email"],
        selectedCategory:
            List<String>.from(json["selectedCategory"].map((x) => x)),
        selectedCountry: json["selectedCountry"],
        selectedLanguage: json["selectedLanguage"],
        showYardNotification: json["showYardNotification"],
        showChatNotification: json["showChatNotification"],
      );

  factory UserModel.fromSnapshot(QuerySnapshot snapshot) {
    UserModel department =
        UserModel.fromJson(snapshot.docs[0].data() as Map<String, dynamic>);
    department.documentReference = snapshot.docs[0].reference;
    return department;
  }

  factory UserModel.fromDocSnapshot(DocumentSnapshot snapshot) {
    UserModel department =
        UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
    department.documentReference = snapshot.reference;
    return department;
  }

  Map<String, dynamic> toJson() => {
        "address": address,
        "phone": phone,
        "name": name,
        "rating": rating,
        "ratings": List<String>.from(ratings!.map((x) => x)),
        "photo_url": photoUrl,
        "FCM Tokens": List<dynamic>.from(fcmTokens!.map((x) => x)),
        "items": List<dynamic>.from(items!.map((x) => x)),
        "uuid": uuid,
        "email": email,
        "selectedCategory": List<String>.from(selectedCategory!.map((x) => x)),
        "selectedCountry": selectedCountry,
        "selectedLanguage": selectedLanguage,
        "showYardNotification": showYardNotification,
        "showChatNotification": showChatNotification,
      };
}
