import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  checkPermission() async {
    PermissionStatus permission = await Permission.location.request();
  }

  LiveLocation() async {
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    });
  }

  double latitude = 0;
  double longitude = 0;

  Completer<GoogleMapController> googleMapController = Completer();
  late CameraPosition position;

  @override
  void initState() {
    super.initState();
    checkPermission();
    LiveLocation();
    position = CameraPosition(
      target: LatLng(latitude, longitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Location"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await openAppSettings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Your Current Longitude and Latitude",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "$latitude, $longitude",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: GoogleMap(
              mapType: MapType.satellite,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                googleMapController.complete(controller);
              },
              initialCameraPosition: position,
              markers: {
                Marker(
                  markerId: const MarkerId("Current Location"),
                  position: LatLng(latitude, longitude),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}