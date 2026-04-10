import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/navigation_service.dart';
import '../widgets/map_widget.dart';

class MapScreen extends StatefulWidget {
  final LatLng start;
  final LatLng destination;

  const MapScreen({super.key, required this.start, required this.destination});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController(); 
  List<LatLng> routePoints = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadRoute();
  }

  void loadRoute() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final route = await NavigationService.getRoute(
        widget.start,
        widget.destination,
      );

      if (mounted) {
        setState(() {
          routePoints = route;
          loading = false;
          if (route.isEmpty) {
            //errorMessage = "No walking route found. Check your connection or locations.";
          }
        });

        // 📏 Fit map to route bounds
        if (route.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                final bounds = LatLngBounds.fromPoints(route);
                mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(70), // Increased padding for better visibility
                  ),
                );
                debugPrint("📏 Map bounds fitted to route (${route.length} points)");
              } catch (e) {
                debugPrint("⚠️ Fitting bounds failed: $e");
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Error in loadRoute: $e");
      if (mounted) {
        setState(() {
          errorMessage = "Error loading route. Please try again.";
          loading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Route Map"),backgroundColor:Colors.orange ,),
      body: Stack(
        children: [
          MapWidget(
            start: widget.start,
            destination: widget.destination,
            routePoints: routePoints,
            mapController: mapController, // 🛠 Pass MapController
          ),
          if (loading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (errorMessage != null && !loading)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.redAccent,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
