part of 'conversation_bloc.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();
}

class ConversationInitial extends ConversationState {
  @override
  List<Object> get props => [];
}

class ConversationCreationProgress extends ConversationState {
  @override
  List<Object> get props => [];
}

class ConversationCreationSuccess extends ConversationState {
  final DocumentReference documentReference;

  ConversationCreationSuccess(this.documentReference);

  @override
  List<Object> get props => [];
}

class ConversationCreationFailure extends ConversationState {
  @override
  List<Object> get props => [];
}
