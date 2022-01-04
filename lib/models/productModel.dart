class ProductModel {
  List<String>? imagesUrl = [];
  String? productId = "";
  String productName = "";
  String? shortDescription = "";
  String description = "";
  String productCategory = "";
  String productType = "";
  DateTime createdDate = DateTime.utc(2021, 1, 1);
  DateTime lastUpdated = DateTime(2021);
  DateTime validUntil = DateTime.now().add(Duration(hours: 48));
  double? productRating = 0.0;
  int? totalComments = 0;
  //constructor
  ProductModel({
    this.imagesUrl,
    this.productId,
    required this.productName,
    this.shortDescription,
    required this.description,
    required this.productCategory,
    required this.productType,
    required this.createdDate,
    required this.lastUpdated,
    required this.validUntil,
    this.productRating,
    this.totalComments,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var dynamicLst = json['media'] as List;
    List<String> imgs = [];
    for (var img in dynamicLst) {
      imgs.add(img.toString());
    }
    return ProductModel(
      productCategory: json['categoryId'],
      description: json['description'],
      // imagesUrl: json['media'],
      imagesUrl: imgs,
      productName: json['item_name'],
      createdDate: json['posted_at'].toDate(),
      lastUpdated: json['posted_at'].toDate(),
      validUntil: json['posted_at'].toDate(),
      productType: json['categoryId'],
      totalComments: 0,
      productId: null,
      productRating: 5,
    );
  }
}
