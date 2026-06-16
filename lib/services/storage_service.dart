import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_constants.dart';

class StorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage({bool fromCamera = false}) async {
    final picked = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    return picked;
  }

  Future<String?> uploadEventImage(XFile file, String eventId) async {
    if (AppConstants.isDemoMode) {
      return 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800';
    }
    return await _uploadFile(file, 'events/$eventId.jpg');
  }

  Future<String?> uploadTripImage(XFile file, String tripId) async {
    if (AppConstants.isDemoMode) {
      return 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800';
    }
    return await _uploadFile(file, 'trips/$tripId.jpg');
  }

  Future<String?> uploadDonationImage(XFile file, String campaignId) async {
    if (AppConstants.isDemoMode) {
      return 'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=800';
    }
    return await _uploadFile(file, 'donations/$campaignId.jpg');
  }

  Future<String?> uploadProfilePhoto(XFile file, String userId) async {
    if (AppConstants.isDemoMode) {
      return 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150';
    }
    return await _uploadFile(file, 'profiles/$userId.jpg');
  }

  Future<String?> _uploadFile(XFile file, String path) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteFile(String url) async {
    if (AppConstants.isDemoMode) return;
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}
