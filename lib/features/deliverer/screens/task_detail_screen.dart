import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../core/widgets/glass_button.dart';
import '../providers/deliveries_provider.dart';
import '../../../router/app_router.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const TaskDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isAssigning = false;

  Future<void> _assign() async {
    setState(() => _isAssigning = true);
    try {
      await ref
          .read(deliveryActionsProvider.notifier)
          .assign(widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task assigned! Go pick up the order.')),
        );
        context.go(AppRoutes.currentTask);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to assign: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Load order detail
    return FutureBuilder(
      future: ref.read(apiServiceProvider).getDeliveryDetail(widget.orderId),
      builder: (context, snapshot) {
        return Scaffold(
          body: FarmBackground(
            child: SafeArea(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentGreen))
                  : snapshot.hasError
                      ? Center(child: Text('Error: ${snapshot.error}'))
                      : snapshot.data == null
                          ? const Center(child: Text('Task not found'))
                          : _buildDetail(context, snapshot.data!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetail(BuildContext context, dynamic order) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text('Task #${order.id.substring(0, 8).toUpperCase()}'),
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
                // Earnings
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen.withOpacity(0.3),
                        AppColors.primaryGreenLight.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.primaryGreenLight.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_rounded,
                          color: AppColors.accentGreen, size: 40),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Earnings',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            '${(order.deliveryPrice ?? 0).toStringAsFixed(0)} DZD',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: AppColors.accentGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Route
                Text('Route', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _RouteCard(
                  fromLabel: order.farmerName ?? 'Farmer',
                  toLabel: order.buyerName ?? 'Buyer',
                  distanceKm: order.distanceKm,
                ),
                const SizedBox(height: 20),

                // Items
                Text('Cargo', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...order.items.map<Widget>((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.glassCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              color: AppColors.accentGreen),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(item.product?.title ?? 'Product',
                                  style: const TextStyle(
                                      color: Colors.white))),
                          Text('×${item.quantity}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    )),
                const SizedBox(height: 28),

                // Assign button
                PrimaryButton(
                  label: 'Assign to Me',
                  icon: Icons.assignment_ind_rounded,
                  isLoading: _isAssigning,
                  onPressed: _assign,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  final String fromLabel;
  final String toLabel;
  final double? distanceKm;

  const _RouteCard({
    required this.fromLabel,
    required this.toLabel,
    this.distanceKm,
  });

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
            children: [
              const Icon(Icons.circle,
                  color: AppColors.primaryGreenLight, size: 12),
              const SizedBox(width: 10),
              Expanded(
                child: Text('FROM: $fromLabel',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Container(
                width: 2, height: 24, color: AppColors.glassBorder),
          ),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: AppColors.statusPending, size: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Text('TO: $toLabel',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          if (distanceKm != null) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.glassBorder),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.straighten_rounded,
                    color: AppColors.textMuted, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${distanceKm!.toStringAsFixed(1)} km',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
