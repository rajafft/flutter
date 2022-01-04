part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();
}

class CreateConversation extends ConversationEvent {
  final String ownerId, productId, senderId, senderName, ownerName;
  final DocumentReference productReference;

  CreateConversation(this.ownerId, this.ownerName, this.productId,
      this.senderId, this.senderName, this.productReference);

  @override
  List<Object?> get props => [];
}
