import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:wean_app/models/yardItemModel.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class GetPrefs extends OrderEvent {
  GetPrefs();
  @override
  List<Object> get props => [];
}

class UploadImages extends OrderEvent {
  final List<File> files;
  UploadImages({required this.files});

  @override
  List<Object> get props => [files];
}

class DeleteImages extends OrderEvent {
  final List<String> files;
  DeleteImages({required this.files});

  @override
  List<Object> get props => [files];
}

class UploadOrder extends OrderEvent {
  final YardItem item;
  UploadOrder({required this.item});

  @override
  List<Object> get props => [item];
}

class UpdateAskUI extends OrderEvent {
  UpdateAskUI();

  @override
  List<Object> get props => [];
}
