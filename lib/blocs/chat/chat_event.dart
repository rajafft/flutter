part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
}

class FetchChat extends ChatEvent {
  final String chatRoomId;

  FetchChat(this.chatRoomId);

  @override
  List<Object?> get props => [];
}
class SendMessage extends ChatEvent {
  final String chatRoomId;
  final Map<String, dynamic> data;

  SendMessage(this.chatRoomId, this.data);
  @override
  List<Object?> get props => [];
}