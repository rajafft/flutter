import 'package:cloud_firestore/cloud_firestore.dart';

class RatingsModel{
  String? ownerId;
  String? buyerId;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  int? rating;
  String? buyerReview;
  DocumentReference? documentReference;

  RatingsModel({this.ownerId,
  this.buyerId,
  this.createdAt,
  this.updatedAt,
  this.rating,
  this.buyerReview,});

  factory RatingsModel.fromJson(Map<String, dynamic> json) => RatingsModel(
    ownerId: json["ownerId"],
    buyerId: json["buyerId"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    rating: json["rating"],
    buyerReview: json["buyerReview"],
  );

  factory RatingsModel.fromSnapshot(QueryDocumentSnapshot snapshot){
    RatingsModel model = RatingsModel.fromJson(snapshot.data() as Map<String, dynamic>);
    model.documentReference = snapshot.reference;
    return model;
  }

  Map<String, dynamic> toJson()=> {
    'ownerId': ownerId,
    'buyerId': buyerId,
    'createdAt':createdAt,
    'updatedAt':updatedAt,
    'rating': rating,
    'buyerReview': buyerReview,
  };

}