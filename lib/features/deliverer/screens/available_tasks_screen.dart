import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order.dart';
import '../../../core/widgets/farm_background.dart';
import '../providers/deliveries_provider.dart';

class AvailableTasksScreen extends ConsumerWidget {
  const AvailableTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesAsync = ref.watch(availableDeliveriesProvider);

    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Available Tasks',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.refresh(availableDeliveriesProvider),
                      icon: const Icon(Icons.refresh_rounded,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: deliveriesAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentGreen)),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (orders) => orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_shipping_outlined,
                                  size: 80,
                                  color: AppColors.textMuted),
                              const SizedBox(height: 16),
                              Text('No available tasks',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              const SizedBox(height: 8),
                              Text(
                                  'Check back later for delivery tasks in your area',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.accentGreen,
                          onRefresh: () => ref.refresh(
                              availableDeliveriesProvider.future),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            itemCount: orders.length,
                            itemBuilder: (ctx, i) =>
                                _TaskCard(order: orders[i]),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Order order;
  const _TaskCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/deliverer/tasks/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.primaryGreenLight.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'TASK #${order.id.substring(0, 6).toUpperCase()}',
                    style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 11),
                  ),
                ),
                const Spacer(),
                if (order.deliveryPrice != null)
                  Text(
                    '${order.deliveryPrice!.toStringAsFixed(0)} DZD',
                    style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Route info
            Row(
              children: [
                const Icon(Icons.circle,
                    color: AppColors.primaryGreenLight, size: 12),
                const SizedBox(width: 8),
                Text('From: Farmer Location',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                  width: 2, height: 16, color: AppColors.glassBorder),
            ),
            Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: AppColors.statusPending, size: 14),
                const SizedBox(width: 8),
                Text('To: Buyer Location',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            if (order.distanceKm != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.straighten_rounded,
                      color: AppColors.textMuted, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${order.distanceKm!.toStringAsFixed(1)} km',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.inventory_2_outlined,
                      color: AppColors.textMuted, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${order.items.length} item(s)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreenLight.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primaryGreenLight.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                        color: AppColors.primaryGreenLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.primaryGreenLight, size: 13),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
