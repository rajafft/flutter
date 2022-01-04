part of 'user_details_bloc.dart';

abstract class UserDetailsEvent extends Equatable {
  const UserDetailsEvent();
}

class SubmitUserDetails extends UserDetailsEvent {
  // final File image;
  final Map<String,dynamic> data;
  final String uid;

  SubmitUserDetails(/* this.image, */ this.data, this.uid);

  @override
  List<Object?> get props => [];
}





