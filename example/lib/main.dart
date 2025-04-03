import 'package:clippy_flutter/triangle.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:custom_info_window/custom_info_window.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomInfoWindowExample(),
    );
  }
}

class CustomInfoWindowExample extends StatefulWidget {
  const CustomInfoWindowExample({super.key});

  @override
  CustomInfoWindowExampleState createState() => CustomInfoWindowExampleState();
}

class CustomInfoWindowExampleState extends State<CustomInfoWindowExample> {
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  final LatLng _latLng = LatLng(28.7041, 77.1025);
  final double _zoom = 15.0;
  final double offset = 50;
  final double height = 75;
  final double width = 150;

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    _markers.add(
      Marker(
        markerId: MarkerId("marker_id"),
        position: _latLng,
        onTap: () {
          _customInfoWindowController.addInfoWindow(
            SizedBox(
              height: height,
              width: width,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: double.infinity,
                      height: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              "I am here",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Triangle.isosceles(
                    edge: Edge.BOTTOM,
                    child: Container(
                      color: Colors.blue,
                      width: 20.0,
                      height: 10.0,
                    ),
                  ),
                ],
              ),
            ),
            _latLng,
          );
        },
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Info Window Example'),
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onTap: (position) {
              _customInfoWindowController.hideInfoWindow();
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove();
            },
            onMapCreated: (GoogleMapController controller) async {
              _customInfoWindowController.googleMapController = controller;
            },
            markers: _markers,
            initialCameraPosition: CameraPosition(
              target: _latLng,
              zoom: _zoom,
            ),
          ),
          CustomInfoWindow(
            onChange: (top, left) => null,
            controller: _customInfoWindowController,
          ),
        ],
      ),
    );
  }
}
