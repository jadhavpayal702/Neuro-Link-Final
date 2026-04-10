import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/profile_screen.dart';
import '../widgets/deaf_theme.dart';

class ProfileBarrier {
  static void check(BuildContext context, UserModel? user, VoidCallback onAllowed) {
    if (user?.profileCompleted == true) {
      onAllowed();
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person, size: 64, color: DeafTheme.orangeA),
                const SizedBox(height: 24),
                const Text(
                  "Profile Incomplete",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "You must complete your profile to use this feature.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProfileScreen(
                            uid: user?.uid ?? '',
                            existingUser: user,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DeafTheme.orangeA,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Complete Profile",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Maybe Later", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
