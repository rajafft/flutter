import 'dart:convert';

enum NotificationType { CHAT, BID }

class NotificationData {
  NotificationData({
    required this.type,
    this.productId,
    this.chatId,
  });

  factory NotificationData.fromJson(String source) =>
      NotificationData.fromMap(json.decode(source));

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      type:
          map['type'] == 'chat' ? NotificationType.CHAT : NotificationType.BID,
      productId: map['productId'] ?? '',
      chatId: map['chatId'] ?? '',
    );
  }

  String? chatId;
  String? productId;
  NotificationType type;

  Map<String, dynamic> toMap() {
    return {
      'type': type == NotificationType.CHAT ? 'chat' : 'bid',
      'productId': productId,
      'chatId': chatId,
    };
  }

  String toJson() => json.encode(toMap());
}
