import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static Future<LatLng?> getCoordinates(String place) async {
    try {
      final url =
          "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(place)}&format=json&limit=1";

      debugPrint("Geocoding request: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'FlutterNavigationApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat'].toString());
          final lon = double.tryParse(data[0]['lon'].toString());

          if (lat != null && lon != null) {
            debugPrint("Geocoding success: $lat, $lon");
            return LatLng(lat, lon);
          }
        }
      } else {
        debugPrint("Geocoding error: Status code ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Geocoding exception: $e");
    }
    return null;
  }
}
