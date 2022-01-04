class CommentsModel{
  String productId = "";
  String userId = "";
  String userName = "";
  DateTime commentDate = DateTime(2021);
  String? commentId = "";
  String comments = "";
  int? rateUseful = 0;
  CommentsModel({required this.productId, required this.userId, required this.userName,
  required this.commentDate, this.commentId,
  required this.comments,this.rateUseful});
}