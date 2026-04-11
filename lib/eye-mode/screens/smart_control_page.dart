import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

typedef FocusableBuilder = Widget Function({
  required int index,
  required Widget child,
});

class SmartControlPage extends StatefulWidget {
  final FocusableBuilder focusableBuilder;
  final int focusIndex;
  final bool lightOn;
  final bool fanOn;
  final bool sosArmed;
  final VoidCallback onToggleLight;
  final VoidCallback onToggleFan;
  final VoidCallback onTriggerSOS;
  final Widget sectionHeader;
  final Widget bottomNav;
  final ValueNotifier<int?> selectTrigger;

  const SmartControlPage({
    super.key,
    required this.focusableBuilder,
    required this.focusIndex,
    required this.lightOn,
    required this.fanOn,
    required this.sosArmed,
    required this.onToggleLight,
    required this.onToggleFan,
    required this.onTriggerSOS,
    required this.sectionHeader,
    required this.bottomNav,
    required this.selectTrigger,
  });

  @override
  State<SmartControlPage> createState() => _SmartControlPageState();
}

class _SmartControlPageState extends State<SmartControlPage> {
  // ✅ FIXED IoT FUNCTION
  Future<void> _toggleLightIoT(bool currentState) async {
    const String baseUrl = "http://172.20.10.2"; // SAME as Deaf Mode

    try {
      final url = currentState
          ? "$baseUrl/off"   // 🔥 FIXED
          : "$baseUrl/on";   // 🔥 FIXED

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        debugPrint("ESP Response: ${response.body}");
      } else {
        debugPrint("ESP Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("IoT Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    widget.selectTrigger.addListener(_onRemoteSelect);
  }

  @override
  void dispose() {
    widget.selectTrigger.removeListener(_onRemoteSelect);
    super.dispose();
  }

  void _onRemoteSelect() {
    if (!mounted || widget.selectTrigger.value == null) return;
    final idx = widget.selectTrigger.value!;
    
    // index 0 -> Light
    if (idx == 0) {
      _toggleLightIoT(widget.lightOn);
      widget.onToggleLight();
    }
    // index 1 -> Fan
    else if (idx == 1) {
      widget.onToggleFan();
    }
    // index 2 -> SOS
    else if (idx == 2) {
      widget.onTriggerSOS();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.sectionHeader,
        const SizedBox(height: 10),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: widget.focusableBuilder(
                        index: 0,
                        child: _toggleTile(
                          label: 'Light',
                          enabled: widget.lightOn,
                          onTap: () async {
                            debugPrint("LIGHT TRIGGERED"); 
                            await _toggleLightIoT(widget.lightOn);
                            widget.onToggleLight();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: widget.focusableBuilder(
                        index: 1,
                        child: _toggleTile(
                          label: 'Fan',
                          enabled: widget.fanOn,
                          onTap: widget.onToggleFan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: widget.focusableBuilder(
                  index: 2,
                  child: _largeButton(
                    label: widget.sosArmed ? 'SOS Armed' : 'SOS Emergency',
                    color: const Color(0xFFE53935),
                    onTap: widget.onTriggerSOS,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        widget.bottomNav,
      ],
    );
  }

  Widget _toggleTile({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF1B5E20) : const Color(0xFF111C30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled ? const Color(0xFF7CFF8A) : const Color(0xFF2A3D61),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '$label ${enabled ? 'ON' : 'OFF'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _largeButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 64,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}