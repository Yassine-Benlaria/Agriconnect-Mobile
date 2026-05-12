import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/enums.dart';
import '../../../core/models/order.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../core/widgets/glass_button.dart';
import '../providers/orders_provider.dart';
import '../../../router/app_router.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: orderAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accentGreen)),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (order) => CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text('Order #${order.id.substring(0, 8).toUpperCase()}'),
                  leading: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                  ),
                  floating: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status timeline
                        _OrderTimeline(order: order),
                        const SizedBox(height: 24),

                        // Order items
                        Text('Items', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        ...order.items.map((item) => _ItemRow(item: item)),
                        const SizedBox(height: 16),

                        // Pricing
                        _PriceRow(
                            label: 'Products Total',
                            value: order.totalPrice),
                        if (order.deliveryPrice != null)
                          _PriceRow(
                              label: 'Delivery Fee',
                              value: order.deliveryPrice!),
                        if (order.distanceKm != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Distance: ${order.distanceKm!.toStringAsFixed(1)} km',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        const Divider(height: 24),
                        _PriceRow(
                            label: 'Grand Total',
                            value: order.grandTotal,
                            highlight: true),

                        // Rejection reason
                        if (order.status == OrderStatus.REJECTED &&
                            order.rejectionReason != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Rejection Reason',
                                    style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(order.rejectionReason!,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],

                        // Contact buttons
                        if (order.farmerPhone != null) ...[
                          const SizedBox(height: 24),
                          Text('Contact', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          _ContactButton(
                            label: 'Call Farmer (${order.farmerName ?? ""})',
                            phone: order.farmerPhone!,
                            icon: Icons.phone_rounded,
                          ),
                        ],
                        if (order.delivererPhone != null)
                          _ContactButton(
                            label: 'Call Deliverer (${order.delivererName ?? ""})',
                            phone: order.delivererPhone!,
                            icon: Icons.delivery_dining_rounded,
                          ),

                        // Action buttons
                        const SizedBox(height: 24),
                        _buildActions(context, ref, order),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, Order order) {
    final buttons = <Widget>[];

    // Confirm pickup (without delivery)
    if (order.status == OrderStatus.AWAITING_BUYER_PICKUP &&
        !order.buyerConfirmedPickup) {
      buttons.add(
        PrimaryButton(
          label: 'Confirm I Picked Up',
          icon: Icons.check_circle_rounded,
          onPressed: () async {
            await ref
                .read(buyerOrdersProvider.notifier)
                .confirmPickup(order.id);
            ref.refresh(orderDetailProvider(order.id));
          },
        ),
      );
    }

    // Confirm delivery (with delivery)
    if (order.status == OrderStatus.IN_TRANSIT &&
        !order.buyerConfirmedDelivery) {
      buttons.add(
        PrimaryButton(
          label: 'Confirm Delivery Received',
          icon: Icons.check_circle_rounded,
          onPressed: () async {
            await ref
                .read(buyerOrdersProvider.notifier)
                .confirmDelivery(order.id);
            ref.refresh(orderDetailProvider(order.id));
          },
        ),
      );
    }

    // Review button for completed orders
    if (order.status == OrderStatus.COMPLETED) {
      buttons.add(
        GlassButton(
          label: 'Rate the Farmer',
          icon: Icons.star_rounded,
          accentColor: const Color(0xFFFFC107),
          onPressed: () =>
              context.go('/buyer/orders/${order.id}/review'),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          buttons[i],
          if (i < buttons.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final Order order;
  const _OrderTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final isDelivery =
        order.deliveryOption == DeliveryOption.WITH_DELIVERY;
    final steps = isDelivery
        ? [
            (OrderStatus.PENDING, 'Pending'),
            (OrderStatus.AWAITING_DELIVERER_ASSIGN, 'Accepted'),
            (OrderStatus.AWAITING_DELIVERER_PICKUP, 'Deliverer Assigned'),
            (OrderStatus.IN_TRANSIT, 'In Transit'),
            (OrderStatus.COMPLETED, 'Completed'),
          ]
        : [
            (OrderStatus.PENDING, 'Pending'),
            (OrderStatus.AWAITING_BUYER_PICKUP, 'Ready for Pickup'),
            (OrderStatus.COMPLETED, 'Completed'),
          ];

    final currentIdx = steps.indexWhere((s) => s.$1 == order.status);
    final isRejected = order.status == OrderStatus.REJECTED;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: isRejected
          ? Row(
              children: [
                const Icon(Icons.cancel_rounded,
                    color: AppColors.error, size: 32),
                const SizedBox(width: 12),
                Text('Order Rejected',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.error)),
              ],
            )
          : Column(
              children: [
                for (int i = 0; i < steps.length; i++) ...[
                  Row(
                    children: [
                      _TimelineDot(
                        done: i <= currentIdx,
                        active: i == currentIdx,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        steps[i].$2,
                        style: TextStyle(
                          color: i <= currentIdx
                              ? Colors.white
                              : AppColors.textMuted,
                          fontWeight: i == currentIdx
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  if (i < steps.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 11),
                      child: Container(
                        width: 2,
                        height: 24,
                        color: i < currentIdx
                            ? AppColors.accentGreen
                            : AppColors.glassBorder,
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final bool done;
  final bool active;
  const _TimelineDot({required this.done, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.accentGreen : AppColors.glassBorder,
        border: active
            ? Border.all(color: AppColors.primaryGreenLight, width: 3)
            : null,
      ),
      child: done
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
          : null,
    );
  }
}

class _ItemRow extends StatelessWidget {
  final dynamic item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.product?.title ?? 'Product',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            '×${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 12),
          Text(
            '${item.subtotal.toStringAsFixed(0)} DZD',
            style: const TextStyle(
                color: AppColors.accentGreen, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool highlight;
  const _PriceRow(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: highlight
                  ? Theme.of(context).textTheme.titleLarge
                  : Theme.of(context).textTheme.bodyMedium),
          Text(
            '${value.toStringAsFixed(0)} DZD',
            style: TextStyle(
              color: highlight ? AppColors.accentGreen : Colors.white,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              fontSize: highlight ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final String label;
  final String phone;
  final IconData icon;
  const _ContactButton(
      {required this.label, required this.phone, required this.icon});

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
