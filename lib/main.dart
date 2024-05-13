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
  List<List<LatLng>> beachSections = [];
  List<int> numberOfRows = [];
  List<double> spaceBetweenBeachchairs = [];
  List<double> spaceBetweenRows = [];
  List<Marker> beachchairs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Vector with Markers on Flutter Map'),
      ),
      body: Stack(
        children: [
          FlutterMap(
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
              MarkerLayer(
                markers: beachchairs,
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              color: Colors.white.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _addBeachSection,
                    child: const Text('Add Beach Section'),
                  ),
                  SizedBox(
                    width: 400,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: beachSections.length,
                      itemBuilder: (context, index) => _buildVectorSettings(index),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(LatLng point) {
    setState(() {
      if (beachSections.last.length < 2) {
        beachSections.last.add(point);
        _addBeachchair(point);
      }
      if (beachSections.last.length == 2) {
        _distributeBeachchairs();
      }
    });
  }

  void _addBeachSection() {
    setState(() {
      beachSections.add([]);
      numberOfRows.add(3);
      spaceBetweenBeachchairs.add(4.0);
      spaceBetweenRows.add(4.0);
    });
  }

  Widget _buildVectorSettings(int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          _buildSettingRow('Number of Rows', (value) {
            numberOfRows[index] = int.tryParse(value) ?? 3;
          }),
          _buildSettingRow('Space between beachchairs (m)', (value) {
            spaceBetweenBeachchairs[index] = double.tryParse(value) ?? 4.0;
          }),
          _buildSettingRow('Space between rows (m)', (value) {
            spaceBetweenRows[index] = double.tryParse(value) ?? 4.0;
          }),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String label, ValueChanged<String> onChanged) {
    return Row(
      children: [
        Text('Vector ${beachSections.length} - $label:'),
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

  void _addBeachchair(LatLng point) {
    beachchairs.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: point,
        child: const Icon(Icons.location_on, color: Colors.blue),
      ),
    );
  }

  int _calculateNumberOfBeachchairsBetweenTwoPoints(LatLng point1, LatLng point2, double spacing) {
    Geodesy geodesy = Geodesy();
    num distance = geodesy.distanceBetweenTwoGeoPoints(point1, point2);
    int numberOfMarkers = (distance ~/ spacing) + 1;
    return numberOfMarkers;
  }

  void _distributeBeachchairs() {
    beachchairs.clear();
    for (int i = 0; i < beachSections.length; i++) {
      List<LatLng> points = beachSections[i];
      int numberOfMarkersX = _calculateNumberOfBeachchairsBetweenTwoPoints(points[0], points[1], spaceBetweenBeachchairs[i]);
      int numberOfMarkersY = numberOfRows[i];
      double markerSpacingX = spaceBetweenBeachchairs[i];
      double markerSpacingY = spaceBetweenRows[i];

      LatLng startPoint = points[0];
      LatLng endPoint = points[1];

      Geodesy geodesy = Geodesy();
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

          _addBeachchair(markerPosition);
        }
      }
    }
  }
}
