import 'package:latlong2/latlong.dart';

class BeachSection {
  LatLng? startPoint;
  LatLng? endPoint;
  int numRows;
  double rowSpacing;
  double spotSpacing;
  List<LatLng> spots;

  BeachSection({
    this.startPoint,
    this.endPoint,
    required this.numRows,
    required this.rowSpacing,
    required this.spotSpacing,
    required this.spots,
  });

  BeachSection copyWith({
    LatLng? startPoint,
    LatLng? endPoint,
    int? numRows,
    double? spotSpacing,
    double? rowSpacing,
    List<LatLng>? spots,
  }) {
    return BeachSection(
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      numRows: numRows ?? this.numRows,
      rowSpacing: rowSpacing ?? this.rowSpacing,
      spotSpacing: spotSpacing ?? this.spotSpacing,
      spots: spots ?? this.spots,
    );
  }
}
