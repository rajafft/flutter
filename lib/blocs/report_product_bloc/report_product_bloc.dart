import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wean_app/services/firebaseServices.dart';

part 'report_product_event.dart';
part 'report_product_state.dart';

class ReportProductBloc extends Bloc<ReportProductEvent, ReportProductState> {
  ReportProductBloc() : super(ReportProductInitial()) {
    on<ReportProduct>((event, emit) async {
      emit(ReportProductProgress());
      final data = await FirebaseDBServices().reportProduct(event.data);
      if (data != null) {
        emit(ReportProductSuccess());
      } else {
        ReportProductFailure();
      }
    });
  }
}
