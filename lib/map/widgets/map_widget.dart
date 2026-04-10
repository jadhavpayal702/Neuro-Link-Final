import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  final LatLng start;
  final LatLng destination;
  final List<LatLng> routePoints;
  final MapController? mapController; // 🛠 Add MapController

  const MapWidget({
    super.key,
    required this.start,
    required this.destination,
    required this.routePoints,
    this.mapController, // 🛠 Accept MapController
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController, // 🛠 Assign MapController
      options: MapOptions(
        initialCenter: start,
        initialZoom: 14,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.flutter_application_map',
        ),

        if (routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 6, // 🔴 Increased width
                color: Colors.red, // 🔴 High visibility color
                borderColor: Colors.red.darken(0.2), // Added dark border
                borderStrokeWidth: 2,
              ),
            ],
          ),

        MarkerLayer(
          markers: [
            Marker(
              point: start,
              width: 50,
              height: 50,
              child: const Column(
                children: [
                  Icon(Icons.location_on, color: Colors.green, size: 35),
                  Text(
                    "Start",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ],
              ),
            ),
            Marker(
              point: destination,
              width: 50,
              height: 50,
              child: const Column(
                children: [
                  Icon(Icons.location_on, color: Colors.red, size: 35),
                  Text(
                    "End",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 🎨 Helper extension for darkening colors
extension ColorDarken on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
