import 'package:flutter/material.dart';
import 'package:gym_app_flutter/src/models/user_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_app_flutter/src/services/api_service.dart';

class UserProvider with ChangeNotifier {
  UserDto? _user;
  String? _token;

  UserDto? get user => _user;
  String? get token => _token;

  // set token method
  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  // This method sets the user and token, and also saves the token to SharedPreferences
  void setUser(UserDto user, String token) async {
    _user = user;
    _token = token;

    // Save the token in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);

    notifyListeners();
  }

  // Clear user and token from the provider and SharedPreferences
  void clearUser() async {
    _user = null;
    _token = null;

    // Remove the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    notifyListeners();
  }

  void cancelSavedToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
