import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/trip_card.dart';
import '../../widgets/loading_widget.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trips',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: tripProvider.isLoading
          ? const ShimmerList()
          : tripProvider.trips.isEmpty
              ? const EmptyStateWidget(
                  message: 'No trips available yet.\nCheck back soon!',
                  icon: Icons.directions_bus_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tripProvider.trips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final trip = tripProvider.trips[i];
                    final isRegistered =
                        user?.registeredTrips.contains(trip.id) ?? false;
                    return TripCard(
                      trip: trip,
                      isRegistered: isRegistered,
                      onRegister: () async {
                        if (user == null) return;
                        if (isRegistered) {
                          await context
                              .read<TripProvider>()
                              .unregisterFromTrip(trip.id, user.uid);
                        } else {
                          await context
                              .read<TripProvider>()
                              .registerForTrip(trip.id, user.uid);
                        }
                        await context.read<AuthProvider>().refreshUser();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(isRegistered
                                ? 'Booking cancelled'
                                : 'Trip booked successfully!'),
                            backgroundColor: isRegistered
                                ? AppColors.error
                                : AppColors.success,
                          ));
                        }
                      },
                    );
                  },
                ),
    );
  }
}
