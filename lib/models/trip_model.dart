import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String title;
  final String description;
  final String destination;
  final DateTime departureDate;
  final DateTime returnDate;
  final double price;
  final int totalSeats;
  final int bookedSeats;
  final DateTime registrationDeadline;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final List<String> itinerary;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;

  TripModel({
    required this.id,
    required this.title,
    required this.description,
    required this.destination,
    required this.departureDate,
    required this.returnDate,
    required this.price,
    required this.totalSeats,
    this.bookedSeats = 0,
    required this.registrationDeadline,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.itinerary = const [],
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
  });

  int get availableSeats => totalSeats - bookedSeats;
  bool get isFull => bookedSeats >= totalSeats;
  bool get isDeadlinePassed =>
      DateTime.now().isAfter(registrationDeadline);
  bool get hasLocation => latitude != null && longitude != null;

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      destination: data['destination'] ?? '',
      departureDate: (data['departureDate'] as Timestamp).toDate(),
      returnDate: (data['returnDate'] as Timestamp).toDate(),
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      totalSeats: data['totalSeats'] ?? 0,
      bookedSeats: data['bookedSeats'] ?? 0,
      registrationDeadline:
          (data['registrationDeadline'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      itinerary: List<String>.from(data['itinerary'] ?? []),
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'destination': destination,
      'departureDate': Timestamp.fromDate(departureDate),
      'returnDate': Timestamp.fromDate(returnDate),
      'price': price,
      'totalSeats': totalSeats,
      'bookedSeats': bookedSeats,
      'registrationDeadline': Timestamp.fromDate(registrationDeadline),
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'itinerary': itinerary,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
