// ignore: implementation_imports
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slider/carousel.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/screenConfig.dart';
import 'package:wean_app/models/productModel.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/widgets/textViews.dart';

class ProductDetailsUI extends StatefulWidget {
  final ProductModel item;

  ProductDetailsUI({required this.item});

  @override
  _ProductDetailsUIState createState() => _ProductDetailsUIState();
}

class _ProductDetailsUIState extends State<ProductDetailsUI> {
  ProductModel get _items => widget.item;

  List<String> imageUrls = [];

  final toolTipKey = GlobalKey<State<Tooltip>>();

  IconData favIcon = Icons.favorite_border_outlined;

  int numberOfFav = 0;

  Color favColor = Colors.red;

  @override
  void initState() {
    getImageUrls();
    super.initState();
  }

  List<String> getImageUrls() {
    if (_items.imagesUrl != null && _items.imagesUrl!.isNotEmpty) {
      imageUrls = _items.imagesUrl!;
    } else {
      if (_items.imagesUrl != null) {
        imageUrls.add("${_items.imagesUrl}");
      } else {
        imageUrls.add("assets/waen_bglogo.png");
      }
    }
    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: AppTheme.primaryColor,
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
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppTheme.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 6, right: 6, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Carousel(
                indicatorBarColor: Colors.black54.withOpacity(0.6),
                autoScrollDuration: Duration(seconds: 2),
                animationPageDuration: Duration(milliseconds: 500),
                activateIndicatorColor: AppTheme.primaryColor,
                animationPageCurve: Curves.bounceInOut,
                indicatorBarHeight: 20,
                indicatorHeight: 10,
                indicatorWidth: 10,
                unActivatedIndicatorColor: Colors.white,
                stopAtEnd: true,
                autoScroll: true,
                scrollAxis: Axis.horizontal,
                isCircle: true,
                items: imageUrls.map((String link) {
                  return ClipRect(
                    child: link.startsWith("assets")
                        ? Image.asset(
                            link,
                            width: SizeConfig.screenWidth - 10,
                            height: SizeConfig.screenHeight / 2,
                            fit: BoxFit.cover,
                          )
                        : Image.network(link,
                            width: SizeConfig.screenWidth - 10,
                            fit: BoxFit.fitHeight),
                  );
                }).toList(),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextTitle(
                      text: _items.productName,
                      textSize: 24,
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: (){
                  //     setState(() {
                  //       if(favIcon== Icons.favorite_border_outlined) {
                  //         favIcon = Icons.favorite;
                  //         favColor = Colors.white;
                  //         numberOfFav = plusFavorites();
                  //       }else{
                  //         favIcon = Icons.favorite_border_outlined;
                  //         favColor = Colors.red;
                  //         numberOfFav = minusFavorites();
                  //       }
                  //     });
                  //   },
                  //   child: Stack(
                  //     alignment: AlignmentDirectional.center,
                  //     children: [
                  //       Align(child: Icon(favIcon, color: Colors.red, size: 42,), alignment: Alignment.center,),
                  //     ],
                  //   ),
                  // )
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.timelapse_rounded,
                    color: Colors.redAccent,
                  ),
                  TextTitle(text: 'Expired within 03-January-2021 12.00 pm'),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              // Row(
              //   children: [
              //     TextNormal(text: "$numberOfFav likes",),
              //     TextNormal(text: '5 Comments'),
              //   ],
              // ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Icons.person,
                  //       color: Colors.green.shade800,
                  //     ),
                  //     TextTitle(
                  //       text: _items.sellerName,
                  //       textSize: 16,
                  //       textColor: AppTheme.primaryDarkColor,
                  //     ),
                  //   ],
                  // ),
                  Row(
                    children: const [
                      // InkWell(
                      //   child: Icon(
                      //     Icons.phone,
                      //     color: Colors.blue,
                      //   ),
                      // ),
                      // SizedBox(
                      //   width: 40,
                      // ),
                      // Tooltip(
                      //   key: toolTipKey,
                      //   message: _items.sellerAddress,
                      //   child: GestureDetector(
                      //     child:
                      //         Icon(Icons.place, color: Colors.red),
                      //     onTap: () => _onTapAddress(toolTipKey),
                      //     behavior: HitTestBehavior.opaque,
                      //   ),
                      // ),
                      // SizedBox(
                      //   width: 10,
                      // ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              (_items.shortDescription != null)
                  ? TextNormal(
                      text: "${_items.shortDescription},",
                      textSize: 14,
                    )
                  : Text(""),
              SizedBox(
                height: 5,
              ),
              TextTitle(
                text: LocaleKeys.product_information.tr(),
                textSize: 18,
              ),
              TextNormal(
                text: _items.description,
                textSize: 14,
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
