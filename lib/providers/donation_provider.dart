import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/donation_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class DonationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

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

  Future<bool> addCampaign({required DonationCampaignModel campaign, XFile? imageFile}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final id = await _firestoreService.addDonationCampaign(campaign);
      if (imageFile != null) {
        final url = await _storageService.uploadDonationImage(imageFile, id);
        if (url != null) {
          final updated = DonationCampaignModel(
            id: id,
            title: campaign.title,
            description: campaign.description,
            category: campaign.category,
            goalAmount: campaign.goalAmount,
            raisedAmount: campaign.raisedAmount,
            imageUrl: url,
            endDate: campaign.endDate,
            isActive: campaign.isActive,
            createdBy: campaign.createdBy,
            createdAt: campaign.createdAt,
          );
          await _firestoreService.updateDonationCampaign(updated);
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      _error = 'Failed to add campaign.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCampaign(String campaignId) async {
    try {
      await _firestoreService.deleteDonationCampaign(campaignId);
      return true;
    } catch (_) {
      _error = 'Failed to delete campaign.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
