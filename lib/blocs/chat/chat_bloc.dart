import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:wean_app/services/firebaseServices.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial());

  Stream<QuerySnapshot>? chatStream;
  @override
  Stream<ChatState> mapEventToState(
    ChatEvent event,
  ) async* {
    if(event is FetchChat) {
      try {
        yield ChatFetchProgress();
        chatStream = FirebaseDBServices().fetchChat(event.chatRoomId);
        yield ChatFetchSuccess(chatStream!);
      } catch (e) {
        // print(e);
        yield ChatFetchFailure();
      }
    } else if(event is SendMessage) {
      try {
        yield ChatSendProgress();
        final messageDocRef = await FirebaseDBServices().sendMessage(event.chatRoomId, event.data);
        yield ChatSendSuccess(messageDocRef);
        yield ChatFetchSuccess(chatStream!);
      } catch (e) {
        // print(e);
        yield ChatSendFailure();
      }
    }
  }
}
