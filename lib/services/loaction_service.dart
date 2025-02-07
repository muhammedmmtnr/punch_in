
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double TARGET_LATITUDE = 11.261062457428787;
  static const double TARGET_LONGITUDE = 75.78865503412923;
  static const int RADIUS_METERS = 50;

  static String _currentAddress = '';
  static Position? _currentPosition;

  static Future<void> initializeLocation() async {
    Position position = await _getGeoLocationPosition();
    _currentPosition = position;
    _currentAddress = await _getAddressFromLatLong(position);
    
    print('Location Initialized:');
    print('Position: ${position.latitude}, ${position.longitude}');
    print('Address: $_currentAddress');
  }

  static Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation
    );
  }

  static Future<String> _getAddressFromLatLong(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      if (placemarks.isEmpty) {
        return 'Unknown location';
      }

      Placemark place = placemarks[0];
      return '${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}';
    } catch (e) {
      print('Error getting address: $e');
      return 'Error getting address';
    }
  }

  static Future<bool> isWithinRange() async {
    Position position = await _getGeoLocationPosition();
    _currentPosition = position;
    _currentAddress = await _getAddressFromLatLong(position);

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      TARGET_LATITUDE,
      TARGET_LONGITUDE,
    );

    print('Current Location: $_currentAddress');
    print('Distance to target: $distance meters');

    return distance <= RADIUS_METERS;
  }

  // Getter methods
  static Future<String> getAddress() async {
    if (_currentAddress.isEmpty) {
      await initializeLocation();
    }
    return _currentAddress;
  }

  static Future<Position?> getPosition() async {
    if (_currentPosition == null) {
      await initializeLocation();
    }
    return _currentPosition;
  }
}