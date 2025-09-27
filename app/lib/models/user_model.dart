class UserModel {
  final String id;
  final String name;
  final String email;
  final String gender;
  final int age;
  final String bodyType;
  final String activityLevel;
  final TemperatureSensitivity temperatureSensitivity;
  final List<String> stylePreferences;
  final Map<String, dynamic> situationPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.bodyType,
    required this.activityLevel,
    required this.temperatureSensitivity,
    required this.stylePreferences,
    required this.situationPreferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      bodyType: json['bodyType'] ?? '',
      activityLevel: json['activityLevel'] ?? '',
      temperatureSensitivity: TemperatureSensitivity.fromJson(json['temperatureSensitivity'] ?? {}),
      stylePreferences: List<String>.from(json['stylePreferences'] ?? []),
      situationPreferences: Map<String, dynamic>.from(json['situationPreferences'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'age': age,
      'bodyType': bodyType,
      'activityLevel': activityLevel,
      'temperatureSensitivity': temperatureSensitivity.toJson(),
      'stylePreferences': stylePreferences,
      'situationPreferences': situationPreferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? gender,
    int? age,
    String? bodyType,
    String? activityLevel,
    TemperatureSensitivity? temperatureSensitivity,
    List<String>? stylePreferences,
    Map<String, dynamic>? situationPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      bodyType: bodyType ?? this.bodyType,
      activityLevel: activityLevel ?? this.activityLevel,
      temperatureSensitivity: temperatureSensitivity ?? this.temperatureSensitivity,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      situationPreferences: situationPreferences ?? this.situationPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TemperatureSensitivity {
  final double coldSensitivity; // -1.0 to 1.0 (more negative = more cold sensitive)
  final double heatSensitivity; // -1.0 to 1.0 (more negative = more heat sensitive)
  final String level; // 'low', 'normal', 'high'

  TemperatureSensitivity({
    required this.coldSensitivity,
    required this.heatSensitivity,
    required this.level,
  });

  factory TemperatureSensitivity.fromJson(Map<String, dynamic> json) {
    return TemperatureSensitivity(
      coldSensitivity: (json['coldSensitivity'] ?? 0.0).toDouble(),
      heatSensitivity: (json['heatSensitivity'] ?? 0.0).toDouble(),
      level: json['level'] ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coldSensitivity': coldSensitivity,
      'heatSensitivity': heatSensitivity,
      'level': level,
    };
  }

  TemperatureSensitivity copyWith({
    double? coldSensitivity,
    double? heatSensitivity,
    String? level,
  }) {
    return TemperatureSensitivity(
      coldSensitivity: coldSensitivity ?? this.coldSensitivity,
      heatSensitivity: heatSensitivity ?? this.heatSensitivity,
      level: level ?? this.level,
    );
  }
}
