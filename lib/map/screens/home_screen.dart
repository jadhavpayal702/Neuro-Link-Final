// import 'package:flutter/material.dart';
// import 'map_screen.dart';
// import '../services/geocoding_service.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final TextEditingController startController = TextEditingController();
//   final TextEditingController destController = TextEditingController();

//   bool loading = false;

//   void showRoute() async {
//     final startLoc = startController.text.trim();
//     final destLoc = destController.text.trim();

//     if (startLoc.isEmpty || destLoc.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter both locations")),
//       );
//       return;
//     }

//     setState(() => loading = true);

//     try {
//       final start = await GeocodingService.getCoordinates(startLoc);
//       final dest = await GeocodingService.getCoordinates(destLoc);

//       if (start != null && dest != null) {
//         if (!mounted) return;
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MapScreen(start: start, destination: dest),
//           ),
//         );
//       } else {
//         if (!mounted) return;
//         String errorMsg = "Could not find locations. Try being more specific.";
//         if (start == null && dest == null) errorMsg = "Both locations not found.";
//         else if (start == null) errorMsg = "Start location not found.";
//         else errorMsg = "Destination location not found.";
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMsg)),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("An error occurred: $e")),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => loading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Navigation App"),
//         elevation: 2,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: startController,
//                       decoration: const InputDecoration(
//                         labelText: "Start Location",
//                         prefixIcon: Icon(Icons.my_location, color: Colors.green),
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: destController,
//                       decoration: const InputDecoration(
//                         labelText: "Destination",
//                         prefixIcon: Icon(Icons.location_on, color: Colors.red),
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: loading ? null : showRoute,
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: loading
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Text("Generate Route", style: TextStyle(fontSize: 16)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'map_screen.dart';
import '../services/geocoding_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController startController = TextEditingController();
  final TextEditingController destController = TextEditingController();

  bool loading = false;

  void showRoute() async {
    final startLoc = startController.text.trim();
    final destLoc = destController.text.trim();

    if (startLoc.isEmpty || destLoc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both locations")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final start = await GeocodingService.getCoordinates(startLoc);
      final dest = await GeocodingService.getCoordinates(destLoc);

      if (start != null && dest != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MapScreen(start: start, destination: dest),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid locations")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.orange.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enter Route",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Start Location
                  TextField(
                    controller: startController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Starting Location",
                      prefixIcon: const Icon(Icons.my_location, color: Colors.orange),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.orange),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Destination
                  TextField(
                    controller: destController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Destination",
                      prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.orange),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : showRoute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Generate Route",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}