import 'package:geodesy/geodesy.dart';

class BeachSectionService {
  int calculateNumberOfBeachchairsBetweenTwoPoints(LatLng point1, LatLng point2, double spacing) {
    Geodesy geodesy = Geodesy();
    num distance = geodesy.distanceBetweenTwoGeoPoints(point1, point2);
    return (distance ~/ spacing) + 1;
  }

  List<LatLng> distributeSpotsForBeachSection(
    LatLng startPoint,
    LatLng endPoint,
    int numRows,
    double spotSpacing,
    double rowSpacing,
  ) {
    int numberOfMarkersX = calculateNumberOfBeachchairsBetweenTwoPoints(startPoint, endPoint, spotSpacing);
    int numberOfMarkersY = numRows;
    double markerSpacingX = spotSpacing;
    double markerSpacingY = rowSpacing;
    List<LatLng> spots = [];

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

        spots.add(markerPosition);
      }
    }
    return spots;
  }
}
