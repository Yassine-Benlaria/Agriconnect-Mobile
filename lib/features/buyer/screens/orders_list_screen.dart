import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/enums.dart';
import '../../../core/models/order.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../providers/orders_provider.dart';

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(buyerOrdersProvider);

    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text('My Orders',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              Expanded(
                child: ordersAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentGreen)),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (orders) => orders.isEmpty
                      ? Center(
                          child: Text('No orders yet',
                              style: Theme.of(context).textTheme.bodyLarge))
                      : RefreshIndicator(
                          color: AppColors.accentGreen,
                          onRefresh: () =>
                              ref.read(buyerOrdersProvider.notifier).load(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: orders.length,
                            itemBuilder: (ctx, i) =>
                                _OrderCard(order: orders[i]),
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

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  Color _statusColor() {
    switch (order.status) {
      case OrderStatus.PENDING:
        return AppColors.statusPending;
      case OrderStatus.REJECTED:
        return AppColors.statusRejected;
      case OrderStatus.COMPLETED:
        return AppColors.statusCompleted;
      default:
        return AppColors.statusInProgress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return GestureDetector(
      onTap: () => context.go('/buyer/orders/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8).toUpperCase()}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Colors.white),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.items.length} item(s) · ${order.grandTotal.toStringAsFixed(0)} DZD',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              order.deliveryOption.label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.accentGreen),
            ),
          ],
        ),
      ),
    );
  }
}
