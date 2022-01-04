import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:wean_app/services/firebaseServices.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc() : super(ConversationInitial());

  @override
  Stream<ConversationState> mapEventToState(
    ConversationEvent event,
  ) async* {
    if (event is CreateConversation) {
      try {
        yield ConversationCreationProgress();
        final documentReference = await FirebaseDBServices().createConversation(
          event.productId,
          event.ownerId,
          event.senderId,
          event.ownerName,
          event.senderName,
          event.productReference,
        );
        yield ConversationCreationSuccess(documentReference);
      } catch (e) {
        // print(e);
        yield ConversationCreationFailure();
      }
    }
  }
}
