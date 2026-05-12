import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/enums.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../core/widgets/glass_button.dart';
import '../providers/deliveries_provider.dart';

class CurrentTaskScreen extends ConsumerWidget {
  const CurrentTaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(currentDeliveryProvider);

    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: taskAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppColors.accentGreen)),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (order) {
              if (order == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.navigation_outlined,
                          size: 80, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text('No active task',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        'Browse available tasks and assign yourself',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.accentGreen,
                onRefresh: () =>
                    ref.refresh(currentDeliveryProvider.future),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text('Active Task',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.statusInProgress.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.statusInProgress
                                .withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.radio_button_checked_rounded,
                              color: AppColors.statusInProgress, size: 16),
                          const SizedBox(width: 8),
                          Text(order.status.label,
                              style: const TextStyle(
                                  color: AppColors.statusInProgress,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Routing info
                    Text('Route',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    _RouteSection(order: order),
                    const SizedBox(height: 20),

                    // Contact buttons
                    Text('Contact',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    if (order.farmerPhone != null)
                      _CallButton(
                        label: 'Call Farmer (${order.farmerName ?? ""})',
                        phone: order.farmerPhone!,
                        icon: Icons.agriculture_rounded,
                      ),
                    if (order.buyerPhone != null)
                      _CallButton(
                        label: 'Call Buyer (${order.buyerName ?? ""})',
                        phone: order.buyerPhone!,
                        icon: Icons.person_rounded,
                      ),
                    const SizedBox(height: 20),

                    // Action buttons
                    _buildActions(context, ref, order),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, dynamic order) {
    if (order.status == OrderStatus.AWAITING_DELIVERER_PICKUP &&
        !order.delivererConfirmedPickup) {
      return PrimaryButton(
        label: 'Confirm Pickup from Farmer',
        icon: Icons.check_circle_rounded,
        onPressed: () async {
          try {
            await ref
                .read(deliveryActionsProvider.notifier)
                .confirmPickup(order.id);
            ref.refresh(currentDeliveryProvider);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pickup confirmed!')));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppColors.error));
          }
        },
      );
    }
    if (order.status == OrderStatus.IN_TRANSIT &&
        !order.delivererConfirmedDelivery) {
      return PrimaryButton(
        label: 'Confirm Delivery to Buyer',
        icon: Icons.check_circle_rounded,
        onPressed: () async {
          try {
            await ref
                .read(deliveryActionsProvider.notifier)
                .confirmDelivery(order.id);
            ref.refresh(currentDeliveryProvider);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delivery confirmed! Task complete.')));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppColors.error));
          }
        },
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glassCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Waiting for the other party to confirm their step.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteSection extends StatelessWidget {
  final dynamic order;
  const _RouteSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.circle,
                      color: AppColors.primaryGreenLight, size: 12),
                  Container(
                      width: 2, height: 40, color: AppColors.glassBorder),
                  const Icon(Icons.location_on_rounded,
                      color: AppColors.statusPending, size: 14),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PICKUP FROM',
                        style: Theme.of(context).textTheme.labelSmall),
                    Text(order.farmerName ?? 'Farmer',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white)),
                    const SizedBox(height: 20),
                    Text('DELIVER TO',
                        style: Theme.of(context).textTheme.labelSmall),
                    Text(order.buyerName ?? 'Buyer',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          if (order.distanceKm != null) ...[
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.straighten_rounded,
                    color: AppColors.textMuted, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${order.distanceKm.toStringAsFixed(1)} km total',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final String label;
  final String phone;
  final IconData icon;

  const _CallButton({
    required this.label,
    required this.phone,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassButton(
        label: label,
        icon: icon,
        accentColor: AppColors.accentGreen,
        onPressed: () async {
          final uri = Uri.parse('tel:$phone');
          if (await canLaunchUrl(uri)) launchUrl(uri);
        },
      ),
    );
  }
}
