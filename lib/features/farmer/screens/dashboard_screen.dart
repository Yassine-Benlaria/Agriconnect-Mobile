import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../core/enums/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/my_products_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final productsAsync = ref.watch(myProductsProvider);
    final ordersAsync = ref.watch(farmerOrdersProvider);

    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            user?.fullname.split(' ').first ?? 'Farmer',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.4),
                      child: Text(
                        user?.fullname.isNotEmpty == true
                            ? user!.fullname[0].toUpperCase()
                            : 'F',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.inventory_2_rounded,
                        label: 'Products',
                        value: productsAsync.maybeWhen(
                          data: (p) => '${p.total}',
                          orElse: () => '–',
                        ),
                        color: AppColors.primaryGreenLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.receipt_long_rounded,
                        label: 'Pending Orders',
                        value: ordersAsync.maybeWhen(
                          data: (orders) => '${orders.where((o) => o.status == OrderStatus.PENDING).length}',
                          orElse: () => '–',
                        ),
                        color: AppColors.statusPending,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star_rounded,
                        label: 'Rating',
                        value: user?.rating != null
                            ? user!.rating.toStringAsFixed(1)
                            : '–',
                        color: const Color(0xFFFFC107),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle_rounded,
                        label: 'Completed',
                        value: ordersAsync.maybeWhen(
                          data: (orders) => '${orders.where((o) => o.status == OrderStatus.COMPLETED).length}',
                          orElse: () => '–',
                        ),
                        color: AppColors.statusCompleted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                Text('Recent Activity',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),

                // Recent orders list
                ordersAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentGreen)),
                  error: (_, __) =>
                      const Text('Could not load orders'),
                  data: (orders) {
                    final recent = orders.take(3).toList();
                    if (recent.isEmpty) {
                      return Text('No orders yet',
                          style: Theme.of(context).textTheme.bodyMedium);
                    }
                    return Column(
                      children: recent
                          .map((o) => _RecentOrderTile(order: o))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final dynamic order;
  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.glassCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_rounded,
              color: AppColors.accentGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Order #${order.id.substring(0, 8).toUpperCase()}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.statusPending.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.status.label,
              style: const TextStyle(
                  color: AppColors.statusPending,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
