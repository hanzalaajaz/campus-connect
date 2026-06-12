import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String department;
  final String semester;
  final String role;
  final String? photoUrl;
  final String? fcmToken;
  final List<String> registeredEvents;
  final List<String> registeredTrips;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.department,
    required this.semester,
    required this.role,
    this.photoUrl,
    this.fcmToken,
    this.registeredEvents = const [],
    this.registeredTrips = const [],
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      role: map['role'] ?? 'student',
      photoUrl: map['photoUrl'],
      fcmToken: map['fcmToken'],
      registeredEvents: List<String>.from(map['registeredEvents'] ?? []),
      registeredTrips: List<String>.from(map['registeredTrips'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'department': department,
      'semester': semester,
      'role': role,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'registeredEvents': registeredEvents,
      'registeredTrips': registeredTrips,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? department,
    String? semester,
    String? role,
    String? photoUrl,
    String? fcmToken,
    List<String>? registeredEvents,
    List<String>? registeredTrips,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      registeredEvents: registeredEvents ?? this.registeredEvents,
      registeredTrips: registeredTrips ?? this.registeredTrips,
      createdAt: createdAt,
    );
  }
}
