import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final bool isRegistered;
  final VoidCallback? onRegister;

  const TripCard({
    super.key,
    required this.trip,
    this.isRegistered = false,
    this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final canRegister = !trip.isFull && !trip.isDeadlinePassed && !isRegistered;

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.tripDetail, arguments: trip),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.location_on_outlined, trip.destination),
                  const SizedBox(height: 4),
                  _infoRow(
                    Icons.calendar_today_outlined,
                    '${DateFormat('MMM d').format(trip.departureDate)} — ${DateFormat('MMM d, yyyy').format(trip.returnDate)}',
                  ),
                  const SizedBox(height: 4),
                  _infoRow(
                    Icons.event_busy_outlined,
                    'Deadline: ${DateFormat('MMM d').format(trip.registrationDeadline)}',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PKR ${trip.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${trip.availableSeats} seats left',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: canRegister ? onRegister : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRegistered
                              ? Colors.grey.shade200
                              : trip.isFull || trip.isDeadlinePassed
                                  ? Colors.grey.shade200
                                  : AppColors.accent,
                          foregroundColor: isRegistered
                              ? AppColors.textSecondary
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        child: Text(
                          trip.isFull
                              ? 'Full'
                              : trip.isDeadlinePassed
                                  ? 'Closed'
                                  : isRegistered
                                      ? 'Booked ✓'
                                      : 'Book Now',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: trip.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: trip.imageUrl!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(height: 160, color: Colors.grey.shade200),
              errorWidget: (_, __, ___) => _placeholderImage(),
            )
          : _placeholderImage(),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 160,
      color: AppColors.accent.withOpacity(0.08),
      child: Center(
        child: Icon(Icons.directions_bus_outlined,
            size: 52, color: AppColors.accent.withOpacity(0.4)),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
