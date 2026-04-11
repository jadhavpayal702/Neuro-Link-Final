import 'package:flutter/material.dart';

typedef FocusableBuilder = Widget Function({required int index, required Widget child});

class GameFindWord extends StatefulWidget {
  final FocusableBuilder focusableBuilder;
  final int focusIndex;
  final ValueNotifier<int?> selectTrigger;
  final VoidCallback onWin;

  const GameFindWord({
    super.key,
    required this.focusableBuilder,
    required this.focusIndex,
    required this.selectTrigger,
    required this.onWin,
  });

  @override
  State<GameFindWord> createState() => _GameFindWordState();
}

class _GameFindWordState extends State<GameFindWord> {
  final List<String> grid = [
    'A', 'B', 'H', 'E',
    'F', 'G', 'E', 'I',
    'K', 'L', 'L', 'N',
    'M', 'O', 'P', 'R',
  ];
  final String target = "HELP";
  List<int> selectedIndices = [];

  @override
  void initState() {
    super.initState();
    widget.selectTrigger.addListener(_onRemoteSelect);
  }

  void _onRemoteSelect() {
    if (!mounted || widget.selectTrigger.value == null) return;
    final idx = widget.selectTrigger.value!;
    if (idx >= 0 && idx < grid.length) {
      _onCellSelect(idx);
    }
  }

  @override
  void dispose() {
    widget.selectTrigger.removeListener(_onRemoteSelect);
    super.dispose();
  }

  void _onCellSelect(int index) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }

      // Check if word formed
      String current = selectedIndices.map((i) => grid[i]).join();
      if (current == target) {
        widget.onWin();
      } else if (current.length >= target.length) {
        selectedIndices.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'FIND THE WORD:',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            target,
            style: const TextStyle(color: Color(0xFFFF6A00), fontSize: 36, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.builder(
              itemCount: grid.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final isFocused = widget.focusIndex == index;
                final isSelected = selectedIndices.contains(index);

                return widget.focusableBuilder(
                  index: index,
                  child: GestureDetector(
                    onTap: () => _onCellSelect(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF6A00) : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isFocused ? Colors.white : const Color(0xFF2A2A2A), width: 2.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        grid[index],
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
