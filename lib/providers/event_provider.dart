import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'dart:io';

class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<EventModel> get events => _filteredEvents;
  List<EventModel> get allEvents => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<EventModel> get _filteredEvents {
    return _events.where((e) {
      final matchesSearch = _searchQuery.isEmpty ||
          e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.venue.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || e.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<EventModel> get upcomingEvents {
    final now = DateTime.now();
    return _events
        .where((e) => e.date.isAfter(now))
        .take(5)
        .toList();
  }

  void listenToEvents() {
    _firestoreService.getEvents().listen(
      (events) {
        _events = events;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load events.';
        notifyListeners();
      },
    );
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<bool> addEvent({
    required EventModel event,
    File? imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final id = await _firestoreService.addEvent(event);
      if (imageFile != null) {
        final url = await _storageService.uploadEventImage(imageFile, id);
        if (url != null) {
          final updated = EventModel(
            id: id,
            title: event.title,
            description: event.description,
            venue: event.venue,
            date: event.date,
            time: event.time,
            category: event.category,
            imageUrl: url,
            latitude: event.latitude,
            longitude: event.longitude,
            maxParticipants: event.maxParticipants,
            registeredCount: 0,
            isActive: true,
            createdBy: event.createdBy,
            createdAt: event.createdAt,
          );
          await _firestoreService.updateEvent(updated);
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      _error = 'Failed to add event.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      await _firestoreService.deleteEvent(eventId);
      return true;
    } catch (_) {
      _error = 'Failed to delete event.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerForEvent(String eventId, String userId) async {
    try {
      await _firestoreService.registerForEvent(eventId, userId);
      return true;
    } catch (_) {
      _error = 'Registration failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> unregisterFromEvent(String eventId, String userId) async {
    try {
      await _firestoreService.unregisterFromEvent(eventId, userId);
      return true;
    } catch (_) {
      _error = 'Could not cancel registration.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
