import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '19218d4839024b60945101013240612'; // Replace with your actual WeatherAPI key

  Future<Map<String, dynamic>> fetchWeatherByCity(String cityName) async {
    final url =
        'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$cityName';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      if (decodedResponse != null && decodedResponse is Map<String, dynamic>) {
        return decodedResponse;
      } else {
        throw Exception('Invalid or empty response from WeatherAPI.');
      }
    } else {
      throw Exception('Failed to fetch weather: ${response.body}');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are denied.');
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      return placemarks[0].locality ?? 'Unknown City';
    } else {
      throw Exception('Could not determine the current city.');
    }
  }
}
