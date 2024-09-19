import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gym_app_flutter/src/models/user_dto.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl = "https://gym-app.bitrey.it/v1";

  // Helper method to add Bearer token to headers
  Map<String, String> _getAuthHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Login User by QR code
  Future<LoginDto> loginUser(String fiscalCode) async {
    var uri = Uri.parse("$baseUrl/auth/login");
    var request = http.MultipartRequest('POST', uri);

    // Add fiscal code
    request.fields['fiscalCode'] = fiscalCode;

    var response = await request.send();
    var responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonResponse = jsonDecode(responseBody.body);
      debugPrint("Login response: ${jsonEncode(jsonResponse)}");

      return LoginDto.fromJson(jsonResponse);
    } else {
      debugPrint("Failed to login: ${responseBody.body}");
      throw Exception(responseBody.body);
    }
  }

  // Get User Profile
  Future<UserDto> getUserProfile(String token) async {
    var uri = Uri.parse("$baseUrl/auth/profile");
    var response = await http.get(uri, headers: _getAuthHeaders(token));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      debugPrint("Profile response: ${jsonEncode(jsonResponse)}");
      return UserDto.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

// Update User Profile
  Future<LoginDto> updateUserProfile(
    String token,
    String fiscalCode, {
    String? username,
    File? profilePic,
  }) async {
    var uri = Uri.parse("$baseUrl/auth/login");
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['fiscalCode'] = fiscalCode;

    if (username != null) request.fields['username'] = username;

    if (profilePic != null) {
      // Determine the MIME type based on the file path
      var mimeType = lookupMimeType(profilePic.path) ??
          'image/jpeg'; // Default to 'image/jpeg' if MIME type is not found
      var mediaType = MediaType.parse(mimeType);

      request.files.add(http.MultipartFile.fromBytes(
        'profilePic',
        await profilePic.readAsBytes(),
        filename: profilePic.path.split('/').last, // Use the actual file name
        contentType: mediaType,
      ));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await http.Response.fromStream(response);
      var jsonResponse = jsonDecode(responseBody.body);
      return LoginDto.fromJson(jsonResponse);
    } else {
      var responseBody = await http.Response.fromStream(response);
      throw Exception(responseBody.body);
    }
  }

  // Create a new workout
  Future<void> createWorkout(
    String token,
    CreateWorkoutDto workout,
    List<File> images,
  ) async {
    var uri = Uri.parse('$baseUrl/workout');
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['startTime'] = workout.startTime.toIso8601String();
    request.fields['endTime'] = workout.endTime.toIso8601String();
    request.fields['type'] = workout.type;
    if (workout.notes != null) {
      request.fields['notes'] = workout.notes!;
    }

    for (var image in images) {
      var mimeType = lookupMimeType(image.path);
      var file = await http.MultipartFile.fromPath(
        'files',
        image.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      );
      request.files.add(file);
    }

    var response = await request.send();

    if (response.statusCode != 201) {
      var responseBody = await http.Response.fromStream(response);
      throw Exception(responseBody.body);
    }
  }

  // Get a workout by ID
  Future<WorkoutDto> getWorkout(String token, int id) async {
    var uri = Uri.parse("$baseUrl/workout/$id");
    var response = await http.get(uri, headers: _getAuthHeaders(token));

    if (response.statusCode == 200) {
      return WorkoutDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get workout: ${response.body}');
    }
  }

  // Get all workouts
  Future<List<WorkoutDto>> getAllWorkouts(String token) async {
    var uri = Uri.parse("$baseUrl/workout");
    var response = await http.get(uri, headers: _getAuthHeaders(token));

    if (response.statusCode == 200) {
      List<dynamic> workoutsJson = jsonDecode(response.body);
      return workoutsJson.map((json) => WorkoutDto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get workouts: ${response.body}');
    }
  }
}
