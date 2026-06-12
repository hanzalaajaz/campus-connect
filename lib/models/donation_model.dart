import 'package:cloud_firestore/cloud_firestore.dart';

class DonationCampaignModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double goalAmount;
  final double raisedAmount;
  final String? imageUrl;
  final DateTime endDate;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;

  DonationCampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.goalAmount,
    this.raisedAmount = 0.0,
    this.imageUrl,
    required this.endDate,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
  });

  double get progressPercent =>
      goalAmount > 0 ? (raisedAmount / goalAmount).clamp(0.0, 1.0) : 0.0;
  bool get isGoalReached => raisedAmount >= goalAmount;
  bool get isExpired => DateTime.now().isAfter(endDate);

  factory DonationCampaignModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DonationCampaignModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Other',
      goalAmount: (data['goalAmount'] as num?)?.toDouble() ?? 0.0,
      raisedAmount: (data['raisedAmount'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'],
      endDate: (data['endDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'goalAmount': goalAmount,
      'raisedAmount': raisedAmount,
      'imageUrl': imageUrl,
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class DonationRecord {
  final String id;
  final String campaignId;
  final String userId;
  final String userName;
  final double amount;
  final String? message;
  final DateTime donatedAt;

  DonationRecord({
    required this.id,
    required this.campaignId,
    required this.userId,
    required this.userName,
    required this.amount,
    this.message,
    required this.donatedAt,
  });

  factory DonationRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DonationRecord(
      id: doc.id,
      campaignId: data['campaignId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      message: data['message'],
      donatedAt:
          (data['donatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'campaignId': campaignId,
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'message': message,
      'donatedAt': Timestamp.fromDate(donatedAt),
    };
  }
}
