import 'package:geodesy/geodesy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'beachsection.dart';

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
  List<BeachSection> beachSections = [];

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
                markers: beachSections
                    .expand((section) => section.spots.map((spot) => Marker(
                          width: 80.0,
                          height: 80.0,
                          point: spot,
                          child: const Icon(Icons.location_on, color: Colors.blue),
                        )))
                    .toList(),
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
                      itemBuilder: (context, index) => _buildBeachSectionSettings(index),
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
      if (beachSections.last.startPoint == null) {
        beachSections.last.startPoint = point;
      } else {
        beachSections.last.endPoint = point;
        _distributeSpotsForBeachSection(beachSections.last);
      }
    });
  }

  void _addBeachSection() {
    setState(() {
      beachSections.add(BeachSection(
        numRows: 3,
        rowSpacing: 4.0,
        spotSpacing: 4.0,
        spots: [],
      ));
    });
  }

  Widget _buildBeachSectionSettings(int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          _buildSettingRow('Number of Rows', (value) {
            beachSections[index] = beachSections[index].copyWith(numRows: int.tryParse(value) ?? 3, spotSpacing: null, rowSpacing: null);
          }),
          _buildSettingRow('Space between beachchairs (m)', (value) {
            beachSections[index] = beachSections[index].copyWith(spotSpacing: double.tryParse(value) ?? 4.0, numRows: null, rowSpacing: null);
          }),
          _buildSettingRow('Space between rows (m)', (value) {
            beachSections[index] = beachSections[index].copyWith(rowSpacing: double.tryParse(value) ?? 4.0, numRows: null, spotSpacing: null);
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

  int _calculateNumberOfBeachchairsBetweenTwoPoints(LatLng point1, LatLng point2, double spacing) {
    Geodesy geodesy = Geodesy();
    num distance = geodesy.distanceBetweenTwoGeoPoints(point1, point2);
    int numberOfMarkers = (distance ~/ spacing) + 1;
    return numberOfMarkers;
  }

  void _distributeSpotsForBeachSection(BeachSection section) {
    int numberOfMarkersX = _calculateNumberOfBeachchairsBetweenTwoPoints(section.startPoint!, section.endPoint!, section.spotSpacing);
    int numberOfMarkersY = section.numRows;
    double markerSpacingX = section.spotSpacing;
    double markerSpacingY = section.rowSpacing;

    LatLng startPoint = section.startPoint!;
    LatLng endPoint = section.endPoint!;

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

        section.spots.add(markerPosition);
      }
    }
  }
}
