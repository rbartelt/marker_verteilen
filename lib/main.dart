import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';

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
  bool _isAddingBeachSection = false;
  String _infoMessage = '';
  bool _showInputForm = false;
  int _numRows = 3;
  double _spotSpacing = 4.0;
  double _rowSpacing = 4.0;
  LatLng? _startPoint;
  LatLng? _endPoint;
  BeachSection? _selectedBeachSection;

  final polygons = <Polygon>[];
  final testPolygon = Polygon(
    color: Colors.deepOrange,
    borderStrokeWidth: 4,
    isFilled: false,
    points: [],
  );

  @override
  void initState() {
    super.initState();
    polygons.add(testPolygon);
  }

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
                markers: [
                  if (_startPoint != null)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _startPoint!,
                      child: const Icon(Icons.location_on, color: Colors.red),
                    ),
                  ...beachSections.expand((section) => section.spots.map((spot) => Marker(
                        width: 80.0,
                        height: 80.0,
                        point: spot,
                        child: GestureDetector(
                          onTap: () => _selectBeachSection(section),
                          child: const Icon(Icons.location_on, color: Colors.blue),
                        ),
                      ))),
                ],
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
                    onPressed: _toggleInputForm,
                    child: const Text('Add Beach Section'),
                  ),
                ],
              ),
            ),
          ),
          if (_infoMessage.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.blue,
                child: Text(
                  _infoMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          if (_showInputForm)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.3,
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedBeachSection == null ? 'Add Beach Section' : 'Edit Beach Section', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Number of Rows'),
                      controller: TextEditingController(text: _numRows.toString()),
                      onChanged: (value) => setState(() => _numRows = int.tryParse(value) ?? 3),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Space between beachchairs (m)'),
                      controller: TextEditingController(text: _spotSpacing.toString()),
                      onChanged: (value) => setState(() => _spotSpacing = double.tryParse(value) ?? 4.0),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Space between rows (m)'),
                      controller: TextEditingController(text: _rowSpacing.toString()),
                      onChanged: (value) => setState(() => _rowSpacing = double.tryParse(value) ?? 4.0),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _selectedBeachSection == null ? _startAddingBeachSection : _updateBeachSection,
                      child: Text(_selectedBeachSection == null ? 'Start Adding' : 'Update'),
                    ),
                    if (_selectedBeachSection != null)
                      ElevatedButton(
                        onPressed: _cancelEdit,
                        child: const Text('Cancel'),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleInputForm() {
    setState(() {
      _showInputForm = !_showInputForm;
      _isAddingBeachSection = false;
      _infoMessage = '';
      _startPoint = null;
      _endPoint = null;
      _selectedBeachSection = null;
    });
  }

  void _startAddingBeachSection() {
    setState(() {
      _isAddingBeachSection = true;
      _showInputForm = false;
      _infoMessage = 'Klicke den ersten Punkt des Strandabschnittes an.';
    });
  }

  void _selectBeachSection(BeachSection section) {
    setState(() {
      _selectedBeachSection = section;
      _numRows = section.numRows;
      _spotSpacing = section.spotSpacing;
      _rowSpacing = section.rowSpacing;
      _startPoint = section.startPoint;
      _endPoint = section.endPoint;
      _showInputForm = true;
    });
  }

  void _updateBeachSection() {
    setState(() {
      if (_selectedBeachSection != null) {
        _selectedBeachSection?.copyWith(
          startPoint: _startPoint,
          endPoint: _endPoint,
          numRows: _numRows,
          spotSpacing: _spotSpacing,
          rowSpacing: _rowSpacing,
          spots: [],
        );
        // _selectedBeachSection!.numRows = _numRows;
        // _selectedBeachSection!.spotSpacing = _spotSpacing;
        // _selectedBeachSection!.rowSpacing = _rowSpacing;
        // _selectedBeachSection!.startPoint = _startPoint;
        // _selectedBeachSection!.endPoint = _endPoint;
        // _selectedBeachSection!.spots.clear();
        _distributeSpotsForBeachSection(_selectedBeachSection!);
      }
      _selectedBeachSection = null;
      _showInputForm = false;
    });
  }

  void _cancelEdit() {
    setState(() {
      _selectedBeachSection = null;
      _showInputForm = false;
    });
  }

  void _handleTap(LatLng point) {
    if (!_isAddingBeachSection && _selectedBeachSection == null) return;

    setState(() {
      if (_startPoint == null) {
        _startPoint = point;
        _infoMessage = 'Klicke nun den zweiten Punkt des Strandabschnittes an.';
      } else if (_endPoint == null) {
        _endPoint = point;
        if (_selectedBeachSection == null) {
          beachSections.add(BeachSection(
            numRows: _numRows,
            rowSpacing: _rowSpacing,
            spotSpacing: _spotSpacing,
            startPoint: _startPoint,
            endPoint: _endPoint,
            spots: [],
          ));
          _distributeSpotsForBeachSection(beachSections.last);
        } else {
          _updateBeachSection();
        }
        _isAddingBeachSection = false;
        _infoMessage = '';
        _startPoint = null;
        _endPoint = null;
      }
    });
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
