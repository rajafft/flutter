part of 'yard_cubit.dart';

abstract class YardState extends Equatable {
  const YardState();

  @override
  List<Object> get props => [];
}

class YardList extends YardState {}

class YardGrid extends YardState {}
