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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: announcement.isPinned
            ? Border.all(color: AppColors.accent.withOpacity(0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _typeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_typeIcon, color: _typeColor, size: 22),
        ),
        title: Row(
          children: [
            if (announcement.isPinned) ...[
              const Icon(Icons.push_pin, size: 14, color: AppColors.accent),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                announcement.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              announcement.message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              '${announcement.createdByName} • ${DateFormat('MMM d, h:mm a').format(announcement.createdAt)}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
        trailing: showDelete
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
