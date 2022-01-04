part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();
}

class ChatInitial extends ChatState {
  @override
  List<Object> get props => [];
}
class ChatFetchProgress extends ChatState {
  @override
  List<Object> get props => [];
}
class ChatFetchSuccess extends ChatState {
  final Stream<QuerySnapshot> chatStream;

  ChatFetchSuccess(this.chatStream);
  @override
  List<Object> get props => [];
}

class ChatFetchFailure extends ChatState {
  @override
  List<Object> get props => [];
}

class ChatSendSuccess extends ChatState {
  final DocumentReference messageDocRef;

  ChatSendSuccess(this.messageDocRef);

  @override
  List<Object> get props => [];
}
class ChatSendProgress extends ChatState {
  @override
  List<Object> get props => [];
}
class ChatSendFailure extends ChatState {
  @override
  List<Object> get props => [];
}

