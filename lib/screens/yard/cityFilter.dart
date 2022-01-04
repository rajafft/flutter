import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/toastUtils.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/utils/util.dart';
import 'package:wean_app/widgets/textViews.dart';
import 'package:geocode/geocode.dart';

class CityFilter extends StatefulWidget {
  final List<String> cities;

  CityFilter({required this.cities});

  @override
  _CityFilterState createState() => _CityFilterState();
}

class _CityFilterState extends State<CityFilter> {
  List<String> get _cities => widget.cities;
  late LocationData? _currentPosition;
  Location location = Location();
  GeoCode geoCode = GeoCode();

  @override
  void initState() {
    getPermission();
    super.initState();
  }

  getPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _currentPosition = await location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
            child: Scaffold(
          body: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.grey,
                          )),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue value) {
                          return _cities
                              .where((element) =>
                                  translatedText(element, context)
                                      .toLowerCase()
                                      .contains(value.text.toLowerCase()))
                              .toList();
                        },
                        displayStringForOption: (String value) => value,
                        onSelected: (value) async {
                          Navigator.pop(context, value);
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController fieldTextEditingController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted) {
                          return Container(
                            margin: EdgeInsets.only(left: 10, bottom: 10),
                            child: TextField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppTheme.primaryBColor,
                                          width: 1.0),
                                    ),
                                    hintText: LocaleKeys.search_area_city.tr(),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ))),
                          );
                        },
                        optionsViewBuilder: (BuildContext context,
                            AutocompleteOnSelected<String> onSelected,
                            Iterable<String>? options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.only(top: 60, bottom: 100),
                              child: ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  final selectedCity =
                                      options!.elementAt(index);
                                  return ListTile(
                                    title: TextTitle(
                                        text: translatedText(
                                            selectedCity, context)),
                                    onTap: () {
                                      onSelected(selectedCity);
                                    },
                                    leading: Icon(
                                      Icons.location_on,
                                      color: Colors.grey.shade500,
                                    ),
                                  );
                                },
                                itemCount: options!.length,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                color: Colors.grey.shade200,
                padding: EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () async {
                    if (_currentPosition == null) {
                      Toast.showError(
                          LocaleKeys.please_enable_location_permission.tr());
                      return;
                    }
                    var loc = await geoCode.reverseGeocoding(
                        latitude: _currentPosition?.latitude ?? 0.0,
                        longitude: _currentPosition?.longitude ?? 0.0);
                    var city = loc.city;
                    if (city != null && !_cities.contains(city)) {
                      Toast.showError(LocaleKeys.unlisted_location.tr() +
                          ' - $city' +
                          LocaleKeys.please_choose_location.tr());
                      return;
                    }
                    Navigator.pop(context, city);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(Icons.my_location),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextTitle(text: LocaleKeys.current_location.tr()),
                            TextNormal(text: LocaleKeys.using_gps.tr())
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        )));
  }
}
