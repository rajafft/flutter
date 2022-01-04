part of 'report_product_bloc.dart';

abstract class ReportProductEvent extends Equatable {
  const ReportProductEvent();

  @override
  List<Object> get props => [];
}

class ReportProduct extends ReportProductEvent {
  final Map<String, dynamic> data;

  ReportProduct(this.data);
}
