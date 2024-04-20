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
  List<int> numberOfMarkersPerVector = [];
  List<double> markerSpacingPerVector = [];
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
                            color: Colors.blue,
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
                numberOfMarkersPerVector.add(10);
                markerSpacingPerVector.add(100.0);
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
                        Text('Vector ${index + 1} - Number of Markers:'),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                numberOfMarkersPerVector[index] = int.tryParse(value) ?? 10;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter number of markers',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Vector ${index + 1} - Marker Spacing (m):'),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                markerSpacingPerVector[index] = double.tryParse(value) ?? 100.0;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter marker spacing in meters',
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
      int numberOfMarkers = numberOfMarkersPerVector[i];
      double markerSpacing = markerSpacingPerVector[i];

      double vectorLength = const Distance().as(
        LengthUnit.Meter,
        LatLng(points[0].latitude, points[0].longitude),
        LatLng(points[1].latitude, points[1].longitude),
      );
      LatLng vectorDirection = LatLng(
        (points[1].latitude - points[0].latitude) / vectorLength,
        (points[1].longitude - points[0].longitude) / vectorLength,
      );

      for (int j = 0; j < numberOfMarkers; j++) {
        double distance = markerSpacing * j;
        LatLng markerPosition = LatLng(
          points[0].latitude + vectorDirection.latitude * distance,
          points[0].longitude + vectorDirection.longitude * distance,
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
