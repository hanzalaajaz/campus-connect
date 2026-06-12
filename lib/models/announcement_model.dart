import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? imageUrl;
  final bool isPinned;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.imageUrl,
    this.isPinned = false,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
  });

  static const String typeGeneral = 'general';
  static const String typeEvent = 'event';
  static const String typeTrip = 'trip';
  static const String typeUrgent = 'urgent';
  static const String typeAcademic = 'academic';

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? typeGeneral,
      imageUrl: data['imageUrl'],
      isPinned: data['isPinned'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'] ?? 'Admin',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'imageUrl': imageUrl,
      'isPinned': isPinned,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
