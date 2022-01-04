import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:wean_app/models/productModel.dart';
import 'package:wean_app/models/sellerModel.dart';

class YardItemModel {
  String? imageUrl = "";
  List<String>? imagesUrl = [];
  String title = "";
  String? shortDescription = "";
  String description = "";
  DateTime createdDate = DateTime.utc(2021, 1, 1);
  DateTime lastUpdated = DateTime(2021);
  String sellerName = "";
  String sellerAddress = "";
  String? sellerUrl = "";
  String? sellerPhone = "";
  int? numberOfFavorites = 0;

  YardItemModel({
    this.imageUrl,
    this.imagesUrl,
    required this.title,
    this.shortDescription,
    required this.description,
    required this.createdDate,
    required this.lastUpdated,
    required this.sellerName,
    required this.sellerAddress,
    this.sellerUrl,
    this.sellerPhone,
    this.numberOfFavorites,
  });
}

class YardModel {
  late ProductModel item;
  late SellerModel sellerInfo;

  YardModel({required this.item, required this.sellerInfo});
}

class YardItem extends Equatable {
  YardItem(
      {required this.ownerId,
      required this.name,
      required this.item_live,
      required this.description,
      required this.postedAt,
      required this.updatedAt,
      required this.media,
      required this.category,
        required this.city,
      required this.country, required this.is_auction, this.current_bid, this.starting_bid});

  final String ownerId;
  final String name;
  final bool item_live;
  final String description;
  final Timestamp postedAt;
  final Timestamp updatedAt;
  final List<String> media;
  final String category;
  final String city;
  final String country;
  final bool is_auction;
  final double? current_bid;
  final double? starting_bid;

  DocumentReference? documentReference;

  @override
  List<Object> get props =>
      [ownerId, name, item_live, description, postedAt, updatedAt, media];

  Map<String, dynamic> toJson() => {
        'description': description,
        'name': name,
        'is_live': item_live,
        'ownerId': ownerId,
        'posted_at': postedAt,
        'updated_at': updatedAt,
        'media': List<dynamic>.from(media.map((x) => x)),
        'category': category,
        'country': country,
        'city': city,
        'is_auction': is_auction,
        'current_bid': current_bid,
        'starting_bid': starting_bid
      };

  factory YardItem.fromSnapshot(QueryDocumentSnapshot snapshot) {
    YardItem item = YardItem.fromJson(snapshot.data() as Map<String,dynamic>);
    item.documentReference = snapshot.reference;
    return item;
  }

  factory YardItem.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    YardItem item = YardItem.fromJson(snapshot.data() as Map<String,dynamic>);
    item.documentReference = snapshot.reference;
    return item;
  }

  factory YardItem.fromJson(Map<String, dynamic> json) {
    var dynamicLst = json['media'] as List;
    List<String> imgs = [];
    for (var img in dynamicLst) {
      imgs.add(img.toString());
    }
    return YardItem(
      description: json['description'],
      media: imgs,
      name: json['name'],
      postedAt: json['posted_at'],
      updatedAt: json['updated_at'],
      item_live: json['is_live'],
      ownerId: json['ownerId'],
      category: json['category'],
      country: json['country'],
      city: json['city'] == null ? '' : json['city'],
      is_auction: json['is_auction'] == null ? false : json['is_auction'],
      current_bid: json['current_bid'],
      starting_bid: json['starting_bid']
    );
  }
}

class YardItemInfo {
  YardItemInfo({required this.item, required this.isHistory});

  final YardItem item;
  final bool isHistory;
}
