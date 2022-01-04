import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/screenConfig.dart';
import 'package:wean_app/common/toastUtils.dart';
import 'package:wean_app/screens/map/get_location.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/widgets/textViews.dart';

class MapScreen extends StatefulWidget {
  // LatLng latLng;
  // MapScreen(this.latLng);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _loading = true;
  GoogleMapController? _googleMapController;
  LocationData? locationData;
  LatLng? _pickedLocation;
  GeoCode geoCode = GeoCode();
  final LatLng _default = LatLng(21.27, 39.49);
  LatLng? latLng = LatLng(21.27, 39.49);

  // Directions _info;
  CameraPosition? position1 = CameraPosition(
    target: LatLng(21, 39),
    zoom: 11.5,
  );

  void _pickLocation(LatLng argument) {
    _pickedLocation = argument;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  AppTheme.primaryColor,
                ),
              ),
            )
          : Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: const [
                        Color(0xffFFC557),
                        Color(0xffCE8700),
                      ],
                    ),
                  ),
                  child: Center(
                    child: TextAppName(),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 80, bottom: 50
                      // bottom: kBottomNavigationBarHeight,
                      ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GoogleMap(
                            mapType: MapType.normal,
                            myLocationButtonEnabled: true,
                            zoomGesturesEnabled: true,
                            onTap: _pickLocation,
                            onCameraMove: (position) {
                              position1 = position;
                              setState(() {});
                              // print(position.zoom);
                            },
                            zoomControlsEnabled: true,
                            cameraTargetBounds: CameraTargetBounds.unbounded,
                            initialCameraPosition: position1!,
                            onMapCreated: (controller) =>
                                _googleMapController = controller,
                            markers: {
                              Marker(
                                markerId: const MarkerId('origin'),
                                infoWindow: const InfoWindow(title: 'Origin'),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed),
                                position: _pickedLocation ?? _default,
                              )
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // ic
                Positioned(
                    top: 100,
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
                          color: Colors.black.withOpacity(.30),
                        ),
                        alignment: Alignment(0.2, 0.0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    )),
                Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: SizeConfig.screenWidth,
                      child: TextButton(
                        onPressed: () async {
                          if(_pickedLocation!=null) {
                            var loc = await geoCode.reverseGeocoding(latitude: _pickedLocation?.latitude??0.0, longitude:  _pickedLocation?.longitude??0.0);
                            var city =
                                "${loc.streetNumber??''} ${loc.streetAddress??''} ${loc.city??''} ${loc.countryName??''}";
                            // print("city $city");
                            Navigator.pop(context, city);
                          }else{
                            Toast.showError(LocaleKeys.invalid_location.tr());
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        child: Center(
                            child: TextTitle(
                          text: LocaleKeys.confirm.tr(),
                        )),
                      ),
                    )),
              ],
            ),

      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 50,
            right: 45,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.black,
              onPressed: () async {
                locationData = await LocationService.getLocation();
                // latLng?.latitude = locationData.latitude;
                _pickedLocation = LatLng(locationData?.latitude ?? 21,
                    locationData?.longitude ?? 39);
                _googleMapController?.animateCamera(
                  CameraUpdate.newCameraPosition(CameraPosition(
                    target: LatLng(locationData?.latitude ?? 21,
                        locationData?.longitude ?? 39),
                    zoom: 11.5,
                  )),
                );
                position1 = CameraPosition(
                  target: LatLng(locationData?.latitude ?? 21,
                      locationData?.longitude ?? 39),
                  zoom: 11.5,
                );
                setState(() {});
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void getLocation() async {
    locationData = await LocationService.getLocation();
    _pickedLocation =
        LatLng(locationData?.latitude ?? 21, locationData?.longitude ?? 39);
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(locationData?.latitude ?? 21, locationData?.longitude ?? 39),
        zoom: 11.5,
      )),
    );
    position1 = CameraPosition(
      target:
          LatLng(locationData?.latitude ?? 21, locationData?.longitude ?? 39),
      zoom: 11.5,
    );

    _loading = false;
    setState(() {});
  }
}
