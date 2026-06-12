import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String venue;
  final DateTime date;
  final String time;
  final String category;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final int? maxParticipants;
  final int registeredCount;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.venue,
    required this.date,
    required this.time,
    required this.category,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.maxParticipants,
    this.registeredCount = 0,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get isFull =>
      maxParticipants != null && registeredCount >= maxParticipants!;
  int get spotsLeft =>
      maxParticipants != null ? maxParticipants! - registeredCount : -1;

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      venue: data['venue'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      category: data['category'] ?? 'Other',
      imageUrl: data['imageUrl'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      maxParticipants: data['maxParticipants'] as int?,
      registeredCount: data['registeredCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'venue': venue,
      'date': Timestamp.fromDate(date),
      'time': time,
      'category': category,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'maxParticipants': maxParticipants,
      'registeredCount': registeredCount,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
