import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  Widget _placeholderImage() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: const Center(
        child: Icon(Icons.event, size: 80, color: Colors.white30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isRegistered =
        user?.registeredEvents.contains(event.id) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrl != null
                  ? AppImage(
                      imageUrl: event.imageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholderImage(),
                    )
                  : _placeholderImage(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _infoCard([
                    _infoRow(Icons.calendar_today_outlined,
                        DateFormat('EEEE, MMMM d, y').format(event.date)),
                    _infoRow(Icons.access_time_outlined, event.time),
                    _infoRow(Icons.location_on_outlined, event.venue),
                    if (event.maxParticipants != null)
                      _infoRow(
                        Icons.people_outline,
                        '${event.registeredCount} / ${event.maxParticipants} registered  (${event.spotsLeft} spots left)',
                      ),
                  ]),
                  const SizedBox(height: 20),
                  const Text(
                    'About This Event',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  if (event.hasLocation) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Location',
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
                            initialCenter: LatLng(
                                event.latitude!, event.longitude!),
                            initialZoom: 15,
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
                                      event.latitude!, event.longitude!),
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: AppColors.error,
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
                  if (user != null && !authProvider.isAdmin)
                    CustomButton(
                      text: event.isFull
                          ? 'Event Full'
                          : isRegistered
                              ? 'Cancel Registration'
                              : 'Register for Event',
                      color: isRegistered ? AppColors.error : AppColors.primary,
                      onPressed: event.isFull
                          ? null
                          : () async {
                              final ep = context.read<EventProvider>();
                              if (isRegistered) {
                                await ep.unregisterFromEvent(
                                    event.id, user.uid);
                              } else {
                                await ep.registerForEvent(
                                    event.id, user.uid);
                              }
                              await context
                                  .read<AuthProvider>()
                                  .refreshUser();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(isRegistered
                                      ? 'Registration cancelled'
                                      : 'Successfully registered!'),
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
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
