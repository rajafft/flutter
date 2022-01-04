import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wean_app/models/appPreferencesModel.dart';
import 'package:wean_app/models/ratingsModel.dart';
import 'package:wean_app/services/firebaseServices.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  late AppPreferences preferences;
  PreferencesBloc() : super(PreferencesLoading());

  FirebaseDBServices firebaseDBServices = FirebaseDBServices();

  double ratingSum = 0.0;

  int ratingLength = 0;

  @override
  Stream<PreferencesState> mapEventToState(
    PreferencesEvent event,
  ) async* {
    if (event is GetPreferences) {
      yield PreferencesLoading();
      preferences = await firebaseDBServices.loadPreferences();
      firebaseDBServices.loadReview(FirebaseAuth.instance.currentUser!.uid);
      await getSumOfReview(FirebaseAuth.instance.currentUser!.uid);
      // print("rsum $ratingSum");
      yield PreferencesLoaded(
          preferences: preferences,
          ratingSum: ratingSum,
          ratingLength: ratingLength);
    } else if (event is PreferenceUpdateUI) {
      yield SettingsUIUpdated();
    }
  }

  Future<void> getSumOfReview(String ownerId) async {
    int counter = 0;
    FirebaseFirestore.instance
        .collection('ratings')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((data) {
      data.docs.forEach((element) {
        RatingsModel rate = RatingsModel.fromJson(element.data());
        counter += rate.rating!;
      });
      // print("totalRate $counter");
      // rateSum = counter/ratingsLength;
      ratingLength = data.docs.length;
      ratingSum = (counter.toDouble()) / ratingLength;
      // print("ratelengt $ratingLength");
    });
  }
}
