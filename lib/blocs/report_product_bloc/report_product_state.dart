part of 'report_product_bloc.dart';

abstract class ReportProductState extends Equatable {
  const ReportProductState();
  
  @override
  List<Object> get props => [];
}

class ReportProductInitial extends ReportProductState {}

class ReportProductProgress extends ReportProductState {}

class ReportProductSuccess extends ReportProductState {}

class ReportProductFailure extends ReportProductState {}
