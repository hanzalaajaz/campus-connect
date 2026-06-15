import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../widgets/donation_card.dart';
import '../../widgets/loading_widget.dart';

class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donationProvider = context.watch<DonationProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: authProvider.isAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.addCampaign),
              backgroundColor: AppColors.success,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      appBar: AppBar(
        title: const Text('Donation Drives',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: donationProvider.isLoading
          ? const ShimmerList()
          : donationProvider.campaigns.isEmpty
              ? const EmptyStateWidget(
                  message: 'No active donation campaigns.\nCheck back soon!',
                  icon: Icons.volunteer_activism_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
                  itemCount: donationProvider.campaigns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final campaign = donationProvider.campaigns[i];
                    return DonationCard(
                      campaign: campaign,
                      onDonate: () => _showDonateDialog(
                          context, campaign.id, user?.uid ?? '',
                          user?.name ?? ''),
                    );
                  },
                ),
    );
  }

  void _showDonateDialog(
      BuildContext context, String campaignId, String userId, String userName) {
    final ctrl = TextEditingController();
    final msgCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
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
                'Make a Donation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your contribution makes a difference!',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              const Text('Amount (PKR)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter an amount';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  return null;
                },
                decoration: InputDecoration(
                  prefixText: 'PKR ',
                  hintText: '500',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [500, 1000, 2000, 5000].map((amount) {
                  return ActionChip(
                    label: Text('PKR $amount'),
                    onPressed: () => ctrl.text = amount.toString(),
                    backgroundColor: AppColors.success.withOpacity(0.1),
                    labelStyle:
                        const TextStyle(color: AppColors.success),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Text('Message (optional)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: msgCtrl,
                decoration: InputDecoration(
                  hintText: 'Leave a kind message...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.volunteer_activism),
                  label: const Text('Donate Now',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(ctx);
                    final success = await context
                        .read<DonationProvider>()
                        .makeDonation(
                          campaignId: campaignId,
                          userId: userId,
                          userName: userName,
                          amount: double.parse(ctrl.text),
                          message: msgCtrl.text.isEmpty
                              ? null
                              : msgCtrl.text,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(success
                            ? 'Thank you for your donation!'
                            : 'Donation failed. Please try again.'),
                        backgroundColor:
                            success ? AppColors.success : AppColors.error,
                      ));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
