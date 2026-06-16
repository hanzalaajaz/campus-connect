import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../widgets/event_card.dart';
import '../../widgets/announcement_tile.dart';
import '../events/events_screen.dart';
import '../trips/trips_screen.dart';
import '../donations/donations_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _HomeTab(),
    EventsScreen(),
    TripsScreen(),
    DonationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().listenToEvents();
      context.read<TripProvider>().listenToTrips();
      context.read<DonationProvider>().listenToCampaigns();
      context.read<AnnouncementProvider>().listenToAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event_rounded, color: AppColors.primary),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bus_outlined),
            selectedIcon:
                Icon(Icons.directions_bus_rounded, color: AppColors.primary),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon:
                Icon(Icons.volunteer_activism, color: AppColors.primary),
            label: 'Donate',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon:
                Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              if (authProvider.isAdmin)
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings,
                      color: Colors.white),
                  onPressed: () => Navigator.pushNamed(
                      context, AppRoutes.adminDashboard),
                ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () => Navigator.pushNamed(
                    context, AppRoutes.announcements),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<AuthProvider>().signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                    }
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Hello, ${user?.name.split(' ').first ?? 'Student'}! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.department ?? 'COMSATS University Islamabad',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  const Text(
                    'Upcoming Events',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (eventProvider.upcomingEvents.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No upcoming events',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ),
                    )
                  else
                    ...eventProvider.upcomingEvents.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EventCard(
                          event: e,
                          isRegistered: user?.registeredEvents
                                  .contains(e.id) ??
                              false,
                          onRegister: () async {
                            if (user == null) return;
                            final ep = context.read<EventProvider>();
                            final isReg = user.registeredEvents.contains(e.id);
                            bool success;
                            if (isReg) {
                              success = await ep.unregisterFromEvent(e.id, user.uid);
                            } else {
                              success = await ep.registerForEvent(e.id, user.uid);
                            }
                            await context.read<AuthProvider>().refreshUser();
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success 
                                    ? (isReg ? 'Successfully unregistered!' : 'Successfully registered for event!')
                                    : 'Failed to update registration.'),
                                  backgroundColor: success ? AppColors.success : AppColors.error,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Announcements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.announcements),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Consumer<AnnouncementProvider>(
                    builder: (context, annProvider, __) {
                      final announcements = annProvider.recentAnnouncements;
                      if (announcements.isEmpty) {
                        return Text('No announcements yet',
                            style:
                                TextStyle(color: Colors.grey.shade400));
                      }
                      return Column(
                        children: announcements
                            .map((a) => AnnouncementTile(announcement: a))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _quickAction(
              context,
              icon: Icons.event_rounded,
              label: 'Events',
              color: AppColors.primary,
              onTap: () => Navigator.pushNamed(context, AppRoutes.events),
            ),
            const SizedBox(width: 12),
            _quickAction(
              context,
              icon: Icons.directions_bus_rounded,
              label: 'Trips',
              color: AppColors.accent,
              onTap: () => Navigator.pushNamed(context, AppRoutes.trips),
            ),
            const SizedBox(width: 12),
            _quickAction(
              context,
              icon: Icons.volunteer_activism,
              label: 'Donate',
              color: AppColors.success,
              onTap: () => Navigator.pushNamed(context, AppRoutes.donations),
            ),
            const SizedBox(width: 12),
            _quickAction(
              context,
              icon: Icons.campaign_rounded,
              label: 'News',
              color: Colors.purple,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.announcements),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
