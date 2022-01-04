import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wean_app/blocs/order/order_bloc.dart';
import 'package:wean_app/blocs/order/order_event.dart';
import 'package:wean_app/blocs/order/order_state.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/routes.dart';
import 'package:wean_app/common/screenConfig.dart';
import 'package:wean_app/common/toastUtils.dart';
import 'package:wean_app/models/appPreferencesModel.dart';
import 'package:wean_app/models/productModel.dart';
import 'package:wean_app/models/yardItemModel.dart';
import 'package:wean_app/services/firebaseServices.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/utils/util.dart';
import 'package:wean_app/widgets/buttons.dart';
import 'package:wean_app/widgets/decorations.dart';
import 'package:wean_app/widgets/textViews.dart';

class OrderScreen extends StatefulWidget {
  final ProductModel? item;

  OrderScreen({required this.item});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<File> imageFiles = [];

  int maxImageLength = 5;

  int finalImageLength = 5;

  final formKey = GlobalKey<FormState>();

  TextEditingController _productNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  FirebaseDBServices dbServices = FirebaseDBServices();
  List<String> imageUrls = [];

  List categories = [];
  String? selectedCategory;

  List<Country> cities = [];

  String? selectedCity;

  late String ownerId;

  bool imageUploaded = false;

  bool isLoading = false;

  late OrderBloc _orderBloc;

  @override
  void initState() {
    loadServices();
    super.initState();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    imageFiles.clear();
    imageUrls.clear();
    super.dispose();
  }

  _imgFromCamera() async {
    final pickedFile = await ImagePicker.platform
        .getImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      imageFiles.add(File(pickedFile!.path));
    });
  }

  _imgFromGallery() async {
    final pickedFile = await ImagePicker.platform
        .getImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      imageFiles.add(File(pickedFile!.path));
    });
  }

  loadServices() async {
    _orderBloc = BlocProvider.of<OrderBloc>(context);
    _orderBloc.add(GetPrefs());
    ownerId = FirebaseAuth.instance.currentUser!.uid;
    // await _imgFromCamera();
  }

  bool validateItems() {
    // if (_productNameController.text.isEmpty) {
    //   Toast.showError("Please enter the product name.");
    //   return false;
    // } else

    if (_descriptionController.text.isEmpty) {
      Toast.showError(LocaleKeys.enter_description_msg.tr());
      return false;
    } else if (selectedCity == null) {
      Toast.showError(LocaleKeys.select_city.tr());
      return false;
    } else if (selectedCategory == null) {
      Toast.showError(LocaleKeys.please_select_category.tr());
      return false;
    } else if (imageFiles.length < 0) {
      Toast.showError(LocaleKeys.please_select_images.tr());
      return false;
    }
    return true;
  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      callback();
    });
  }

  uploadUserItem() async {
    String productDescription = _descriptionController.text;
    String city = selectedCity.toString();
    String category = selectedCategory.toString();
    Timestamp currentTime = Timestamp.now();
    // print("uploadItems");
    _orderBloc.add(UploadOrder(
        item: YardItem(
            ownerId: ownerId,
            name: '',
            item_live: true,
            description: productDescription,
            postedAt: currentTime,
            updatedAt: currentTime,
            media: imageUrls,
            country: city,
            city: '',
            category: category,
            is_auction: false,
            current_bid: null)));
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text(LocaleKeys.photo_library.tr()),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text(LocaleKeys.camera.tr()),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBar(
              backgroundColor: AppTheme.primaryBColor,
              elevation: 0.0,
              centerTitle: true,
              automaticallyImplyLeading: true,
              title: TextAppName(),
              actions: [
                widget.item != null
                    ? GestureDetector(
                        child: Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ))
                    : Container(),
                SizedBox(
                  width: 20,
                ),
                widget.item != null
                    ? GestureDetector(
                        child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ))
                    : Container(),
                SizedBox(
                  width: 10,
                ),
              ],
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            child: Container(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight - 80,
              padding: EdgeInsets.all(8),
              child: BlocBuilder<OrderBloc, OrderState>(
                bloc: _orderBloc,
                builder: (context, state) {
                  if (state is OrderLoading) {
                    isLoading = true;
                  }
                  // after pref value loaded
                  else if (state is OrderPrefLoaded) {
                    isLoading = false;
                    categories = state.preferences.categories;
                    cities = state.preferences.countries;
                    _orderBloc.add(UpdateAskUI());
                  }
                  // upload the image
                  else if (state is OrderImagesUploaded) {
                    isLoading = false;
                    imageUrls = state.imageUrls;
                    imageUploaded = true;
                    _orderBloc.add(UpdateAskUI());
                  }
                  // upload the order
                  else if (state is OrderUploaded) {
                    _orderBloc.add(UpdateAskUI());
                    if (isLoading) isLoading = false;
                    imageUploaded = false;
                    _onWidgetDidBuild(() {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          home, (Route<dynamic> route) => false);
                    });
                  }
                  // update UI
                  else if (state is OrderUIUpdated) {
                    if (isLoading) isLoading = false;
                  }

                  return isLoading
                      ? Container(
                          height: SizeConfig.screenHeight - 100,
                          alignment: Alignment.center,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        )
                      : (imageUploaded
                          ? Container(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Form(
                                      key: formKey,
                                      child: Column(
                                        children: [
                                          // //product name
                                          // Padding(
                                          //   padding: const EdgeInsets.all(12.0),
                                          //   child: TextFormField(
                                          //     controller: _productNameController,
                                          //     keyboardType: TextInputType.text,
                                          //     textInputAction: TextInputAction.done,
                                          //     maxLines: 1,
                                          //     decoration: InputDecoration(
                                          //         border: normalBorder,
                                          //         enabledBorder: normalBorder,
                                          //         focusedBorder: focusBorder,
                                          //         hintText: "Enter product name",
                                          //         hintStyle:
                                          //             AppTheme.body2.copyWith(
                                          //           color: AppTheme.greyText,
                                          //         )),
                                          //   ),
                                          // ),
                                          // SizedBox(
                                          //   height: 6,
                                          // ),
                                          //category
                                          Container(
                                            // decoration: roundedOutlineBox,
                                            margin: const EdgeInsets.all(12),
                                            padding: const EdgeInsets.all(6),
                                            child: DropdownButton(
                                                icon: Icon(Icons
                                                    .keyboard_arrow_down_outlined),
                                                isExpanded: true,
                                                underline: Container(
                                                  height: 1,
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.6),
                                                ),
                                                value: selectedCategory,
                                                hint: Text(
                                                    LocaleKeys.select_category
                                                        .tr(),
                                                    style: TextStyle(
                                                        color:
                                                            AppTheme.greyText,
                                                        fontSize: 16)),
                                                items: categories.map((choice) {
                                                  return DropdownMenuItem(
                                                    child: Text(
                                                      translatedText(
                                                          choice, context),
                                                      style: AppTheme.body2,
                                                    ),
                                                    value: choice,
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedCategory =
                                                        value as String?;
                                                  });
                                                }),
                                          ),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          //city
                                          Container(
                                            // decoration: roundedOutlineBox,
                                            margin: const EdgeInsets.all(12),
                                            padding: const EdgeInsets.all(6),
                                            child: DropdownButton(
                                                icon: Icon(Icons
                                                    .keyboard_arrow_down_outlined),
                                                isExpanded: true,
                                                underline: Container(
                                                  height: 1,
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.6),
                                                ),
                                                value: selectedCity,
                                                hint: Text(
                                                    LocaleKeys.select_country
                                                        .tr(),
                                                    style: TextStyle(
                                                        color:
                                                            AppTheme.greyText,
                                                        fontSize: 16)),
                                                items: cities.map((choice) {
                                                  return DropdownMenuItem(
                                                    child: Text(
                                                      choice.name,
                                                      style: AppTheme.body2,
                                                    ),
                                                    value: choice.name,
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedCity =
                                                        value as String?;
                                                  });
                                                }),
                                          ),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: TextFormField(
                                              controller:
                                                  _descriptionController,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.done,
                                              maxLines: 5,
                                              decoration: InputDecoration(
                                                  // border: normalBorder,
                                                  // enabledBorder: normalBorder,
                                                  focusedBorder: focusBorder,
                                                  hintText: LocaleKeys
                                                      .product_description_missing_msg
                                                      .tr(),
                                                  hintStyle:
                                                      AppTheme.body2.copyWith(
                                                    color: AppTheme.greyText,
                                                  )),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: TextFormField(
                                              controller:
                                                  _descriptionController,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.done,
                                              maxLines: 5,
                                              decoration: InputDecoration(
                                                  // border: normalBorder,
                                                  // enabledBorder: normalBorder,
                                                  focusedBorder: focusBorder,
                                                  hintText: LocaleKeys
                                                      .product_description_missing_msg
                                                      .tr(),
                                                  hintStyle:
                                                      AppTheme.body2.copyWith(
                                                    color: AppTheme.greyText,
                                                  )),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          CustomFlatButton(
                                              fn: () async {
                                                if (!validateItems()) {
                                                  return;
                                                }
                                                uploadUserItem();
                                              },
                                              text: widget.item != null
                                                  ? LocaleKeys.UPDATE.tr()
                                                  : LocaleKeys.ADD.tr()),

                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: imageFiles.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return imageFiles.isNotEmpty
                                          ? Container(
                                              width:
                                                  SizeConfig.screenWidth / 3 -
                                                      10,
                                              height:
                                                  SizeConfig.screenHeight / 5 -
                                                      5,
                                              color: Colors.grey,
                                              child: Stack(
                                                alignment:
                                                    AlignmentDirectional.topEnd,
                                                children: [
                                                  Image.file(
                                                    imageFiles[index],
                                                    width:
                                                        SizeConfig.screenWidth /
                                                                3 -
                                                            10,
                                                    height: SizeConfig
                                                                .screenHeight /
                                                            5 -
                                                        5,
                                                  ),
                                                  GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          imageFiles
                                                              .removeAt(index);
                                                        });
                                                      },
                                                      child: Icon(
                                                        Icons.remove_circle,
                                                        color:
                                                            Colors.red.shade400,
                                                      ))
                                                ],
                                              ),
                                            )
                                          : Container();
                                    }),
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CustomFlatButton(
                                        fn: () async {
                                          if (imageFiles.isEmpty ||
                                              imageFiles.length < 5) {
                                            finalImageLength = maxImageLength -
                                                imageFiles.length;
                                            _showPicker(context);
                                            // List<Media>? imgs =
                                            //     await ImagesPicker.openCamera(
                                            //   pickType: PickType.image,
                                            // );
                                            // if (imgs != null) {
                                            //   print(
                                            //       imgs.map((e) => e.path).toList());
                                            //   imgs.map((e) {
                                            //     print("file ${e.path}");
                                            //     print("file2 ${e.thumbPath}");
                                            //     print(
                                            //         "file3 ${e.path.split('/').last}");
                                            //     setState(() {
                                            //       imageFiles.add(File(e.path));
                                            //     });
                                            //   }).toList();
                                            // }
                                          }
                                        },
                                        text: LocaleKeys.pick_image.tr()),
                                    Visibility(
                                        visible: imageFiles.length > 0,
                                        child: CustomFlatButton(
                                            fn: () {
                                              _orderBloc.add(UploadImages(
                                                  files: imageFiles));
                                            },
                                            text: LocaleKeys.next_button.tr())),
                                    Visibility(
                                        visible: imageFiles.length > 0,
                                        child: CustomFlatButton(
                                          fn: () {
                                            if (imageUrls.length > 0) {
                                              _orderBloc.add(DeleteImages(
                                                  files: imageUrls));
                                            } else {
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          text: LocaleKeys.cancel.tr(),
                                        )),
                                  ],
                                ))
                              ],
                            ));
                },
              ),
            ),
          )),
        ));
  }
}
