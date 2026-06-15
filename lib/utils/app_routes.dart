import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/events/event_detail_screen.dart';
import '../screens/trips/trips_screen.dart';
import '../screens/trips/trip_detail_screen.dart';
import '../screens/donations/donations_screen.dart';
import '../screens/announcements/announcements_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/add_event_screen.dart';
import '../screens/admin/add_trip_screen.dart';
import '../screens/admin/add_campaign_screen.dart';
import '../models/event_model.dart';
import '../models/trip_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String events = '/events';
  static const String eventDetail = '/event-detail';
  static const String trips = '/trips';
  static const String tripDetail = '/trip-detail';
  static const String donations = '/donations';
  static const String announcements = '/announcements';
  static const String profile = '/profile';
  static const String adminDashboard = '/admin-dashboard';
  static const String addEvent = '/add-event';
  static const String addTrip = '/add-trip';
  static const String addCampaign = '/add-campaign';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    home: (_) => const HomeScreen(),
    events: (_) => const EventsScreen(),
    trips: (_) => const TripsScreen(),
    donations: (_) => const DonationsScreen(),
    announcements: (_) => const AnnouncementsScreen(),
    profile: (_) => const ProfileScreen(),
    adminDashboard: (_) => const AdminDashboard(),
    addEvent: (_) => const AddEventScreen(),
    addTrip: (_) => const AddTripScreen(),
    addCampaign: (_) => const AddCampaignScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case eventDetail:
        final event = settings.arguments as EventModel;
        return MaterialPageRoute(
          builder: (_) => EventDetailScreen(event: event),
        );
      case tripDetail:
        final trip = settings.arguments as TripModel;
        return MaterialPageRoute(
          builder: (_) => TripDetailScreen(trip: trip),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}
