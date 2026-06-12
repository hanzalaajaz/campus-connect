import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'dart:io';

class TripProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<TripModel> _trips = [];
  bool _isLoading = false;
  String? _error;

  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TripModel> get availableTrips =>
      _trips.where((t) => !t.isFull && !t.isDeadlinePassed).toList();

  void listenToTrips() {
    _firestoreService.getTrips().listen(
      (trips) {
        _trips = trips;
        notifyListeners();
      },
      onError: (_) {
        _error = 'Failed to load trips.';
        notifyListeners();
      },
    );
  }

  Future<bool> addTrip({required TripModel trip, File? imageFile}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final id = await _firestoreService.addTrip(trip);
      if (imageFile != null) {
        final url = await _storageService.uploadTripImage(imageFile, id);
        if (url != null) {
          final updated = TripModel(
            id: id,
            title: trip.title,
            description: trip.description,
            destination: trip.destination,
            departureDate: trip.departureDate,
            returnDate: trip.returnDate,
            price: trip.price,
            totalSeats: trip.totalSeats,
            registrationDeadline: trip.registrationDeadline,
            imageUrl: url,
            latitude: trip.latitude,
            longitude: trip.longitude,
            itinerary: trip.itinerary,
            createdBy: trip.createdBy,
            createdAt: trip.createdAt,
          );
          await _firestoreService.updateTrip(updated);
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      _error = 'Failed to add trip.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTrip(String tripId) async {
    try {
      await _firestoreService.deleteTrip(tripId);
      return true;
    } catch (_) {
      _error = 'Failed to delete trip.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerForTrip(String tripId, String userId) async {
    try {
      await _firestoreService.registerForTrip(tripId, userId);
      return true;
    } catch (_) {
      _error = 'Trip registration failed.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> unregisterFromTrip(String tripId, String userId) async {
    try {
      await _firestoreService.unregisterFromTrip(tripId, userId);
      return true;
    } catch (_) {
      _error = 'Could not cancel trip registration.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
