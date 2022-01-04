import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:wean_app/blocs/order/order_bloc.dart';
import 'package:wean_app/blocs/order/order_event.dart';
import 'package:wean_app/blocs/order/order_state.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/routes.dart';
import 'package:wean_app/common/screenConfig.dart';
import 'package:wean_app/models/appPreferencesModel.dart';
import 'package:wean_app/models/userModel.dart';
import 'package:wean_app/models/yardItemModel.dart';
import 'package:wean_app/services/firebaseServices.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/utils/util.dart';
import 'package:wean_app/widgets/textViews.dart';
import 'package:easy_localization/easy_localization.dart';

class EnterProductInformation extends StatefulWidget {
  const EnterProductInformation(this.selectedImagesList);

  final List<File?> selectedImagesList;

  @override
  _EnterProductInformationState createState() =>
      _EnterProductInformationState();
}

class _EnterProductInformationState extends State<EnterProductInformation> {
  late String ownerId;
  late bool isLoading;
  String city = 'Saudi Arabia', category = 'Toys';
  List allCountries = <Country>[], categories = <String>[];
  late Country selectedCountry;
  final _productDescriptionController = TextEditingController();
  final _currentPriceController = TextEditingController(text: '');
  FirebaseDBServices fbServices = FirebaseDBServices();
  bool isAuction = false;
  double currentBid = 0;
  List<File> compressedImages = [];

  @override
  void initState() {
    isLoading = false;
    context.read<OrderBloc>().add(GetPrefs());
    ownerId = FirebaseAuth.instance.currentUser!.uid;
    selectedCountry = Country(name: "", cities: []);
    // compressImages();
    super.initState();
  }

  void compressImages() async {
    List<File?> images = widget.selectedImagesList;
    if (images.isNotEmpty) {
      for (var imgFile in images)  {
        if (imgFile != null) {
          // print("image not null");
          final dir = await path_provider.getTemporaryDirectory();
          final targetPath = dir.absolute.path +
              "/${DateTime.now().millisecondsSinceEpoch}.jpg";
          // print("absolute_path## ${imgFile.absolute.path}");
          // print("image_size ${imgFile.lengthSync()}");
          // print("target_path## $targetPath");
          final result = await FlutterImageCompress.compressAndGetFile(
            imgFile.absolute.path,
            targetPath,
            quality: 60,
          );
          // print("compressedFileSize ${result!.lengthSync()}");
          setState(() {
            compressedImages.add(result!);
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _productDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.selectedImagesList.retainWhere((element) => element != null);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
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
              text: LocaleKeys.product_details.tr(),
              textSize: 15,
            ),
            elevation: 0,
          ),
          body: BlocConsumer<OrderBloc, OrderState>(
            listener: (_, state) async {
              if (state is OrderLoading) {
                setState(() {
                  isLoading = true;
                });
              }
              if (state is OrderPrefLoaded) {
                categories = state.preferences.categories;
                // categories.forEach((element) {
                //   // print(element);
                // });
                category = categories.first.toString();
                allCountries = state.preferences.countries;
                // allCountries.forEach((element) {
                //   // print(element.name);
                // });
                fbServices = FirebaseDBServices();
                UserModel user = await fbServices.loadBusinessCard();
                for (int i = 0; i < allCountries.length; i++) {
                  if (allCountries[i].name == user.selectedCountry) {
                    selectedCountry = allCountries[i];
                    city = selectedCountry.cities.first;
                    break;
                  }
                }
                setState(() {
                  isLoading = false;
                });
              }
              if (state is OrderImagesUploaded) {
                if (_currentPriceController.text.isNotEmpty) {
                  currentBid = double.parse(_currentPriceController.text);
                }

                var timestamp = Timestamp.now();
                context.read<OrderBloc>().add(
                      UploadOrder(
                        item: YardItem(
                            ownerId: ownerId,
                            name: '',
                            item_live: true,
                            description: _productDescriptionController.text,
                            postedAt: timestamp,
                            updatedAt: timestamp,
                            media: state.imageUrls,
                            country: selectedCountry.name,
                            city: city,
                            category: category,
                            is_auction: isAuction,
                            current_bid: currentBid,
                            starting_bid: currentBid),
                      ),
                    );
              }
              if (state is OrderUploaded) {
                setState(() {
                  isLoading = false;
                });
                Navigator.of(context).pushNamedAndRemoveUntil(
                    home, (Route<dynamic> route) => false);
              }
            },
            builder: (_, state) {
              if (isLoading) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(LocaleKeys.broadcating_msg.tr())
                    ],
                  ),
                );
              } else {
                return SingleChildScrollView(
                  child: SizedBox(
                    width: SizeConfig.screenWidth,
                    height: SizeConfig.screenHeight - 80,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.selectedImagesList.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Image.file(
                                    File(
                                        widget.selectedImagesList[index]!.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DropdownButton(
                              isExpanded: true,
                              hint: Text(LocaleKeys.select_category.tr()),
                              value: category,
                              items: categories
                                  .map((e) => DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(translatedText(
                                            e.toString(), context)),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  category = value as String;
                                });
                              }),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        selectedCountry.cities.isEmpty
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: DropdownButton(
                                  isExpanded: true,
                                  hint: Text(LocaleKeys.select_country.tr()),
                                  value: city,
                                  items: [
                                    ...selectedCountry.cities
                                        .map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                  translatedText(e, context)),
                                            ))
                                        .toList()
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      city = value as String;
                                    });
                                  },
                                ),
                              ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            maxLines: 5,
                            decoration: InputDecoration(
                                hintText:
                                    LocaleKeys.enter_description_msg.tr()),
                            controller: _productDescriptionController,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Text(
                                  LocaleKeys.auction.tr(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppTheme.black,
                                  ),
                                ),
                              ),
                              Switch(
                                activeColor: AppTheme.primaryColor,
                                value: isAuction,
                                onChanged: (value) {
                                  setState(() {
                                    isAuction = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        isAuction
                            ? SizedBox(
                                height: 30,
                              )
                            : Container(),
                        isAuction
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: TextFormField(
                                  maxLines: 1,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: LocaleKeys.starting_price.tr() +
                                          " " +
                                          LocaleKeys.SAR.tr()),
                                  controller: _currentPriceController,
                                ),
                              )
                            : Container(),
                        Spacer(
                          flex: 2,
                        ),
                        InkWell(
                          onTap: () {
                            if (_productDescriptionController.text.isNotEmpty &&
                                (!isAuction ||
                                    (isAuction &&
                                        _currentPriceController
                                            .text.isNotEmpty))) {
                              var imagesList =
                                  widget.selectedImagesList.cast<File>();
                              // var imagesList = compressedImages;
                              context.read<OrderBloc>().add(
                                  UploadImages(files: imagesList.toList()));
                            } else if (isAuction &&
                                _currentPriceController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(LocaleKeys
                                          .starting_price_missing_msg
                                          .tr())));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(LocaleKeys
                                          .product_description_missing_msg
                                          .tr())));
                            }
                          },
                          child: Container(
                            child: Center(
                              child: Text(
                                LocaleKeys.broadcast_button.tr(),
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
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ));
  }
}
