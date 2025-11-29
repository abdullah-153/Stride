class UserProfile {
  final String name;
  final String bio;
  final double weight; // in kg
  final double height; // in cm
  final int age;
  final DateTime? dateOfBirth;
  final String? profileImagePath;

  const UserProfile({
    required this.name,
    this.bio = '',
    required this.weight,
    required this.height,
    required this.age,
    this.dateOfBirth,
    this.profileImagePath,
  });

  // Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Copy with method for immutable updates
  UserProfile copyWith({
    String? name,
    String? bio,
    double? weight,
    double? height,
    int? age,
    DateTime? dateOfBirth,
    String? profileImagePath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'weight': weight,
      'height': height,
      'age': age,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'profileImagePath': profileImagePath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      bio: json['bio'] as String? ?? '',
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      age: json['age'] as int,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  // Default profile for new users
  factory UserProfile.defaultProfile() {
    return const UserProfile(
      name: 'User',
      bio: 'Fitness Enthusiast',
      weight: 70.0,
      height: 170.0,
      age: 25,
    );
  }
}
