import 'package:latlong2/latlong.dart';

class Beachchair {
  final int number;
  final Size size;
  final LatLng location;

  Beachchair({
    required this.number,
    required this.size,
    required this.location,
  });
}

enum Size {
  small,
  medium,
  large,
}
