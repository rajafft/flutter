import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/toastUtils.dart';
import 'package:wean_app/screens/photo_picker/product_details.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/widgets/textViews.dart';
import 'package:easy_localization/easy_localization.dart';

class PhotoPreview extends StatefulWidget {
  const PhotoPreview(this.images);

  final List<File> images;

  @override
  _PhotoPreviewState createState() => _PhotoPreviewState();
}

class _PhotoPreviewState extends State<PhotoPreview> {
  late List<Medium> allImageThumbnails;
  final imageClicked0 = ValueNotifier<File?>(null);
  final imageClicked1 = ValueNotifier<File?>(null);
  final imageClicked2 = ValueNotifier<File?>(null);
  final imageClicked3 = ValueNotifier<File?>(null);
  bool storagePermissionGranted = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    for (var element in widget.images) {
      if (imageClicked0.value == null) {
        imageClicked0.value = element;
      } else if (imageClicked1.value == null) {
        imageClicked1.value = element;
      } else if (imageClicked2.value == null) {
        imageClicked2.value = element;
      } else {
        imageClicked3.value = element;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ValueNotifier<File?>> imageClickedList = [
      imageClicked0,
      imageClicked1,
      imageClicked2,
      imageClicked3,
    ];
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Color(0xffF8FAF7),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
              size: 15,
            ),
          ),
          centerTitle: true,
          title: TextTitle(
            text: LocaleKeys.upload_your_photos.tr(),
            textSize: 15,
          ),
          elevation: 0,
        ),
        body: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Flexible(
                flex: 2,
                child: Center(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      radius: 20,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                )),
            Flexible(
              flex: 1,
              child: Column(
                children: [
                  Container(
                    // height: 50,
                    padding: const EdgeInsets.fromLTRB(25, 10, 10, 0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      LocaleKeys.selected_images.tr(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    // width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: 4,
                      itemBuilder: (_, int index) =>
                          ValueListenableBuilder<File?>(
                        valueListenable: imageClickedList[index],
                        builder: (context, value, child) {
                          return Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: value == null
                                      ? Center(
                                          child: Icon(Icons.photo),
                                        )
                                      : InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return SafeArea(
                                                    child: Scaffold(
                                                      body: Stack(
                                                        children: [
                                                          Center(
                                                            child: Image.file(
                                                              File(value.path),
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 20,
                                                            left: 20,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.5)),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: InkWell(
                                                                onTap: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                child: Icon(
                                                                  Icons
                                                                      .arrow_back_ios,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Image.file(
                                            File(value.path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),
                              if (imageClickedList[index].value != null)
                                Positioned(
                                  top: -10,
                                  right: -10,
                                  child: IconButton(
                                    icon: Icon(Icons.remove_circle),
                                    onPressed: () {
                                      imageClickedList[index].value = null;
                                    },
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (imageClickedList
                          .any((element) => element.value != null)) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return EnterProductInformation([
                                imageClicked0.value,
                                imageClicked1.value,
                                imageClicked2.value,
                                imageClicked3.value,
                              ]);
                            },
                          ),
                        );
                      } else {
                        Toast.showError(
                          LocaleKeys.please_select_images.tr(),
                        );
                      }
                    },
                    child: Container(
                      child: Center(
                        child: Text(
                          LocaleKeys.next_button.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xffF5BC50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
