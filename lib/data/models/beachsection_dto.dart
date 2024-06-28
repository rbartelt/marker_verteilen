import 'package:latlong2/latlong.dart';
import '../../domain/entities/beachsection.dart';

class BeachSectionDTO {
  final String id;
  final int numRows;
  final double spotSpacing;
  final double rowSpacing;
  final LatLng startPoint;
  final LatLng endPoint;
  final List<LatLng> spots;

  BeachSectionDTO({
    required this.id,
    required this.numRows,
    required this.spotSpacing,
    required this.rowSpacing,
    required this.startPoint,
    required this.endPoint,
    required this.spots,
  });

// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numrows': numRows,
      'spotspacing': spotSpacing,
      'rowspacing': rowSpacing,
      'startpoint': {'lat': startPoint.latitude, 'lng': startPoint.longitude},
      'endpoint': {'lat': endPoint.latitude, 'lng': endPoint.longitude},
      'spots': spots.map((spot) => {'lat': spot.latitude, 'lng': spot.longitude}).toList(),
    };
  }

// JSON deserialization
  factory BeachSectionDTO.fromJson(Map<String, dynamic> json) {
    return BeachSectionDTO(
      id: json['id'],
      numRows: json['numrows'],
      spotSpacing: json['spotspacing'],
      rowSpacing: json['rowspacing'],
      startPoint: LatLng(json['startpoint']['lat'], json['startpoint']['lng']),
      endPoint: LatLng(json['endpoint']['lat'], json['endpoint']['lng']),
      spots: (json['spots'] as List).map((spot) => LatLng(spot['lat'], spot['lng'])).toList(),
    );
  }

  // Konvertierung von und zu Domain-Objekten
  BeachSection toDomain() {
    return BeachSection(
      id: id,
      numRows: numRows,
      spotSpacing: spotSpacing,
      rowSpacing: rowSpacing,
      startPoint: startPoint,
      endPoint: endPoint,
      spots: spots,
    );
  }

  factory BeachSectionDTO.fromDomain(BeachSection section) {
    return BeachSectionDTO(
      id: section.id,
      numRows: section.numRows,
      spotSpacing: section.spotSpacing,
      rowSpacing: section.rowSpacing,
      startPoint: section.startPoint,
      endPoint: section.endPoint,
      spots: section.spots,
    );
  }
}
