import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'yard_state.dart';

class YardCubit extends Cubit<YardState> {
  YardCubit() : super(YardList());

  void toggleYardMode() {
    if (state is YardList) {
      emit(YardGrid());
    } else {
      emit(YardList());
    }
  }
}
