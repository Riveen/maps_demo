import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tms_mobile_map/Map%20Components/location_service.dart';

class TMSMap extends StatefulWidget {
  const TMSMap({super.key});

  @override
  State<TMSMap> createState() => TMSMapState();
}

class TMSMapState extends State<TMSMap> {
  // map controller
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  // controllers for origin and destination for map points
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  Set<Polyline> _polylines = Set<Polyline>();
  Set<Marker> _markers = Set<Marker>();

  int _polylineIdCounter = 1;

  // initial camera position to begin each time user refreshes view
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // sets the polyline according to the lat, lng points
  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = "polyline_$_polylineIdCounter";
    _polylineIdCounter++;

    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 4,
        color: Colors.blue,
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
      ),
    );
  }

  // sets the marker
  void setMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("Marker"),
          position: point,
        ),
      );
    });
  }

  // controls the camera by animating it via bounds and points
  Future<void> _goToPlace(double lat, double lng, Map<String, dynamic> boundsNe,
      Map<String, dynamic> boundsSw) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 25),
      ),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
          northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
        ),
        25));

    setMarker(LatLng(lat, lng));
  }

  bool _showTextFields = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "G Maps",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // google map object
          GoogleMap(
            indoorViewEnabled: false,
            mapType: MapType.normal,
            markers: _markers,
            polylines: _polylines,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
          ),
          // card
          Positioned(
            left: 0,
            right: 0,
            bottom: 16.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _showTextFields
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _buildCardWithTextFields(),
                secondChild: _buildMinimizedCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // build widget card with two text fields and a button
  Widget _buildCardWithTextFields() {
    return Card(
      color: Colors.white,
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: const Center(
              child: Text(
                "Distance: 5 km", // Replace with actual distance
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _originController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: "PICK UP"),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _destinationController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: "DROP OFF"),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      var directions = await LocationService().getDirections(
                        _originController.text,
                        _destinationController.text,
                      );

                      setState(() {
                        _showTextFields = false;
                      });

                      _goToPlace(
                        directions['start_location']['lat'],
                        directions['start_location']['lng'],
                        directions['bounds_ne'],
                        directions['bounds_sw'],
                      );
                      _setPolyline(directions['polyline_decoded']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      "ACCEPT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // build minimized card widget
  Widget _buildMinimizedCard() {
    return Card(
      color: Colors.white,
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey.shade300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _showTextFields = true;
                    });
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey, size: 18),
                SizedBox(width: 8.0),
                Text(
                  "10:00 AM", // Replace with actual time detail
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text(
                  "DROP OFF",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
