import 'package:wean_app/models/chatItemModel.dart';

class ChatModel{
  String chatRoomName = "";
  String chatId = "";
  String clientProfileImage = "";
  String lastChatMessage = "";
  DateTime lastChatTime = DateTime(2021);
  List<ChatItemModel>? items= [];
  ChatModel({required this.chatRoomName, required this.chatId,
  required this.clientProfileImage, required this.lastChatMessage,
  required this.lastChatTime, this.items});
}