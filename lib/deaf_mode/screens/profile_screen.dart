import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../widgets/deaf_theme.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  final UserModel? existingUser;

  const ProfileScreen({super.key, required this.uid, this.existingUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _place;
  late final TextEditingController _city;
  late final ProfileController _controller;

  final List<String> emojiOptions = ['👦', '👧', '🧑', '👨', '👩', '😊', '😎', '🤟', '💯', '👍', '❤️'];

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(FirestoreService(), widget.uid);
    _controller.initialize(widget.existingUser);
    
    _name = TextEditingController(text: widget.existingUser?.name ?? '');
    _email = TextEditingController(text: widget.existingUser?.email ?? '');
    _phone = TextEditingController(text: widget.existingUser?.phone ?? '');
    _place = TextEditingController(text: widget.existingUser?.place ?? '');
    _city = TextEditingController(text: widget.existingUser?.city ?? '');

    _name.addListener(() => _validate());
    _email.addListener(() => _validate());
    _phone.addListener(() => _validate());
    _place.addListener(() => _validate());
    _city.addListener(() => _validate());
  }

  void _validate() {
    _controller.validate(
      _name.text.trim(),
      _email.text.trim(),
      _phone.text.trim(),
      _place.text.trim(),
      _city.text.trim(),
      _controller.user?.profileEmoji ?? '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _place.dispose();
    _city.dispose();
    super.dispose();
  }

  InputDecoration _deco(String label, IconData icon, String? error) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: DeafTheme.orangeA),
      errorText: error,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: DeafTheme.orangeA, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: DeafTheme.bg,
            appBar: AppBar(
              title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              controller.user?.profileEmoji.isNotEmpty == true 
                                ? controller.user!.profileEmoji 
                                : '👤',
                              style: const TextStyle(fontSize: 60),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Select Profile Emoji",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: emojiOptions.map((e) {
                              final isSelected = controller.user?.profileEmoji == e;
                              return GestureDetector(
                                onTap: () {
                                  controller.setEmoji(e);
                                  _validate();
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: isSelected ? DeafTheme.orangeA : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(e, style: const TextStyle(fontSize: 24)),
                                ),
                              );
                            }).toList(),
                          ),
                          if (controller.emojiError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(controller.emojiError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _name,
                      decoration: _deco('Full Name', Icons.person_outline, controller.nameError),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _deco('Email Address', Icons.email_outlined, controller.emailError),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: _deco('Phone Number', Icons.phone_outlined, controller.phoneError).copyWith(counterText: ""),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextField(
                          controller: _place,
                          decoration: _deco('Place', Icons.location_on_outlined, controller.placeError),
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: TextField(
                          controller: _city,
                          decoration: _deco('City', Icons.location_city_outlined, controller.cityError),
                        )),
                      ],
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (controller.loading || !_isFormValid(controller)) ? null : () async {
                          final updatedUser = UserModel(
                            uid: widget.uid,
                            name: _name.text.trim(),
                            email: _email.text.trim(),
                            phone: _phone.text.trim(),
                            place: _place.text.trim(),
                            city: _city.text.trim(),
                            profileEmoji: controller.user!.profileEmoji,
                            createdAt: controller.user!.createdAt ?? DateTime.now(),
                          );
                          await controller.saveProfile(updatedUser);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile saved successfully!')),
                            );
                            Navigator.of(context).pop(true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DeafTheme.orangeA,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          disabledBackgroundColor: DeafTheme.orangeA.withValues(alpha: 0.5),
                        ),
                        child: controller.loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Save Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isFormValid(ProfileController controller) {
    return _name.text.isNotEmpty &&
           _email.text.isNotEmpty &&
           _phone.text.length == 10 &&
           _place.text.isNotEmpty &&
           _city.text.isNotEmpty &&
           controller.user?.profileEmoji.isNotEmpty == true &&
           controller.nameError == null &&
           controller.emailError == null &&
           controller.phoneError == null &&
           controller.placeError == null &&
           controller.cityError == null &&
           controller.emojiError == null;
  }
}
