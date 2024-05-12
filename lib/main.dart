import 'package:geodesy/geodesy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

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
  List<List<LatLng>> perpendicularVectorPoints = [];
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
                  userAgentPackageName: 'com.example.app',
                ),
                // PolylineLayer(
                //   polylines: [
                //     ...vectorPoints
                //         .map((points) => Polyline(
                //               points: points,
                //               color: Colors.red,
                //               strokeWidth: 3.0,
                //             ))
                //         .toList(),
                //     ...perpendicularVectorPoints
                //         .map((points) => Polyline(
                //               points: points,
                //               color: Colors.green,
                //               strokeWidth: 3.0,
                //             ))
                //         .toList(),
                //   ],
                // ),
                MarkerLayer(
                  markers: markers,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _addVector,
            child: const Text('Add Vector'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: vectorPoints.length,
              itemBuilder: (context, index) => _buildVectorSettings(index),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(LatLng point) {
    setState(() {
      if (vectorPoints.last.length < 2) {
        vectorPoints.last.add(point);
        _addMarker(point);
      }
      if (vectorPoints.last.length == 2) {
        _distributeMarkers();
      }
    });
  }

  void _addVector() {
    setState(() {
      vectorPoints.add([]);
      perpendicularVectorPoints.add([]);
      numberOfMarkersXPerVector.add(11);
      numberOfMarkersYPerVector.add(3);
      markerSpacingXPerVector.add(4.0);
      markerSpacingYPerVector.add(4.0);
    });
  }

  Widget _buildVectorSettings(int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          _buildSettingRow('Number of Markers in X', (value) {
            numberOfMarkersXPerVector[index] = int.tryParse(value) ?? 11;
          }),
          _buildSettingRow('Number of Markers in Y', (value) {
            numberOfMarkersYPerVector[index] = int.tryParse(value) ?? 3;
          }),
          _buildSettingRow('Marker Spacing in X (m)', (value) {
            markerSpacingXPerVector[index] = double.tryParse(value) ?? 4.0;
          }),
          _buildSettingRow('Marker Spacing in Y (m)', (value) {
            markerSpacingYPerVector[index] = double.tryParse(value) ?? 4.0;
          }),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String label, ValueChanged<String> onChanged) {
    return Row(
      children: [
        Text('Vector ${vectorPoints.length} - $label:'),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Enter $label',
            ),
          ),
        ),
      ],
    );
  }

  void _addMarker(LatLng point) {
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: point,
        child: const Icon(Icons.location_on, color: Colors.blue),
      ),
    );
  }

  void _distributeMarkers() {
    markers.clear();
    for (int i = 0; i < vectorPoints.length; i++) {
      List<LatLng> points = vectorPoints[i];
      int numberOfMarkersX = numberOfMarkersXPerVector[i];
      int numberOfMarkersY = numberOfMarkersYPerVector[i];
      double markerSpacingX = markerSpacingXPerVector[i];
      double markerSpacingY = markerSpacingYPerVector[i];

      LatLng startPoint = points[0];
      LatLng endPoint = points[1];

      Geodesy geodesy = Geodesy();
      //num vectorLength = geodesy.distanceBetweenTwoGeoPoints(startPoint, endPoint);
      num bearing = geodesy.bearingBetweenTwoGeoPoints(startPoint, endPoint);
      double perpendicularBearing = (bearing + 90) % 360;

      for (int y = 0; y < numberOfMarkersY; y++) {
        for (int x = 0; x < numberOfMarkersX; x++) {
          double distanceAlongVector = markerSpacingX * x;
          double distancePerpendicular = markerSpacingY * y;

          LatLng markerAlongVector = geodesy.destinationPointByDistanceAndBearing(
            startPoint,
            distanceAlongVector,
            bearing,
          );

          LatLng markerPosition = geodesy.destinationPointByDistanceAndBearing(
            markerAlongVector,
            distancePerpendicular,
            perpendicularBearing,
          );

          _addMarker(markerPosition);
        }
      }
    }
  }
}
