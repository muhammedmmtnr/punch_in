import 'package:geolocator/geolocator.dart';
  // Updated coordinates as requested
  static const double TARGET_LATITUDE = 11.261062457428787;

class LocationService {
  static const double TARGET_LONGITUDE = 75.78865503412923;
  static const int RADIUS_METERS = 50;

  static Future<bool> isWithinRange() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position with high accuracy
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calculate distance
      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        TARGET_LATITUDE,
        TARGET_LONGITUDE,
      );

      // Print debug information
      print('Current Position: ${currentPosition.latitude}, ${currentPosition.longitude}');
      print('Distance to target: $distanceInMeters meters');

      return distanceInMeters <= RADIUS_METERS;
    } catch (e) {
      print('Location Error: $e');
      rethrow;
    }
  }

  static Future<double> getCurrentDistance() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      TARGET_LATITUDE,
      TARGET_LONGITUDE,
    );
  }
}