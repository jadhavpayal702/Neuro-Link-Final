import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class ProfileController extends ChangeNotifier {
  final FirestoreService _service;
  final String uid;

  ProfileController(this._service, this.uid);

  UserModel? _user;
  UserModel? get user => _user;

  bool _loading = false;
  bool get loading => _loading;

  String? nameError;
  String? emailError;
  String? phoneError;
  String? placeError;
  String? cityError;
  String? emojiError;

  void initialize(UserModel? existing) {
    _user = existing ?? UserModel(
      uid: uid,
      name: '',
      email: '',
      phone: '',
      place: '',
      city: '',
      profileEmoji: '',
    );
    notifyListeners();
  }

  bool validate(String name, String email, String phone, String place, String city, String emoji) {
    bool isValid = true;

    if (name.isEmpty) {
      nameError = "Name is required";
      isValid = false;
    } else {
      nameError = null;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty) {
      emailError = "Email is required";
      isValid = false;
    } else if (!emailRegex.hasMatch(email)) {
      emailError = "Invalid email format";
      isValid = false;
    } else {
      emailError = null;
    }

    if (phone.length != 10) {
      phoneError = "Phone must be exactly 10 digits";
      isValid = false;
    } else {
      phoneError = null;
    }

    if (place.isEmpty) {
      placeError = "Place is required";
      isValid = false;
    } else {
      placeError = null;
    }

    if (city.isEmpty) {
      cityError = "City is required";
      isValid = false;
    } else {
      cityError = null;
    }

    if (emoji.isEmpty) {
      emojiError = "Profile emoji is required";
      isValid = false;
    } else {
      emojiError = null;
    }

    notifyListeners();
    return isValid;
  }

  void setEmoji(String emoji) {
    _user = UserModel(
      uid: _user!.uid,
      name: _user!.name,
      email: _user!.email,
      phone: _user!.phone,
      place: _user!.place,
      city: _user!.city,
      profileEmoji: emoji,
      profileCompleted: _user!.profileCompleted,
      createdAt: _user!.createdAt,
    );
    emojiError = null;
    notifyListeners();
  }

  Future<void> saveProfile(UserModel updatedUser) async {
    _loading = true;
    notifyListeners();
    try {
      final userWithCompletion = UserModel(
        uid: updatedUser.uid,
        name: updatedUser.name,
        email: updatedUser.email,
        phone: updatedUser.phone,
        place: updatedUser.place,
        city: updatedUser.city,
        profileEmoji: updatedUser.profileEmoji,
        profileCompleted: true,
        createdAt: updatedUser.createdAt,
      );
      await _service.saveUserProfile(userWithCompletion);
      _user = userWithCompletion;
    } catch (e) {
      if (kDebugMode) print("Error saving profile: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
