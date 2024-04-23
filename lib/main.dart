import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Draw Vector with Markers on Flutter Map',
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  List<List<LatLng>> vectorPoints = [];
  List<int> numberOfMarkersXPerVector = [];
  List<int> numberOfMarkersYPerVector = [];
  List<double> markerSpacingXPerVector = [];
  List<double> markerSpacingYPerVector = [];
  List<Marker> markers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Vector with Markers on Flutter Map'),
      ),
      body: Column(
        children: [
          Flexible(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(54.01758319961416, 14.069338276999131),
                initialZoom: 19,
                initialRotation: -45,
                onTap: (tapPosition, point) => _handleTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                  subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                  //urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylines: vectorPoints
                      .map((points) => Polyline(
                            points: points,
                            color: Colors.red,
                            strokeWidth: 3.0,
                          ))
                      .toList(),
                ),
                MarkerLayer(
                  markers: markers,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                vectorPoints.add([]);
                numberOfMarkersXPerVector.add(11);
                numberOfMarkersYPerVector.add(3);
                markerSpacingXPerVector.add(4.0);
                markerSpacingYPerVector.add(4.0);
              });
            },
            child: const Text('Add Vector'),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: vectorPoints.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Vector ${index + 1} - Number of Markers in X:'),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                numberOfMarkersXPerVector[index] = int.tryParse(value) ?? 11;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter number of markers in X',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Vector ${index + 1} - Number of Markers in Y:'),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                numberOfMarkersYPerVector[index] = int.tryParse(value) ?? 3;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter number of markers in Y',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Vector ${index + 1} - Marker Spacing in X (m):'),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                markerSpacingXPerVector[index] = double.tryParse(value) ?? 4.0;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter marker spacing in X (meters)',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Vector ${index + 1} - Marker Spacing in Y (m):'),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                markerSpacingYPerVector[index] = double.tryParse(value) ?? 4.0;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter marker spacing in Y (meters)',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleTap(LatLng point) {
    setState(() {
      if (vectorPoints.last.length < 2) {
        vectorPoints.last.add(point);
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: point,
            child: const Icon(Icons.location_on, color: Colors.red),
          ),
        );
      }
      if (vectorPoints.last.length == 2) {
        markers.clear(); // Clear previous markers
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: vectorPoints.last[0],
            child: const Icon(Icons.location_on, color: Colors.red),
          ),
        );
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: vectorPoints.last[1],
            child: const Icon(Icons.location_on, color: Colors.red),
          ),
        );
        _distributeMarkers();
      }
    });
  }

  void _distributeMarkers() {
    markers.clear(); // Clear previous markers
    for (int i = 0; i < vectorPoints.length; i++) {
      List<LatLng> points = vectorPoints[i];
      int numberOfMarkersX = numberOfMarkersXPerVector[i];
      int numberOfMarkersY = numberOfMarkersYPerVector[i];
      double markerSpacingX = markerSpacingXPerVector[i];
      double markerSpacingY = markerSpacingYPerVector[i];

      LatLng vectorDirection = LatLng(
        points[1].latitude - points[0].latitude,
        points[1].longitude - points[0].longitude,
      );

      LatLng perpendicularVector = LatLng(
        -vectorDirection.longitude,
        vectorDirection.latitude,
      );
      double vectorLength = const Distance().as(
        LengthUnit.Meter,
        points[0],
        points[1],
      );
      LatLng unitVector = LatLng(
        vectorDirection.latitude / vectorLength,
        vectorDirection.longitude / vectorLength,
      );

      for (int y = 0; y < numberOfMarkersY; y++) {
        for (int x = 0; x < numberOfMarkersX; x++) {
          double distanceAlongVector = markerSpacingX * x;
          double distancePerpendicular = markerSpacingY * y;
          LatLng markerPosition = LatLng(
            points[0].latitude + unitVector.latitude * distanceAlongVector - unitVector.longitude * distancePerpendicular,
            points[0].longitude + unitVector.longitude * distanceAlongVector + unitVector.latitude * distancePerpendicular,
          );
          markers.add(
            Marker(
              width: 80.0,
              height: 80.0,
              point: markerPosition,
              child: const Icon(Icons.location_on, color: Colors.blue),
            ),
          );
        }
      }
    }
  }
}
