import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:images_picker/images_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ImagePickerServices {
  Future<List<Media?>?> pickImage() async {
    var images = await ImagesPicker.pick(
      pickType: PickType.image,
      gif: false,
      count: 1,
    );
    return images;
  }

  List<String> imagesExtensions = ['jpeg', 'jpg', 'png', 'gif'];
  List<String> videosExtensions = ['mp4', 'mkv', 'avi', 'mpg3', 'mpeg3'];
  List<String> documentsExtensions = [
    'pdf',
    'docx',
    'xml',
    'ppt',
    'txt',
    'xlsx'
  ];

  String checkFileType(String fileExtension) {
    if (imagesExtensions.contains(fileExtension)) {
      return 'IMAGE';
    } else if (videosExtensions.contains(fileExtension)) {
      return 'VIDEO';
    } else if (documentsExtensions.contains(fileExtension)) {
      return 'DOCUMENT';
    } else
      return 'OTHERS';
  }

  Future<void> storeMsgToListTillSent(String key, String msg) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, msg);
  }

  Future<List<String>> getTempMessages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final msgsList = prefs.getStringList('TEMP_MSG_LIST');
    return msgsList!;
  }

  Future<String?> tempFilePath(File? _attachedFile) async {
    return await VideoThumbnail.thumbnailFile(
      video: _attachedFile!.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 64,
      quality: 75,
    );
  }

  Future<File?> pickFile(
    BuildContext context,
    File? _attachedFile,
    FileType fileType,
  ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions:
          fileType == FileType.custom ? documentsExtensions : null,
      type: fileType,
    );

    if (result != null) {
      _attachedFile = File(result.files.single.path!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File selected'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      _attachedFile = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No file selected'),
          duration: Duration(seconds: 1),
        ),
      );
    }
    return _attachedFile;
  }
}
