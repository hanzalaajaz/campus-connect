import 'package:flutter/material.dart';
import 'app_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool isRegistered;
  final VoidCallback? onRegister;

  const EventCard({
    super.key,
    required this.event,
    this.isRegistered = false,
    this.onRegister,
  });

  Color get _categoryColor {
    switch (event.category) {
      case 'Sports':
        return Colors.green;
      case 'Academic':
        return AppColors.primary;
      case 'Cultural':
        return Colors.purple;
      case 'Health':
        return Colors.red;
      case 'Technology':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _categoryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.category,
                          style: TextStyle(
                            color: _categoryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (event.isFull)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'FULL',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.calendar_today_outlined,
                      DateFormat('EEE, MMM d • h:mm a').format(event.date)),
                  const SizedBox(height: 4),
                  _infoRow(Icons.location_on_outlined, event.venue),
                  if (event.maxParticipants != null) ...[
                    const SizedBox(height: 4),
                    _infoRow(
                      Icons.people_outline,
                      '${event.registeredCount}/${event.maxParticipants} registered',
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (context.watch<AuthProvider>().user?.isAdmin != true)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: event.isFull ? null : onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRegistered
                              ? Colors.grey.shade200
                              : AppColors.primary,
                          foregroundColor:
                              isRegistered ? AppColors.textSecondary : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          event.isFull
                              ? 'Event Full'
                              : isRegistered
                                  ? 'Registered ✓'
                                  : 'Register Now',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
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
      child: event.imageUrl != null
          ? AppImage(
              imageUrl: event.imageUrl!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 150,
                color: Colors.grey.shade200,
              ),
              errorWidget: (_, __, ___) => _placeholderImage(),
            )
          : _placeholderImage(),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 150,
      color: AppColors.primary.withOpacity(0.08),
      child: Center(
        child: Icon(Icons.event, size: 48, color: AppColors.primary.withOpacity(0.4)),
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
