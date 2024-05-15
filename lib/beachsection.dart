import 'package:latlong2/latlong.dart';

/// Represents a section of a beach, including its start and end points, number of rows, row spacing, spot spacing, and a list of spots.
///
/// The [BeachSection] class provides a way to encapsulate the properties and behavior of a specific section of a beach. It allows you to create and manipulate beach sections, including copying them with modified properties.
///
/// The [startPoint] and [endPoint] properties represent the geographic coordinates of the start and end points of the beach section, respectively. The [numRows] property specifies the number of rows in the beach section, while [rowSpacing] and [spotSpacing] define the spacing between rows and spots, respectively. The [spots] property is a list of geographic coordinates representing the individual spots within the beach section. Every spot is a potential location for a beachchair.
/// By comparing the spot location and the associated beach chair location, it can be checked whether the beach chair is still in the correct position.
///
/// The [copyWith] method allows you to create a new [BeachSection] instance with modified properties, without affecting the original instance.

class BeachSection {
  LatLng? startPoint;
  LatLng? endPoint;
  final int numRows;
  final double rowSpacing;
  final double spotSpacing;
  final List<LatLng> spots;

  BeachSection({
    this.startPoint,
    this.endPoint,
    required this.numRows,
    required this.rowSpacing,
    required this.spotSpacing,
    required this.spots,
  });

  BeachSection copyWith({LatLng? startPoint, LatLng? endPoint, int? numRows, double? spotSpacing, double? rowSpacing, List<LatLng>? spots}) {
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
