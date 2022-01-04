import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryView extends StatefulWidget {
  List<String>? imageUrls = [];
  final int currentPosition;
  final PageController pageController;

  GalleryView({this.currentPosition = 0, this.imageUrls})
      : pageController = PageController(initialPage: currentPosition);


  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  late int? currentIndex = widget.currentPosition;

  List<String>? get imgUrls => widget.imageUrls;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            child: PhotoViewGallery.builder(
              backgroundDecoration: BoxDecoration(
                color: Color(0xFF272727),
              ),
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                // i = index!=null?index!:0;
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage('${imgUrls![index]}'),
                  // initialScale: PhotoViewComputedScale.contained * 0.5,

                  heroAttributes: PhotoViewHeroAttributes(tag: imgUrls![index]),
                );
              },
              itemCount: imgUrls!.length,
              loadingBuilder: (context, event) =>
                  Center(
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(value: 50
                        // event == null
                        //     ? 0
                        //     : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                      ),
                    ),
                  ),
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
            )),
        Positioned(
            top: 50,
            left: 20,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.white.withOpacity(.3),
                ),
                alignment: Alignment(0.2, 0.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: Colors.black.withOpacity(.87),
                ),
              ),
            ))
      ],
    );
  }
}

