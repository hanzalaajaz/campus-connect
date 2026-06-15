import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/announcement_tile.dart';
import '../../widgets/loading_widget.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final annProvider = context.watch<AnnouncementProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Announcements',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: Colors.grey.shade100, height: 1),
        ),
      ),
      floatingActionButton: authProvider.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddAnnouncementDialog(context),
              label: const Text('New Announcement'),
              icon: const Icon(Icons.add),
              backgroundColor: AppColors.primary,
            )
          : null,
      body: annProvider.isLoading
          ? const LoadingWidget()
          : annProvider.announcements.isEmpty
              ? const EmptyStateWidget(
                  message: 'No announcements yet.\nCheck back soon!',
                  icon: Icons.campaign_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 96),
                  itemCount: annProvider.announcements.length,
                  itemBuilder: (context, i) {
                    final a = annProvider.announcements[i];
                    return AnnouncementTile(
                      announcement: a,
                      showDelete: authProvider.isAdmin,
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Announcement'),
                            content: const Text(
                                'Are you sure you want to delete this?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await context
                              .read<AnnouncementProvider>()
                              .deleteAnnouncement(a.id);
                        }
                      },
                    );
                  },
                ),
    );
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String selectedType = AnnouncementModel.typeGeneral;
    bool isPinned = false;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Announcement',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: messageCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Message'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Message required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  onChanged: (v) => setState(() => selectedType = v!),
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: [
                    AnnouncementModel.typeGeneral,
                    AnnouncementModel.typeEvent,
                    AnnouncementModel.typeTrip,
                    AnnouncementModel.typeUrgent,
                    AnnouncementModel.typeAcademic,
                  ]
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                      .toList(),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pin to top'),
                  value: isPinned,
                  onChanged: (v) => setState(() => isPinned = v),
                  activeThumbColor: AppColors.primary,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final user =
                          context.read<AuthProvider>().user;
                      final announcement = AnnouncementModel(
                        id: '',
                        title: titleCtrl.text.trim(),
                        message: messageCtrl.text.trim(),
                        type: selectedType,
                        isPinned: isPinned,
                        createdBy: user?.uid ?? '',
                        createdByName: user?.name ?? 'Admin',
                        createdAt: DateTime.now(),
                      );
                      Navigator.pop(ctx);
                      await context
                          .read<AnnouncementProvider>()
                          .addAnnouncement(announcement);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Announcement posted!')),
                        );
                      }
                    },
                    child: const Text('Post Announcement',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
