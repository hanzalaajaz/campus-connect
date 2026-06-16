import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/trip_model.dart';
import '../models/donation_model.dart';
import '../models/announcement_model.dart';
import '../utils/app_constants.dart';
import 'mock_database.dart';

class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ─── EVENTS ─────────────────────────────────────────────────────────────────

  Stream<List<EventModel>> getEvents() {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.getEvents();
    }
    return _db
        .collection(AppConstants.eventsCollection)
        .orderBy('date', descending: false)
        .snapshots()
        .map((s) => s.docs.map(EventModel.fromFirestore).where((e) => e.isActive).toList());
  }

  Future<String> addEvent(EventModel event) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.addEvent(event);
    }
    final ref =
        await _db.collection(AppConstants.eventsCollection).add(event.toMap());
    return ref.id;
  }

  Future<void> updateEvent(EventModel event) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.updateEvent(event);
    }
    await _db
        .collection(AppConstants.eventsCollection)
        .doc(event.id)
        .update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.deleteEvent(eventId);
    }
    await _db
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .update({'isActive': false});
  }

  Future<void> registerForEvent(String eventId, String userId) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.registerForEvent(eventId, userId);
    }
    final batch = _db.batch();
    final eventRef =
        _db.collection(AppConstants.eventsCollection).doc(eventId);
    final userRef =
        _db.collection(AppConstants.usersCollection).doc(userId);

    batch.update(eventRef, {
      'registeredCount': FieldValue.increment(1),
    });
    batch.update(userRef, {
      'registeredEvents': FieldValue.arrayUnion([eventId]),
    });

    await batch.commit();
  }

  Future<void> unregisterFromEvent(String eventId, String userId) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.unregisterFromEvent(eventId, userId);
    }
    final batch = _db.batch();
    final eventRef =
        _db.collection(AppConstants.eventsCollection).doc(eventId);
    final userRef =
        _db.collection(AppConstants.usersCollection).doc(userId);

    batch.update(eventRef, {
      'registeredCount': FieldValue.increment(-1),
    });
    batch.update(userRef, {
      'registeredEvents': FieldValue.arrayRemove([eventId]),
    });

    await batch.commit();
  }

  // ─── TRIPS ──────────────────────────────────────────────────────────────────

  Stream<List<TripModel>> getTrips() {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.getTrips();
    }
    return _db
        .collection(AppConstants.tripsCollection)
        .orderBy('departureDate', descending: false)
        .snapshots()
        .map((s) => s.docs.map(TripModel.fromFirestore).where((t) => t.isActive).toList());
  }

  Future<String> addTrip(TripModel trip) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.addTrip(trip);
    }
    final ref =
        await _db.collection(AppConstants.tripsCollection).add(trip.toMap());
    return ref.id;
  }

  Future<void> updateTrip(TripModel trip) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.updateTrip(trip);
    }
    await _db
        .collection(AppConstants.tripsCollection)
        .doc(trip.id)
        .update(trip.toMap());
  }

  Future<void> deleteTrip(String tripId) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.deleteTrip(tripId);
    }
    await _db
        .collection(AppConstants.tripsCollection)
        .doc(tripId)
        .update({'isActive': false});
  }

  Future<void> registerForTrip(String tripId, String userId) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.registerForTrip(tripId, userId);
    }
    final batch = _db.batch();
    final tripRef = _db.collection(AppConstants.tripsCollection).doc(tripId);
    final userRef =
        _db.collection(AppConstants.usersCollection).doc(userId);

    batch.update(tripRef, {'bookedSeats': FieldValue.increment(1)});
    batch.update(userRef, {
      'registeredTrips': FieldValue.arrayUnion([tripId]),
    });

    await batch.commit();
  }

  Future<void> unregisterFromTrip(String tripId, String userId) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.unregisterFromTrip(tripId, userId);
    }
    final batch = _db.batch();
    final tripRef = _db.collection(AppConstants.tripsCollection).doc(tripId);
    final userRef =
        _db.collection(AppConstants.usersCollection).doc(userId);

    batch.update(tripRef, {'bookedSeats': FieldValue.increment(-1)});
    batch.update(userRef, {
      'registeredTrips': FieldValue.arrayRemove([tripId]),
    });

    await batch.commit();
  }

  // ─── DONATIONS ──────────────────────────────────────────────────────────────

  Stream<List<DonationCampaignModel>> getDonationCampaigns() {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.getDonationCampaigns();
    }
    return _db
        .collection(AppConstants.donationsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(DonationCampaignModel.fromFirestore).where((c) => c.isActive).toList());
  }

  Future<String> addDonationCampaign(DonationCampaignModel campaign) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.addDonationCampaign(campaign);
    }
    final ref = await _db
        .collection(AppConstants.donationsCollection)
        .add(campaign.toMap());
    return ref.id;
  }

  Future<void> makeDonation(DonationRecord record) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.makeDonation(record);
    }
    final batch = _db.batch();
    final campaignRef = _db
        .collection(AppConstants.donationsCollection)
        .doc(record.campaignId);
    final recordRef = _db
        .collection(AppConstants.donationsCollection)
        .doc(record.campaignId)
        .collection('records')
        .doc();

    batch.update(campaignRef, {
      'raisedAmount': FieldValue.increment(record.amount),
    });
    batch.set(recordRef, record.toMap());

    await batch.commit();
  }

  // ─── ANNOUNCEMENTS ──────────────────────────────────────────────────────────

  Stream<List<AnnouncementModel>> getAnnouncements() {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.getAnnouncements();
    }
    return _db
        .collection(AppConstants.announcementsCollection)
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AnnouncementModel.fromFirestore).toList());
  }

  Future<String> addAnnouncement(AnnouncementModel announcement) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.addAnnouncement(announcement);
    }
    final ref = await _db
        .collection(AppConstants.announcementsCollection)
        .add(announcement.toMap());
    return ref.id;
  }

  Future<void> deleteAnnouncement(String id) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.deleteAnnouncement(id);
    }
    await _db
        .collection(AppConstants.announcementsCollection)
        .doc(id)
        .delete();
  }

  Stream<List<AnnouncementModel>> getRecentAnnouncements({int limit = 3}) {
    if (AppConstants.isDemoMode) {
      return getAnnouncements().map((list) => list.take(limit).toList());
    }
    return _db
        .collection(AppConstants.announcementsCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(AnnouncementModel.fromFirestore).toList());
  }

  Future<void> updateDonationCampaign(DonationCampaignModel campaign) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.updateDonationCampaign(campaign);
    }
    await _db
        .collection(AppConstants.donationsCollection)
        .doc(campaign.id)
        .update(campaign.toMap());
  }

  Future<void> deleteDonationCampaign(String id) async {
    if (AppConstants.isDemoMode) {
      return MockDatabase.instance.deleteDonationCampaign(id);
    }
    await _db
        .collection(AppConstants.donationsCollection)
        .doc(id)
        .update({'isActive': false});
  }
}
