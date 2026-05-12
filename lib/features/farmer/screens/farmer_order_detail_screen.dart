import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/enums.dart';
import '../../../core/models/order.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../core/widgets/glass_button.dart';
import '../providers/my_products_provider.dart';
import '../../buyer/providers/orders_provider.dart';

class FarmerOrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  final bool listMode;
  const FarmerOrderDetailScreen({
    super.key,
    required this.orderId,
    this.listMode = false,
  });

  @override
  ConsumerState<FarmerOrderDetailScreen> createState() =>
      _FarmerOrderDetailScreenState();
}

class _FarmerOrderDetailScreenState
    extends ConsumerState<FarmerOrderDetailScreen> {
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  bool _isActing = false;
  final _rejectCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.listMode) {
      _loadOrders();
    } else {
      _loadOrder();
    }
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await ref.read(apiServiceProvider).getOrders();
      setState(() => _orders = orders.cast<Order>());
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    try {
      final order =
          await ref.read(apiServiceProvider).getOrder(widget.orderId);
      setState(() => _selectedOrder = order);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _accept(String orderId) async {
    setState(() => _isActing = true);
    try {
      await ref.read(apiServiceProvider).acceptOrder(orderId);
      _loadOrder();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order accepted!')));
    } catch (_) {} finally {
      setState(() => _isActing = false);
    }
  }

  Future<void> _reject(String orderId) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reject Order',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _rejectCtrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter rejection reason...',
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_rejectCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, _rejectCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;
    setState(() => _isActing = true);
    try {
      await ref.read(apiServiceProvider).rejectOrder(orderId, reason);
      _loadOrder();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order rejected')));
    } catch (_) {} finally {
      setState(() => _isActing = false);
    }
  }

  Future<void> _confirmPickup(String orderId) async {
    setState(() => _isActing = true);
    try {
      await ref.read(apiServiceProvider).farmerConfirmPickup(orderId);
      _loadOrder();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pickup confirmed!')));
    } catch (_) {} finally {
      setState(() => _isActing = false);
    }
  }

  @override
  void dispose() {
    _rejectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listMode) {
      return Scaffold(
        body: FarmBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Text('Incoming Orders',
                      style: Theme.of(context).textTheme.headlineMedium),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accentGreen))
                      : _orders.isEmpty
                          ? Center(
                              child: Text('No orders yet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge))
                          : RefreshIndicator(
                              color: AppColors.accentGreen,
                              onRefresh: _loadOrders,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                itemCount: _orders.length,
                                itemBuilder: (ctx, i) =>
                                    _OrderListTile(_orders[i]),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.accentGreen))
              : _selectedOrder == null
                  ? const Center(child: Text('Order not found'))
                  : _buildDetail(context, _selectedOrder!),
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, Order order) {
    return CustomScrollView(
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
                // Status
                _StatusChip(status: order.status),
                const SizedBox(height: 16),

                // Buyer info
                _InfoCard(
                  title: 'Buyer',
                  children: [
                    if (order.buyerName != null)
                      Text(order.buyerName!,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                    if (order.buyer?['address'] != null)
                      Text(order.buyer!['address'],
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                  ],
                  trailing: order.buyerPhone != null
                      ? IconButton(
                          onPressed: () async {
                            final uri =
                                Uri.parse('tel:${order.buyerPhone}');
                            if (await canLaunchUrl(uri)) launchUrl(uri);
                          },
                          icon: const Icon(Icons.phone_rounded,
                              color: AppColors.accentGreen),
                        )
                      : null,
                ),
                const SizedBox(height: 12),

                // Delivery type
                _InfoCard(
                  title: 'Delivery',
                  children: [
                    Text(order.deliveryOption.label,
                        style: const TextStyle(color: Colors.white)),
                    if (order.distanceKm != null)
                      Text('${order.distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),

                // Items
                Text('Items', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(item.product?.title ?? 'Product',
                                  style: const TextStyle(
                                      color: Colors.white))),
                          Text(
                              '×${item.quantity} · ${item.subtotal.toStringAsFixed(0)} DZD',
                              style: const TextStyle(
                                  color: AppColors.accentGreen)),
                        ],
                      ),
                    )),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text('${order.totalPrice.toStringAsFixed(0)} DZD',
                        style: const TextStyle(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 24),

                // Deliverer contact
                if (order.delivererName != null) ...[
                  _InfoCard(
                    title: 'Deliverer',
                    children: [
                      Text(order.delivererName!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ],
                    trailing: order.delivererPhone != null
                        ? IconButton(
                            onPressed: () async {
                              final uri = Uri.parse(
                                  'tel:${order.delivererPhone}');
                              if (await canLaunchUrl(uri))
                                launchUrl(uri);
                            },
                            icon: const Icon(Icons.phone_rounded,
                                color: AppColors.accentGreen),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // Action buttons
                _buildActions(order),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(Order order) {
    if (_isActing) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen));
    }
    if (order.status == OrderStatus.PENDING) {
      return Column(
        children: [
          PrimaryButton(
            label: 'Accept Order',
            icon: Icons.check_circle_rounded,
            onPressed: () => _accept(order.id),
          ),
          const SizedBox(height: 10),
          GlassButton(
            label: 'Reject Order',
            icon: Icons.cancel_rounded,
            accentColor: AppColors.error,
            onPressed: () => _reject(order.id),
          ),
        ],
      );
    }
    if ((order.status == OrderStatus.AWAITING_BUYER_PICKUP ||
            order.status == OrderStatus.AWAITING_DELIVERER_PICKUP) &&
        !order.farmerConfirmedPickup) {
      return PrimaryButton(
        label: 'Confirm Pickup',
        icon: Icons.check_circle_rounded,
        onPressed: () => _confirmPickup(order.id),
      );
    }
    return const SizedBox.shrink();
  }
}

class _OrderListTile extends StatelessWidget {
  final Order order;
  const _OrderListTile(this.order);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/farmer/orders/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.glassCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: order.status == OrderStatus.PENDING
                ? AppColors.statusPending.withOpacity(0.4)
                : AppColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  if (order.buyerName != null)
                    Text(order.buyerName!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  Text('${order.totalPrice.toStringAsFixed(0)} DZD',
                      style: const TextStyle(color: AppColors.accentGreen)),
                ],
              ),
            ),
            _StatusChip(status: order.status),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  Color get color {
    switch (status) {
      case OrderStatus.PENDING: return AppColors.statusPending;
      case OrderStatus.REJECTED: return AppColors.statusRejected;
      case OrderStatus.COMPLETED: return AppColors.statusCompleted;
      default: return AppColors.statusInProgress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(status.label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;
  const _InfoCard(
      {required this.title, required this.children, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glassCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ...children,
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
