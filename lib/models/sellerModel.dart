class SellerModel{
  String? sellerId = "";
  String? profileImage = "";
  String sellerName = "";
  String sellerPhone = "";
  String sellerEmail = "";
  String sellerAddress = "";
  String? sellerUrl = "";
  double? sellerRating = 0.0;
  SellerModel({this.sellerId, this.profileImage,
  required this.sellerName, required this.sellerPhone,
  required this.sellerEmail, required this.sellerAddress,
  this.sellerUrl, this.sellerRating});
}