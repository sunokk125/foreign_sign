import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_foreign/graphql/QueryMutation.dart';
import 'package:flutter_foreign/service/GraphqlService.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as place;
import 'package:geocoder/geocoder.dart';

class PlacePage extends StatefulWidget {
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<PlacePage> {
  TextEditingController searchController = TextEditingController();

  Position position;

  BitmapDescriptor pinLocationIcon;
  Map<MarkerId, Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();

  var googlePlace =
      place.GooglePlace("AIzaSyDPg12mwTBBemkEc0O3Vixq0aHCXxPm7Pg");
  var result;

  void dispose() {
    print("dispose() of PlacePage");
    super.dispose();
  }

  void initState() {
    super.initState();
    if (!mounted) {
      return;
    }
    setCustomMapPin();
    getLocation();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/marker.png');
  }

  Future<void> getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  Future<Coordinates> getPosition(String address) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(address);
    print("position:${addresses.first.coordinates}");
    Coordinates position = addresses.first.coordinates;

    return position;
  }

  void addMakrer() async {
    var datas = await GraphqlService.futureQuery(QueryMutation.getRestsList());
    List<LazyCacheMap> rests =
        (datas.data['getRestsList'] as List<dynamic>).cast<LazyCacheMap>();
    print(rests[0]);

    int index = 0;

    rests.forEach((rest) async {
      print(rest["res_address"]);
      print(index);
      Coordinates position = await getPosition(rest["res_address"]);
      MarkerId markerId = MarkerId(index.toString());
      Marker marker = Marker(
          markerId: markerId,
          position: LatLng(
            position.latitude,
            position.longitude,
          ),
          icon: pinLocationIcon,
          onTap: () {},
          infoWindow: InfoWindow(
              title: rest["res_name"], //제목
              onTap: () {
                Navigator.pushNamed(context, '/detailRest',
                    arguments: <String, String>{'res_idx': rest["res_idx"]});
              },
              snippet: rest["res_address"] //부제목
              ));
      setState(() {
        _markers[markerId] = marker;
      });
      index += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.search),
        backgroundColor: Color.fromRGBO(52, 73, 94, 1),
        onPressed: () {
          // nearBySearch();
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            position != null
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: (MediaQuery.of(context).size.height -
                        kBottomNavigationBarHeight),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          position.latitude,
                          position.longitude,
                        ),
                        zoom: 18,
                      ),
                      markers: Set.of(_markers.values),
                      zoomControlsEnabled: false,
                      compassEnabled: true,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: true,
                      onCameraIdle: () async {
                        print(_markers);
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        addMakrer();
                      },
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        Text("loading ...."),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
