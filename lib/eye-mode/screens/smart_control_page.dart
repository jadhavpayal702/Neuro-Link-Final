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
  Future<void> _toggleLightIoT(bool currentState) async {
    const String baseUrl = "http://172.20.10.2";
    try {
      final url = currentState ? "$baseUrl/off" : "$baseUrl/on";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        debugPrint("ESP Response: ${response.body}");
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
    if (idx == 0) {
      _toggleLightIoT(widget.lightOn);
      widget.onToggleLight();
    } else if (idx == 1) {
      widget.onToggleFan();
    } else if (idx == 2) {
      widget.onTriggerSOS();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.sectionHeader,
        const SizedBox(height: 8),
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
                            await _toggleLightIoT(widget.lightOn);
                            widget.onToggleLight();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
              const SizedBox(height: 16),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: enabled ? Colors.green.withOpacity(0.12) : Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    label == 'Light' ? Icons.lightbulb_outline_rounded : Icons.air_rounded,
                    size: 32, // Reduced from 48
                    color: enabled ? Colors.green : Colors.white24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$label ${enabled ? 'ON' : 'OFF'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Reduced from 22
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
      height: 64, // Reduced from 80
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        child: Text(label),
      ),
    );
  }
}