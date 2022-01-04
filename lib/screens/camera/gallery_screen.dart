import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:wean_app/translations/locale_keys.g.dart';

class GalleryScreen extends StatefulWidget {
  GalleryScreen({
    Key? key,
    required this.allImageThumbnails,
    required this.currentlySelected,
    required this.newlyAddedPhotoSelection,
  }) : super(key: key);
  List<Medium> allImageThumbnails;
  List<Medium> currentlySelected;
  int newlyAddedPhotoSelection;

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Medium> newGalleryList = [];
  bool changed = false;
  @override
  void initState() {
    newGalleryList.addAll(widget.currentlySelected);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.currentlySelected);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text((newGalleryList.length +
                        widget.newlyAddedPhotoSelection) >
                    0
                ? ("${(newGalleryList.length + widget.newlyAddedPhotoSelection)}" +
                    LocaleKeys.file_selected.tr())
                : ""),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, newGalleryList);
                },
                child: Text(LocaleKeys.ok.tr()),
              )
            ]),
        body: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          children: widget.allImageThumbnails
              .map(
                (image) => SizedBox(
                  height: 50,
                  width: 50,
                  child: InkWell(
                    onTap: () {
                      if (newGalleryList.contains((image))) {
                        setState(() {
                          newGalleryList.remove(image);
                        });
                      } else {
                        setState(() {
                          if ((widget.newlyAddedPhotoSelection +
                                  newGalleryList.length) <
                              4) newGalleryList.add(image);
                        });
                      }
                    },
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: !((widget.newlyAddedPhotoSelection +
                                          newGalleryList.length) <
                                      4) &&
                                  !newGalleryList.contains((image))
                              ? 0.3
                              : 1,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: ThumbnailProvider(
                                  mediumId: image.id,
                                  mediumType: MediumType.image,
                                  highQuality: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (newGalleryList.contains(image))
                          Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 30,
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
