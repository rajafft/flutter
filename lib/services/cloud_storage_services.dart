import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';


class CloudStorageServices {

  FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file) async {
    var response =
        await storage.ref('profilesImages').child(file.path.split('/').last).putFile(file);
    String url = await response.ref.getDownloadURL();
    return url;
  }

  Future<String> uploadChatFile(File file, String path) async {
    try {
      var response = await storage.ref('chats').child(path).putFile(file);
      String url = await response.ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      // print(e.message);
      return e.message.toString();
    }
  }
}
