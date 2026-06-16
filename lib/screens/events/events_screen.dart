import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';
import '../../widgets/event_card.dart';
import '../../widgets/loading_widget.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Events',
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
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.addEvent),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          _SearchAndFilter(),
          Expanded(child: _EventList()),
        ],
      ),
    );
  }
}

class _SearchAndFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          TextField(
            onChanged: eventProvider.setSearch,
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', ...AppConstants.eventCategories]
                  .map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat, style: const TextStyle(fontSize: 12)),
                          selected: eventProvider.selectedCategory == cat,
                          onSelected: (_) => eventProvider.setCategory(cat),
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: eventProvider.selectedCategory == cat
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight:
                                eventProvider.selectedCategory == cat
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                          backgroundColor: AppColors.background,
                          side: BorderSide.none,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (eventProvider.isLoading) return const ShimmerList();

    final events = eventProvider.events;
    if (events.isEmpty) {
      return EmptyStateWidget(
        message: 'No events found.\nCheck back soon!',
        icon: Icons.event_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final event = events[i];
        final isRegistered =
            user?.registeredEvents.contains(event.id) ?? false;
        return EventCard(
          event: event,
          isRegistered: isRegistered,
          onRegister: () async {
            if (user == null) return;
            bool success;
            if (isRegistered) {
              success = await context
                  .read<EventProvider>()
                  .unregisterFromEvent(event.id, user.uid);
            } else {
              success = await context
                  .read<EventProvider>()
                  .registerForEvent(event.id, user.uid);
            }
            await context.read<AuthProvider>().refreshUser();
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success 
                    ? (isRegistered ? 'Successfully unregistered!' : 'Successfully registered for event!')
                    : 'Failed to update registration.'),
                  backgroundColor: success ? AppColors.success : AppColors.error,
                ),
              );
            }
          },
        );
      },
    );
  }
}
