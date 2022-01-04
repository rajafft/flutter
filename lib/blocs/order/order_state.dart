import 'package:equatable/equatable.dart';
import 'package:wean_app/models/appPreferencesModel.dart';

abstract class OrderState extends Equatable{
  const OrderState();
  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState{}

class OrderLoading extends OrderState{}

class OrderPrefLoaded extends OrderState{
  final AppPreferences preferences;
  OrderPrefLoaded({required this.preferences});
  @override
  List<Object> get props => [preferences];
}

class OrderImagesUploaded extends OrderState{
  final List<String> imageUrls;
  OrderImagesUploaded({required this.imageUrls});
  @override
  List<Object> get props => [imageUrls];
}

class OrderImageDeleted extends OrderState{}

class OrderUploaded extends OrderState{

}

class OrderError extends OrderState{
  final String error;
  OrderError({required this.error});
  @override
  List<Object> get props => [error];
}

class OrderUIUpdated extends OrderState{}