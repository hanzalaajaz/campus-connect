import 'package:flutter/material.dart';
import '../models/donation_model.dart';
import '../services/firestore_service.dart';

class DonationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<DonationCampaignModel> _campaigns = [];
  bool _isLoading = false;
  String? _error;

  List<DonationCampaignModel> get campaigns => _campaigns;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<DonationCampaignModel> get activeCampaigns =>
      _campaigns.where((c) => c.isActive && !c.isExpired).toList();

  void listenToCampaigns() {
    _firestoreService.getDonationCampaigns().listen(
      (campaigns) {
        _campaigns = campaigns;
        notifyListeners();
      },
      onError: (_) {
        _error = 'Failed to load campaigns.';
        notifyListeners();
      },
    );
  }

  Future<bool> makeDonation({
    required String campaignId,
    required String userId,
    required String userName,
    required double amount,
    String? message,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final record = DonationRecord(
        id: '',
        campaignId: campaignId,
        userId: userId,
        userName: userName,
        amount: amount,
        message: message,
        donatedAt: DateTime.now(),
      );
      await _firestoreService.makeDonation(record);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      _error = 'Donation failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addCampaign(DonationCampaignModel campaign) async {
    try {
      await _firestoreService.addDonationCampaign(campaign);
      return true;
    } catch (_) {
      _error = 'Failed to add campaign.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
