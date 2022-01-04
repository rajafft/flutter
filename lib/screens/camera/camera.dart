import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/screens/camera/preview.dart';
import 'package:wean_app/screens/camera/gallery_screen.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wean_app/widgets/textViews.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Album album;
  const CameraScreen({
    Key? key,
    required this.cameras,
    required this.album,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<Medium> allImageThumbnails;
  List<Medium> selectedGalleryImages = [];
  final List<ValueNotifier<File?>> imageSelected = [];
  List<File> selectedNewlySnappedPhoto = [];
  List<File> imageFiles = [];

  bool isLoading = false;

  Widget _buildGalleryBar() {
    const barHeight = 90.0;
    const vertPadding = 10.0;

    return GestureDetector(
      onVerticalDragUpdate: (details) async {
        int sensitivity = 4;
        if (details.delta.dy < -sensitivity) {
          List<Medium> newList = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GalleryScreen(
                        allImageThumbnails: allImageThumbnails,
                        newlyAddedPhotoSelection:
                            selectedNewlySnappedPhoto.length,
                        currentlySelected: selectedGalleryImages,
                      )));
          setState(() {
            selectedGalleryImages = newList;
          });
        }
      },
      child: Column(
        children: [
          Center(
              child: Icon(Icons.keyboard_arrow_up_outlined,
                  size: 20, color: Colors.white)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                    height: barHeight, // <-- Parent container with height limit
                    child: ListView.builder(
                        // <-- Image screenshot bar
                        padding: EdgeInsets.symmetric(vertical: vertPadding),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: imageFiles.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () async {
                              if (selectedNewlySnappedPhoto
                                  .contains((imageFiles[index]))) {
                                setState(() {
                                  selectedNewlySnappedPhoto
                                      .remove(imageFiles[index]);
                                });
                              } else {
                                setState(() {
                                  if ((selectedNewlySnappedPhoto.length +
                                          selectedGalleryImages.length) <
                                      4) {
                                    selectedNewlySnappedPhoto
                                        .add(imageFiles[index]);
                                  }
                                });
                              }
                            },
                            child: Container(
                              // <-- Each Image
                              padding: EdgeInsets.only(right: 5.0),
                              width: 70.0,
                              height: barHeight - vertPadding * 2,
                              child: Stack(
                                children: [
                                  Opacity(
                                    opacity: !((selectedNewlySnappedPhoto
                                                        .length +
                                                    selectedGalleryImages
                                                        .length) <
                                                4) &&
                                            !selectedNewlySnappedPhoto
                                                .contains((imageFiles[index]))
                                        ? 0.3
                                        : 1,
                                    child: Image.file(
                                      File(imageFiles[index].path),
                                      fit: BoxFit.fitWidth,
                                      width: 70.0,
                                    ),
                                  ),
                                  if (selectedNewlySnappedPhoto
                                      .contains((imageFiles[index])))
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
                          );
                        })),
                SizedBox(
                    height: barHeight, // <-- Parent container with height limit
                    child: ListView.builder(
                        // <-- Gallery bar which will scroll horizontally
                        padding: EdgeInsets.symmetric(vertical: vertPadding),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: allImageThumbnails.length < 15
                            ? allImageThumbnails.length
                            : 15,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              if (selectedGalleryImages
                                  .contains((allImageThumbnails[index]))) {
                                setState(() {
                                  selectedGalleryImages
                                      .remove(allImageThumbnails[index]);
                                });
                              } else {
                                setState(() {
                                  if ((selectedNewlySnappedPhoto.length +
                                          selectedGalleryImages.length) <
                                      4) {
                                    selectedGalleryImages
                                        .add(allImageThumbnails[index]);
                                  }
                                });
                              }
                            },
                            child: Container(
                              // <-- Each Image
                              padding: EdgeInsets.only(right: 5.0),
                              width: 70.0,
                              height: barHeight - vertPadding * 2,
                              child: Stack(
                                children: [
                                  Opacity(
                                    opacity:
                                        !((selectedNewlySnappedPhoto.length +
                                                        selectedGalleryImages
                                                            .length) <
                                                    4) &&
                                                !selectedGalleryImages.contains(
                                                    (allImageThumbnails[index]))
                                            ? 0.3
                                            : 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.fitWidth,
                                          image: ThumbnailProvider(
                                            mediumId: allImageThumbnails
                                                .elementAt(index)
                                                .id,
                                            mediumType: MediumType.image,
                                            highQuality: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (selectedGalleryImages
                                      .contains((allImageThumbnails[index])))
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
                          );
                        })),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    getAllMediaImages();
    initializeCamera(selectedCamera); //Initially selectedCamera = 0
    super.initState();
  }

  Future<List<File>> getFileFromMedium() async {
    List<File> result = [];
    result.addAll(selectedNewlySnappedPhoto);
    for (var element in selectedGalleryImages) {
      {
        File file = await PhotoGallery.getFile(
          mediumId: element.id,
          mediumType: MediumType.image,
        );
        result.add(file);
      }
    }
    return result;
  }

  Future<void> getAllMediaImages() async {
    setState(() {
      isLoading = true;
    });

    List<Medium> tempListOfImageThumbnails = [];
    allImageThumbnails = [];

    await widget.album.listMedia().then((MediaPage value) {
      tempListOfImageThumbnails.addAll(value.items);
    });

    allImageThumbnails = tempListOfImageThumbnails;
    setState(() {
      isLoading = false;
    });
  }

  late CameraController _controller; //To control the camera
  late Future<void>
      _initializeControllerFuture; //Future to wait until camera initializes
  int selectedCamera = 0;
  List<File> capturedImages = [];

  initializeCamera(int cameraIndex) async {
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.cameras[cameraIndex],
      // Define the resolution to use.
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: select a camera first.'),
        duration: const Duration(seconds: 2),
      ));
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error: ${e.code}\n${e.description}'),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          text: LocaleKeys.camera.tr(),
          textSize: 15,
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  AppTheme.primaryColor,
                ),
              ),
            )
          : Stack(
              children: [
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If the Future is complete, display the preview.
                      return CameraPreview(_controller);
                    } else {
                      // Otherwise, display a loading indicator.
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //  buidSelectedBar(),
                    _buildGalleryBar(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (widget.cameras.length > 1) {
                                setState(() {
                                  selectedCamera = selectedCamera == 0 ? 1 : 0;
                                  initializeCamera(selectedCamera);
                                });
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('No secondary camera found'),
                                  duration: const Duration(seconds: 2),
                                ));
                              }
                            },
                            icon: Icon(Icons.switch_camera_rounded,
                                color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await _initializeControllerFuture;
                              takePicture().then((XFile? file) {
                                if (mounted) {
                                  setState(() {
                                    var xFile = file;
                                    if (xFile != null) {
                                      imageFiles.insert(0, File(xFile.path));
                                      if ((selectedNewlySnappedPhoto.length +
                                              selectedGalleryImages.length) <
                                          4) {
                                        selectedNewlySnappedPhoto
                                            .add(imageFiles[0]);
                                      }
                                    }
                                  });
                                }
                              });
                            },
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: (selectedNewlySnappedPhoto.length +
                                    selectedGalleryImages.length) >
                                0,
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 20,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      getFileFromMedium().then((value) =>
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PhotoPreview(value))));
                                    },
                                    icon:
                                        Icon(Icons.check, color: Colors.white),
                                  ),
                                ),
                                Text(
                                  (selectedNewlySnappedPhoto.length +
                                              selectedGalleryImages.length)
                                          .toString() +
                                      "/4",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     //  if (capturedImages.isEmpty) return;
                          //     Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => GalleryScreen(
                          //                   allImageThumbnails: allImageThumbnails,
                          //                 )));
                          //   },
                          //   child: Container(
                          //     height: 60,
                          //     width: 60,
                          //     decoration: BoxDecoration(
                          //       border: Border.all(color: Colors.white),
                          //       image: capturedImages.isNotEmpty
                          //           ? DecorationImage(
                          //               image: FileImage(capturedImages.last),
                          //               fit: BoxFit.cover)
                          //           : null,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
