import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class NavigationService {
  // Use OSRM public routing machine
  static const String baseUrl = "https://router.project-osrm.org/route/v1/foot";

  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    // 🌍 OSRM format: {lon,lat};{lon,lat}?overview=full&geometries=geojson
    final url = "$baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson";

    try {
      debugPrint("Fetching route from OSRM: $url");
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      debugPrint("Navigation Response status: ${response.statusCode}");
      // Print API response for debugging as requested
      debugPrint("Navigation Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 📍 OSRM GeoJSON structure: routes[0].geometry.coordinates
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final List dynamicCoords = data['routes'][0]['geometry']['coordinates'];
          
          final List<LatLng> latLngPoints = dynamicCoords.map<LatLng>((c) {
            // OSRM returns coordinates as [longitude, latitude]
            return LatLng(c[1].toDouble(), c[0].toDouble());
          }).toList();

          debugPrint("✅ Received ${latLngPoints.length} points for polyline");
          return latLngPoints;
        } else {
          debugPrint("⚠️ No routes found in OSRM response");
        }
      } else {
        debugPrint("❌ OSRM Error status: ${response.statusCode}");
        debugPrint("❌ OSRM Error body: ${response.body}");
      }
    } catch (e) {
      debugPrint("⛔ Navigation exception: $e");
    }
    
    return []; // Return empty list on failure
  }
}

