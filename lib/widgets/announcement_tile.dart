import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/announcement_model.dart';
import '../utils/app_colors.dart';

class AnnouncementTile extends StatelessWidget {
  final AnnouncementModel announcement;
  final bool showDelete;
  final VoidCallback? onDelete;

  const AnnouncementTile({
    super.key,
    required this.announcement,
    this.showDelete = false,
    this.onDelete,
  });

  Color get _typeColor {
    switch (announcement.type) {
      case AnnouncementModel.typeUrgent:
        return AppColors.error;
      case AnnouncementModel.typeEvent:
        return AppColors.primary;
      case AnnouncementModel.typeTrip:
        return AppColors.accent;
      case AnnouncementModel.typeAcademic:
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _typeIcon {
    switch (announcement.type) {
      case AnnouncementModel.typeUrgent:
        return Icons.warning_amber_rounded;
      case AnnouncementModel.typeEvent:
        return Icons.event;
      case AnnouncementModel.typeTrip:
        return Icons.directions_bus;
      case AnnouncementModel.typeAcademic:
        return Icons.school;
      default:
        return Icons.campaign_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: announcement.isPinned
            ? Border.all(color: AppColors.accent.withOpacity(0.5), width: 1.5)
            : Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_typeIcon, color: _typeColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            announcement.createdByName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildBadge(),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(announcement.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                if (announcement.isPinned)
                  const Tooltip(
                    message: 'Pinned',
                    child: Icon(Icons.push_pin, size: 16, color: AppColors.accent),
                  ),
                if (showDelete) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              announcement.message,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        announcement.type.toUpperCase(),
        style: TextStyle(
          color: _typeColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
