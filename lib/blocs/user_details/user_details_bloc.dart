import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wean_app/services/firebaseServices.dart';

part 'user_details_event.dart';
part 'user_details_state.dart';

class UserDetailsBloc extends Bloc<UserDetailsEvent, UserDetailsState> {
  UserDetailsBloc() : super(UserDetailsInitial());

  @override
  Stream<UserDetailsState> mapEventToState(
    UserDetailsEvent event,
  ) async* {
    if (event is SubmitUserDetails) {
      try {
        yield UserDetailsProgress();
        await FirebaseDBServices().submitUserDetails(
            /* image: event.image, */ data: event.data, uid: event.uid);
        yield UserDetailsSuccess();
      } catch (e) {
        throw e;
        yield UserDetailsFailure();
      }
    }
  }
}
