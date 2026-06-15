import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class TripDetailScreen extends StatelessWidget {
  final TripModel trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isRegistered =
        user?.registeredTrips.contains(trip.id) ?? false;
    final canRegister =
        !trip.isFull && !trip.isDeadlinePassed && !isRegistered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: trip.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: trip.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: const BoxDecoration(
                          gradient: AppColors.accentGradient),
                      child: const Center(
                        child: Icon(Icons.directions_bus,
                            size: 80, color: Colors.white30),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _infoCard([
                    _infoRow(Icons.location_on_outlined, trip.destination),
                    _infoRow(
                      Icons.flight_takeoff,
                      'Departure: ${DateFormat('EEE, MMM d, y').format(trip.departureDate)}',
                    ),
                    _infoRow(
                      Icons.flight_land,
                      'Return: ${DateFormat('EEE, MMM d, y').format(trip.returnDate)}',
                    ),
                    _infoRow(
                      Icons.event_busy,
                      'Deadline: ${DateFormat('MMM d, y').format(trip.registrationDeadline)}',
                    ),
                    _infoRow(
                      Icons.people_outline,
                      '${trip.bookedSeats}/${trip.totalSeats} seats booked (${trip.availableSeats} left)',
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.payments_outlined, color: Colors.white),
                        const SizedBox(width: 10),
                        const Text(
                          'Trip Cost',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          'PKR ${trip.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'About This Trip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trip.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  if (trip.itinerary.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Itinerary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...trip.itinerary.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                  if (trip.hasLocation) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Destination Map',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter:
                                LatLng(trip.latitude!, trip.longitude!),
                            initialZoom: 10,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                      trip.latitude!, trip.longitude!),
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: AppColors.accent,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  if (user != null && !user.isAdmin)
                    CustomButton(
                      text: trip.isFull
                          ? 'Trip Full'
                          : trip.isDeadlinePassed
                              ? 'Registration Closed'
                              : isRegistered
                                  ? 'Cancel Booking'
                                  : 'Book My Seat',
                      color: isRegistered ? AppColors.error : AppColors.accent,
                      onPressed: trip.isFull || trip.isDeadlinePassed
                          ? null
                          : () async {
                              final tp = context.read<TripProvider>();
                              if (isRegistered) {
                                await tp.unregisterFromTrip(trip.id, user.uid);
                              } else {
                                await tp.registerForTrip(trip.id, user.uid);
                              }
                              await context.read<AuthProvider>().refreshUser();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(isRegistered
                                      ? 'Booking cancelled'
                                      : 'Seat booked successfully!'),
                                  backgroundColor: isRegistered
                                      ? AppColors.error
                                      : AppColors.success,
                                ));
                              }
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

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children
            .map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: w,
                ))
            .toList(),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
