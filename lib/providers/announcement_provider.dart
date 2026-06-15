import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/firestore_service.dart';

class AnnouncementProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String? _error;

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AnnouncementModel> get recentAnnouncements =>
      _announcements.take(3).toList();

  AnnouncementProvider() {
    listenToAnnouncements();
  }

  void listenToAnnouncements() {
    _service.getAnnouncements().listen(
      (data) {
        _announcements = data;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> addAnnouncement(AnnouncementModel announcement) async {
    try {
      await _service.addAnnouncement(announcement);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAnnouncement(String id) async {
    try {
      await _service.deleteAnnouncement(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
