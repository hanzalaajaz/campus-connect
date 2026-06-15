import '../firebase_options.dart';

class AppConstants {
  static bool _isDemoMode = DefaultFirebaseOptions.android.apiKey == 'YOUR-ANDROID-API-KEY';
  static bool get isDemoMode => _isDemoMode;
  static set isDemoMode(bool value) => _isDemoMode = value;

  static const String appName = 'CampusConnect';
  static const String universityName = 'COMSATS University Islamabad';
  static const String department = 'Department of Artificial Intelligence';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String tripsCollection = 'trips';
  static const String donationsCollection = 'donations';
  static const String announcementsCollection = 'announcements';
  static const String registrationsCollection = 'registrations';

  // SharedPreferences Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyFcmToken = 'fcm_token';

  // User Roles
  static const String roleStudent = 'student';
  static const String roleAdmin = 'admin';

  // Departments
  static const List<String> departments = [
    'Artificial Intelligence',
    'Computer Science',
    'Software Engineering',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Business Administration',
    'Mathematics',
  ];

  // Semesters
  static const List<String> semesters = [
    '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th',
  ];

  // Event Categories
  static const List<String> eventCategories = [
    'Sports',
    'Academic',
    'Cultural',
    'Social',
    'Health',
    'Technology',
    'Other',
  ];

  // Donation Campaigns
  static const List<String> donationCategories = [
    'Flood Relief',
    'Orphan Support',
    'Education Fund',
    'Ramadan Drive',
    'Health Camp',
    'Other',
  ];

  // Pagination
  static const int pageSize = 20;

  // Image Sizes
  static const int maxImageSizeKB = 2048;

  // Map defaults (COMSATS Islamabad)
  static const double defaultLat = 33.6844;
  static const double defaultLng = 73.0479;
  static const double defaultZoom = 15.0;
}
