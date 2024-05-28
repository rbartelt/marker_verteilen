import 'package:geodesy/geodesy.dart';
import '../entities/beachsection.dart';

class BeachSectionService {
  int calculateNumberOfBeachchairsBetweenTwoPoints(LatLng point1, LatLng point2, double spacing) {
    Geodesy geodesy = Geodesy();
    num distance = geodesy.distanceBetweenTwoGeoPoints(point1, point2);
    return (distance ~/ spacing) + 1;
  }

  void distributeSpotsForBeachSection(BeachSection section) {
    int numberOfMarkersX = calculateNumberOfBeachchairsBetweenTwoPoints(section.startPoint!, section.endPoint!, section.spotSpacing);
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
