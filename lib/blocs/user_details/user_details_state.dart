part of 'user_details_bloc.dart';

abstract class UserDetailsState extends Equatable {
  const UserDetailsState();
}

class UserDetailsInitial extends UserDetailsState {
  @override
  List<Object> get props => [];
}

class UserDetailsProgress extends UserDetailsState {
  @override
  List<Object> get props => [];
}

class UserDetailsSuccess extends UserDetailsState {
  @override
  List<Object> get props => [];
}

class UserDetailsFailure extends UserDetailsState {
  @override
  List<Object> get props => [];
}
