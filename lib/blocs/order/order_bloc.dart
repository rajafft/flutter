import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wean_app/blocs/order/order_event.dart';
import 'package:wean_app/blocs/order/order_state.dart';
import 'package:wean_app/models/appPreferencesModel.dart';
import 'package:wean_app/models/yardItemModel.dart';
import 'package:wean_app/services/firebaseServices.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState>{

  OrderBloc(): super(OrderInitial());

  OrderState get initState => OrderInitial();

  FirebaseDBServices dbServices = FirebaseDBServices();

  @override
  Stream<OrderState> mapEventToState(OrderEvent event) async*{
    if(event is GetPrefs){
      yield OrderLoading();
      AppPreferences preferences = await dbServices.loadPreferences();
      yield OrderPrefLoaded(preferences: preferences);
    }else if(event is UploadImages){
      yield OrderLoading();
      List<String> imageUrls = [];
      await uploadImages(event.files, imageUrls);
      yield OrderImagesUploaded(imageUrls: imageUrls);
    }else if(event is DeleteImages){
      yield OrderLoading();
      await deleteImages(event.files);
      yield OrderImageDeleted();
    }else if(event is UploadOrder){
      yield OrderLoading();
      await uploadOrder(event.item);
      yield OrderUploaded();
    }else if(event is UpdateAskUI){
      yield OrderUIUpdated();
    }
  }

  Future<String> uploadFile(File _image) async {
    String imageUrls = '';
    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('items/${_image.path
        .split('/')
        .last}');
    firebase_storage.UploadTask uploadTask = storageReference.putFile(_image);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    await taskSnapshot.ref.getDownloadURL().then((value) {
      // print("url $value");
      imageUrls = value;
    });
    return imageUrls;
  }

  Future<bool> uploadImages(List<File> files, List<String> urls) async{
    await Future.forEach(files, (File element) async {
      String returnUrl = await uploadFile(element);
      urls.add(returnUrl);
      if(files.length==urls.length){
        return true;
      }
    });
    return false;
  }

  Future<void> deleteImages(List<String> urls) async{
    urls.map((e) async{
      await firebase_storage.FirebaseStorage.instance.refFromURL(e).delete();
    }).toList();
  }

  Future<void> uploadOrder(YardItem item) async{
    await dbServices.addOrder(item);
  }


}