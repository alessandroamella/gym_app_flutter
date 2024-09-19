// UserAuthDto - Represents the data sent during the user authentication
class UserAuthDto {
  final String fiscalCode;
  final String? username;
  final MediaClass? profilePic;

  UserAuthDto({
    required this.fiscalCode,
    this.username,
    this.profilePic,
  });

  Map<String, dynamic> toJson() {
    return {
      'fiscalCode': fiscalCode,
      'username': username,
      'profilePic': profilePic?.toJson(),
    };
  }

  factory UserAuthDto.fromJson(Map<String, dynamic> json) {
    return UserAuthDto(
      fiscalCode: json['fiscalCode'] as String,
      username: json['username'] as String?,
      profilePic: json['profilePic'] != null
          ? MediaClass.fromJson(json['profilePic'] as Map<String, dynamic>)
          : null,
    );
  }
}

// MediaClass - Represents a media file's URL
class MediaClass {
  final String url;
  final String? type;

  MediaClass({required this.url, this.type});

  factory MediaClass.fromJson(Map<String, dynamic> json) {
    return MediaClass(
      url: json['url'] as String,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type,
    };
  }

  @override
  String toString() {
    return 'MediaClass{url: $url, type: $type}';
  }
}

// UserDto - Represents the data of a logged-in or registered user
class UserDto {
  final int id;
  final MediaClass? profilePic;
  final String username;
  final String birthdate;
  final String updatedAt;
  final String fiscalCode;
  final String gender;
  final String role;
  final String createdAt;
  final List<WorkoutDto> workouts;

  UserDto({
    required this.id,
    this.profilePic,
    required this.username,
    required this.birthdate,
    required this.updatedAt,
    required this.fiscalCode,
    required this.gender,
    required this.role,
    required this.createdAt,
    required this.workouts,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      profilePic: json['profilePic'] != null
          ? MediaClass(url: json['profilePic'] as String)
          : null,
      username: json['username'] as String,
      birthdate: json['birthdate'] as String,
      updatedAt: json['updatedAt'] as String,
      fiscalCode: json['fiscalCode'] as String,
      gender: json['gender'] as String,
      role: json['role'] as String,
      createdAt: json['createdAt'] as String,
      workouts: (json['workouts'] as List<dynamic>)
          .map((workout) => WorkoutDto.fromJson(workout))
          .toList(),
    );
  }
}

// UserWorkoutResponseDto - Represents the user data with workout count information
class UserWorkoutResponseDto {
  final int id;
  final MediaClass? profilePic;
  final String username;
  final int? workoutCount;

  UserWorkoutResponseDto({
    required this.id,
    this.profilePic,
    required this.username,
    this.workoutCount,
  });

  factory UserWorkoutResponseDto.fromJson(Map<String, dynamic> json) {
    return UserWorkoutResponseDto(
      id: json['id'] as int,
      profilePic: json['profilePic'] != null
          ? MediaClass(url: json['profilePic'] as String)
          : null,
      username: json['username'] as String,
      workoutCount:
          (json['_count']?['workouts'] ?? 0) as int, // Defaulting to 0 if null
    );
  }
}

// LoginDto - Represents the login response data
class LoginDto {
  final UserDto user;
  final String token;

  LoginDto({required this.user, required this.token});

  factory LoginDto.fromJson(Map<String, dynamic> json) {
    return LoginDto(
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}

// WorkoutDto - Represents a workout's details
class WorkoutDto {
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final String? notes;
  final int id;
  final List<UserWorkoutResponseDto> users;
  final List<MediaClass> media;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutDto({
    required this.startTime,
    required this.endTime,
    required this.type,
    this.notes,
    required this.id,
    required this.users,
    required this.media,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkoutDto.fromJson(Map<String, dynamic> json) {
    return WorkoutDto(
      id: json['id'] as int,
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      type: json['type'] as String,
      notes: json['notes'] as String?,
      media: (json['media'] as List<dynamic>)
          .map((media) => MediaClass(url: media['url'] as String))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      users: (json['users'] as List<dynamic>)
          .map((user) => UserWorkoutResponseDto.fromJson(user))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type,
      'notes': notes,
      'media': media,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CreateWorkoutDto {
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final String? notes;

  CreateWorkoutDto({
    required this.startTime,
    required this.endTime,
    required this.type,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type,
      'notes': notes,
    };
  }
}
