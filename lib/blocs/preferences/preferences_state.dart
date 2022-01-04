part of 'preferences_bloc.dart';

abstract class PreferencesState extends Equatable {
  const PreferencesState();
  @override
  List<Object> get props => [];
}

class PreferencesLoading extends PreferencesState {
}

class PreferencesLoaded extends PreferencesState {
  final AppPreferences preferences;
  final double ratingSum;
  final int ratingLength;

  PreferencesLoaded({required this.preferences, required this.ratingSum, required this.ratingLength});

  @override
  List<Object> get props => [this.preferences, this.ratingSum, this.ratingLength];
}

class SettingsUIUpdated extends PreferencesState{

}

