import 'dart:async';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/trip_model.dart';
import '../models/donation_model.dart';
import '../models/announcement_model.dart';

class MockDatabase {
  MockDatabase._();
  static final MockDatabase instance = MockDatabase._();

  // ─── AUTHENTICATION STATE ──────────────────────────────────────────────────
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  final StreamController<UserModel?> _authStreamController =
      StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get authStateChanges => _authStreamController.stream;

  // ─── DATA STORES ────────────────────────────────────────────────────────────
  final List<UserModel> _users = [
    UserModel(
      uid: 'admin-123',
      name: 'Director COMSATS',
      email: 'admin@campusconnect.com',
      department: 'Computer Science',
      semester: '8th',
      role: 'admin',
      photoUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserModel(
      uid: 'student-456',
      name: 'Ali Ahmed',
      email: 'student@campusconnect.com',
      department: 'Artificial Intelligence',
      semester: '6th',
      role: 'student',
      photoUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150',
      registeredEvents: ['event-1'],
      registeredTrips: ['trip-1'],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  final List<EventModel> _events = [
    EventModel(
      id: 'event-1',
      title: 'COMSATS AI Hackathon 2026',
      description: 'Join the ultimate 24-hour hackathon to build innovative AI solutions addressing real-world challenges. Free mentoring, networking, and exciting cash prizes for winners!',
      venue: 'Seminar Hall, Academic Block 2',
      date: DateTime.now().add(const Duration(days: 5)),
      time: '09:00 AM - 05:00 PM',
      category: 'Technology',
      imageUrl: 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800',
      latitude: 33.6844,
      longitude: 73.0479,
      maxParticipants: 150,
      registeredCount: 42,
      createdBy: 'admin-123',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    EventModel(
      id: 'event-2',
      title: 'Annual Sports Gala 2026',
      description: 'Prepare yourself for the highly anticipated CUI Sports Gala! Participate in cricket, football, table tennis, badminton, and track events. Registrations are open for all departments.',
      venue: 'Main Sports Complex & Ground',
      date: DateTime.now().add(const Duration(days: 12)),
      time: '08:00 AM - 06:00 PM',
      category: 'Sports',
      imageUrl: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800',
      latitude: 33.6852,
      longitude: 73.0485,
      maxParticipants: 500,
      registeredCount: 120,
      createdBy: 'admin-123',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    EventModel(
      id: 'event-3',
      title: 'Symphony Cultural Fest',
      description: 'Experience a vibrant display of music, art, traditional cuisines, and cultural dress representation from across Pakistan. Special guest performances will close the evening.',
      venue: 'CUI Central Lawns',
      date: DateTime.now().add(const Duration(days: 20)),
      time: '04:00 PM - 10:00 PM',
      category: 'Cultural',
      imageUrl: 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800',
      latitude: 33.6840,
      longitude: 73.0470,
      maxParticipants: 800,
      registeredCount: 340,
      createdBy: 'admin-123',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    )
  ];

  final List<TripModel> _trips = [
    TripModel(
      id: 'trip-1',
      title: 'Spring Excursion to Murree & Patriata',
      description: 'Escape the heat and enjoy the scenic views of Murree hills and Patriata chairlift! Package includes round-trip AC transport, entry tickets, breakfast, lunch, and a guided tour.',
      destination: 'Murree & Patriata',
      departureDate: DateTime.now().add(const Duration(days: 7)),
      returnDate: DateTime.now().add(const Duration(days: 7, hours: 14)),
      price: 2500.0,
      totalSeats: 50,
      bookedSeats: 28,
      registrationDeadline: DateTime.now().add(const Duration(days: 4)),
      imageUrl: 'https://images.unsplash.com/photo-1589136777351-fdc9c9400c73?w=800',
      latitude: 33.9070,
      longitude: 73.3943,
      itinerary: [
        '07:00 AM - Departure from CUI Islamabad',
        '09:30 AM - Arrival in Murree & Breakfast at Mall Road',
        '11:00 AM - Excursion to Patriata (Chairlift & Cable Car)',
        '02:30 PM - Buffet Lunch at Patriata',
        '05:00 PM - Free time for shopping at Murree Mall Road',
        '07:30 PM - Return departure to Islamabad'
      ],
      createdBy: 'admin-123',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    TripModel(
      id: 'trip-2',
      title: 'Industrial Tour to NSTP, NUST',
      description: 'Academic visit to the National Science & Technology Park. Perfect opportunity for AI and Computer Science students to interact with leading startups, tech companies, and research labs.',
      destination: 'NSTP, Islamabad',
      departureDate: DateTime.now().add(const Duration(days: 15)),
      returnDate: DateTime.now().add(const Duration(days: 15, hours: 6)),
      price: 300.0,
      totalSeats: 40,
      bookedSeats: 15,
      registrationDeadline: DateTime.now().add(const Duration(days: 10)),
      imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
      latitude: 33.6425,
      longitude: 72.9904,
      itinerary: [
        '08:30 AM - Departure from CUI Campus',
        '09:15 AM - Arrival at NSTP',
        '09:30 AM - Guided tour of Incubators & Innovation labs',
        '11:30 AM - Interactive seminar with Tech Founders',
        '01:00 PM - Lunch & Networking session',
        '02:00 PM - Return departure to CUI'
      ],
      createdBy: 'admin-123',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    )
  ];

  final List<DonationCampaignModel> _donations = [
    DonationCampaignModel(
      id: 'donation-1',
      title: 'Winter Shawls & Blankets Drive',
      description: 'Help us distribute warm clothing, shawls, and heavy blankets to low-income security staff, gardeners, and underprivileged families living in surrounding communities this winter.',
      category: 'Flood Relief',
      goalAmount: 150000.0,
      raisedAmount: 85200.0,
      imageUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800',
      endDate: DateTime.now().add(const Duration(days: 10)),
      createdBy: 'admin-123',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    DonationCampaignModel(
      id: 'donation-2',
      title: 'Education Scholarship Fund 2026',
      description: 'Empower deserving and bright students at CUI who are struggling to pay their semester tuition fees. 100% of your contributions go directly to clearing academic dues.',
      category: 'Education Fund',
      goalAmount: 500000.0,
      raisedAmount: 320000.0,
      imageUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800',
      endDate: DateTime.now().add(const Duration(days: 25)),
      createdBy: 'admin-123',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    )
  ];

  final List<AnnouncementModel> _announcements = [
    AnnouncementModel(
      id: 'ann-1',
      title: 'Midterm Examinations Schedule Update',
      message: 'Dear Students, please note that the midterm examinations scheduled for Monday have been postponed due to the local government holiday. The updated schedule will be posted shortly. Please keep checking your portals.',
      type: AnnouncementModel.typeUrgent,
      isPinned: true,
      createdBy: 'admin-123',
      createdByName: 'Director Academics',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AnnouncementModel(
      id: 'ann-2',
      title: 'AI Hackathon Registrations are open!',
      message: 'Attention AI enthusiasts! The portal is now accepting submissions for team registrations for the AI Hackathon 2026. Gather your teams of 3-4 members and register before Friday.',
      type: AnnouncementModel.typeEvent,
      isPinned: false,
      createdBy: 'admin-123',
      createdByName: 'Event Committee',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    )
  ];

  // ─── STREAM CONTROLLERS FOR RECURRING UPDATES ──────────────────────────────
  final StreamController<List<EventModel>> _eventsController =
      StreamController<List<EventModel>>.broadcast();
  final StreamController<List<TripModel>> _tripsController =
      StreamController<List<TripModel>>.broadcast();
  final StreamController<List<DonationCampaignModel>> _donationsController =
      StreamController<List<DonationCampaignModel>>.broadcast();
  final StreamController<List<AnnouncementModel>> _announcementsController =
      StreamController<List<AnnouncementModel>>.broadcast();

  // ─── INITIALIZATION ────────────────────────────────────────────────────────
  void initStreams() {
    _eventsController.add(List.unmodifiable(_events));
    _tripsController.add(List.unmodifiable(_trips));
    _donationsController.add(List.unmodifiable(_donations));
    _announcementsController.add(List.unmodifiable(_announcements));
  }

  // ─── AUTHENTICATION METHODS ────────────────────────────────────────────────
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String department,
    required String semester,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Check if user already exists
    if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      throw Exception('email-already-in-use');
    }

    final newUser = UserModel(
      uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      department: department,
      semester: semester,
      role: 'student',
      createdAt: DateTime.now(),
    );

    _users.add(newUser);
    _currentUser = newUser;
    _authStreamController.add(_currentUser);
    return newUser;
  }

  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final user = _users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('user-not-found'),
    );

    // Simple test logic: password must be at least 6 chars (just mock matching)
    if (password.length < 6) {
      throw Exception('wrong-password');
    }

    _currentUser = user;
    _authStreamController.add(_currentUser);
    return _currentUser;
  }

  Future<UserModel?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final googleUser = UserModel(
      uid: 'google-user-101',
      name: 'Google User',
      email: 'googleuser@gmail.com',
      department: 'Software Engineering',
      semester: '4th',
      role: 'student',
      photoUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150',
      createdAt: DateTime.now(),
    );

    if (!_users.any((u) => u.uid == googleUser.uid)) {
      _users.add(googleUser);
    }

    _currentUser = googleUser;
    _authStreamController.add(_currentUser);
    return googleUser;
  }

  Future<UserModel?> getUserData(String uid) async {
    return _users.firstWhere((u) => u.uid == uid, orElse: () => _users.first);
  }

  Future<void> updateUserProfile(UserModel user) async {
    final idx = _users.indexWhere((u) => u.uid == user.uid);
    if (idx != -1) {
      _users[idx] = user;
      if (_currentUser?.uid == user.uid) {
        _currentUser = user;
        _authStreamController.add(_currentUser);
      }
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _authStreamController.add(null);
  }

  // ─── EVENTS METHODS ────────────────────────────────────────────────────────
  Stream<List<EventModel>> getEvents() {
    _eventsController.add(List.unmodifiable(_events));
    return _eventsController.stream;
  }

  Future<String> addEvent(EventModel event) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newEvent = EventModel(
      id: 'event-${DateTime.now().millisecondsSinceEpoch}',
      title: event.title,
      description: event.description,
      venue: event.venue,
      date: event.date,
      time: event.time,
      category: event.category,
      imageUrl: event.imageUrl ?? 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
      latitude: event.latitude,
      longitude: event.longitude,
      maxParticipants: event.maxParticipants,
      registeredCount: event.registeredCount,
      isActive: event.isActive,
      createdBy: _currentUser?.uid ?? 'admin-123',
      createdAt: DateTime.now(),
    );

    _events.add(newEvent);
    _eventsController.add(List.unmodifiable(_events));
    return newEvent.id;
  }

  Future<void> updateEvent(EventModel event) async {
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx != -1) {
      _events[idx] = event;
      _eventsController.add(List.unmodifiable(_events));
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
    _eventsController.add(List.unmodifiable(_events));
  }

  Future<void> registerForEvent(String eventId, String userId) async {
    final eventIdx = _events.indexWhere((e) => e.id == eventId);
    final userIdx = _users.indexWhere((u) => u.uid == userId);

    if (eventIdx != -1 && userIdx != -1) {
      final event = _events[eventIdx];
      final user = _users[userIdx];

      if (!user.registeredEvents.contains(eventId)) {
        final newRegEvents = List<String>.from(user.registeredEvents)..add(eventId);
        _users[userIdx] = user.copyWith(registeredEvents: newRegEvents);
        
        _events[eventIdx] = EventModel(
          id: event.id,
          title: event.title,
          description: event.description,
          venue: event.venue,
          date: event.date,
          time: event.time,
          category: event.category,
          imageUrl: event.imageUrl,
          latitude: event.latitude,
          longitude: event.longitude,
          maxParticipants: event.maxParticipants,
          registeredCount: event.registeredCount + 1,
          isActive: event.isActive,
          createdBy: event.createdBy,
          createdAt: event.createdAt,
        );

        if (_currentUser?.uid == userId) {
          _currentUser = _users[userIdx];
          _authStreamController.add(_currentUser);
        }

        _eventsController.add(List.unmodifiable(_events));
      }
    }
  }

  Future<void> unregisterFromEvent(String eventId, String userId) async {
    final eventIdx = _events.indexWhere((e) => e.id == eventId);
    final userIdx = _users.indexWhere((u) => u.uid == userId);

    if (eventIdx != -1 && userIdx != -1) {
      final event = _events[eventIdx];
      final user = _users[userIdx];

      if (user.registeredEvents.contains(eventId)) {
        final newRegEvents = List<String>.from(user.registeredEvents)..remove(eventId);
        _users[userIdx] = user.copyWith(registeredEvents: newRegEvents);

        _events[eventIdx] = EventModel(
          id: event.id,
          title: event.title,
          description: event.description,
          venue: event.venue,
          date: event.date,
          time: event.time,
          category: event.category,
          imageUrl: event.imageUrl,
          latitude: event.latitude,
          longitude: event.longitude,
          maxParticipants: event.maxParticipants,
          registeredCount: (event.registeredCount - 1).clamp(0, 999999),
          isActive: event.isActive,
          createdBy: event.createdBy,
          createdAt: event.createdAt,
        );

        if (_currentUser?.uid == userId) {
          _currentUser = _users[userIdx];
          _authStreamController.add(_currentUser);
        }

        _eventsController.add(List.unmodifiable(_events));
      }
    }
  }

  // ─── TRIPS METHODS ─────────────────────────────────────────────────────────
  Stream<List<TripModel>> getTrips() {
    _tripsController.add(List.unmodifiable(_trips));
    return _tripsController.stream;
  }

  Future<String> addTrip(TripModel trip) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newTrip = TripModel(
      id: 'trip-${DateTime.now().millisecondsSinceEpoch}',
      title: trip.title,
      description: trip.description,
      destination: trip.destination,
      departureDate: trip.departureDate,
      returnDate: trip.returnDate,
      price: trip.price,
      totalSeats: trip.totalSeats,
      bookedSeats: trip.bookedSeats,
      registrationDeadline: trip.registrationDeadline,
      imageUrl: trip.imageUrl ?? 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800',
      latitude: trip.latitude,
      longitude: trip.longitude,
      itinerary: trip.itinerary,
      isActive: trip.isActive,
      createdBy: _currentUser?.uid ?? 'admin-123',
      createdAt: DateTime.now(),
    );

    _trips.add(newTrip);
    _tripsController.add(List.unmodifiable(_trips));
    return newTrip.id;
  }

  Future<void> updateTrip(TripModel trip) async {
    final idx = _trips.indexWhere((t) => t.id == trip.id);
    if (idx != -1) {
      _trips[idx] = trip;
      _tripsController.add(List.unmodifiable(_trips));
    }
  }

  Future<void> deleteTrip(String tripId) async {
    _trips.removeWhere((t) => t.id == tripId);
    _tripsController.add(List.unmodifiable(_trips));
  }

  Future<void> registerForTrip(String tripId, String userId) async {
    final tripIdx = _trips.indexWhere((t) => t.id == tripId);
    final userIdx = _users.indexWhere((u) => u.uid == userId);

    if (tripIdx != -1 && userIdx != -1) {
      final trip = _trips[tripIdx];
      final user = _users[userIdx];

      if (!user.registeredTrips.contains(tripId)) {
        final newRegTrips = List<String>.from(user.registeredTrips)..add(tripId);
        _users[userIdx] = user.copyWith(registeredTrips: newRegTrips);

        _trips[tripIdx] = TripModel(
          id: trip.id,
          title: trip.title,
          description: trip.description,
          destination: trip.destination,
          departureDate: trip.departureDate,
          returnDate: trip.returnDate,
          price: trip.price,
          totalSeats: trip.totalSeats,
          bookedSeats: trip.bookedSeats + 1,
          registrationDeadline: trip.registrationDeadline,
          imageUrl: trip.imageUrl,
          latitude: trip.latitude,
          longitude: trip.longitude,
          itinerary: trip.itinerary,
          isActive: trip.isActive,
          createdBy: trip.createdBy,
          createdAt: trip.createdAt,
        );

        if (_currentUser?.uid == userId) {
          _currentUser = _users[userIdx];
          _authStreamController.add(_currentUser);
        }

        _tripsController.add(List.unmodifiable(_trips));
      }
    }
  }

  Future<void> unregisterFromTrip(String tripId, String userId) async {
    final tripIdx = _trips.indexWhere((t) => t.id == tripId);
    final userIdx = _users.indexWhere((u) => u.uid == userId);

    if (tripIdx != -1 && userIdx != -1) {
      final trip = _trips[tripIdx];
      final user = _users[userIdx];

      if (user.registeredTrips.contains(tripId)) {
        final newRegTrips = List<String>.from(user.registeredTrips)..remove(tripId);
        _users[userIdx] = user.copyWith(registeredTrips: newRegTrips);

        _trips[tripIdx] = TripModel(
          id: trip.id,
          title: trip.title,
          description: trip.description,
          destination: trip.destination,
          departureDate: trip.departureDate,
          returnDate: trip.returnDate,
          price: trip.price,
          totalSeats: trip.totalSeats,
          bookedSeats: (trip.bookedSeats - 1).clamp(0, 99999),
          registrationDeadline: trip.registrationDeadline,
          imageUrl: trip.imageUrl,
          latitude: trip.latitude,
          longitude: trip.longitude,
          itinerary: trip.itinerary,
          isActive: trip.isActive,
          createdBy: trip.createdBy,
          createdAt: trip.createdAt,
        );

        if (_currentUser?.uid == userId) {
          _currentUser = _users[userIdx];
          _authStreamController.add(_currentUser);
        }

        _tripsController.add(List.unmodifiable(_trips));
      }
    }
  }

  // ─── DONATIONS METHODS ─────────────────────────────────────────────────────
  Stream<List<DonationCampaignModel>> getDonationCampaigns() {
    _donationsController.add(List.unmodifiable(_donations));
    return _donationsController.stream;
  }

  Future<String> addDonationCampaign(DonationCampaignModel campaign) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newCampaign = DonationCampaignModel(
      id: 'donation-${DateTime.now().millisecondsSinceEpoch}',
      title: campaign.title,
      description: campaign.description,
      category: campaign.category,
      goalAmount: campaign.goalAmount,
      raisedAmount: campaign.raisedAmount,
      imageUrl: campaign.imageUrl ?? 'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=800',
      endDate: campaign.endDate,
      isActive: campaign.isActive,
      createdBy: _currentUser?.uid ?? 'admin-123',
      createdAt: DateTime.now(),
    );

    _donations.add(newCampaign);
    _donationsController.add(List.unmodifiable(_donations));
    return newCampaign.id;
  }

  Future<void> makeDonation(DonationRecord record) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _donations.indexWhere((c) => c.id == record.campaignId);
    if (idx != -1) {
      final campaign = _donations[idx];
      _donations[idx] = DonationCampaignModel(
        id: campaign.id,
        title: campaign.title,
        description: campaign.description,
        category: campaign.category,
        goalAmount: campaign.goalAmount,
        raisedAmount: campaign.raisedAmount + record.amount,
        imageUrl: campaign.imageUrl,
        endDate: campaign.endDate,
        isActive: campaign.isActive,
        createdBy: campaign.createdBy,
        createdAt: campaign.createdAt,
      );
      _donationsController.add(List.unmodifiable(_donations));
    }
  }

  // ─── ANNOUNCEMENTS METHODS ─────────────────────────────────────────────────
  Stream<List<AnnouncementModel>> getAnnouncements() {
    _announcementsController.add(List.unmodifiable(_announcements));
    return _announcementsController.stream;
  }

  Future<String> addAnnouncement(AnnouncementModel announcement) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newAnn = AnnouncementModel(
      id: 'ann-${DateTime.now().millisecondsSinceEpoch}',
      title: announcement.title,
      message: announcement.message,
      type: announcement.type,
      imageUrl: announcement.imageUrl,
      isPinned: announcement.isPinned,
      createdBy: _currentUser?.uid ?? 'admin-123',
      createdByName: _currentUser?.name ?? 'Admin',
      createdAt: DateTime.now(),
    );

    _announcements.add(newAnn);
    _announcementsController.add(List.unmodifiable(_announcements));
    return newAnn.id;
  }

  Future<void> deleteAnnouncement(String id) async {
    _announcements.removeWhere((ann) => ann.id == id);
    _announcementsController.add(List.unmodifiable(_announcements));
  }
}
