import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/enums.dart';
import '../../../core/models/commune.dart';
import '../../../core/models/wilaya.dart';
import '../../../core/providers/geo_providers.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../core/widgets/glass_button.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../../../router/app_router.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  DeliveryOption _deliveryOption = DeliveryOption.WITH_DELIVERY;
  Wilaya? _selectedWilaya;
  Commune? _selectedCommune;
  bool _isSubmitting = false;

  Future<void> _checkout() async {
    if (_selectedCommune == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your commune')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(buyerOrdersProvider.notifier).createOrder(
            deliveryOption: _deliveryOption,
            buyerCommuneId: _selectedCommune!.id,
          );
      await ref.read(cartProvider.notifier).load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        context.go(AppRoutes.buyerOrders);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Checkout failed: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: cartAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (cart) {
              if (cart == null || cart.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_cart_outlined,
                          size: 80, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text('Your cart is empty',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('Browse products and add them to cart',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 200,
                        child: PrimaryButton(
                          label: 'Browse Products',
                          onPressed: () => context.go(AppRoutes.buyerHome),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Text('My Cart',
                            style: Theme.of(context).textTheme.headlineMedium),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              ref.read(cartProvider.notifier).clearCart(),
                          child: const Text('Clear',
                              style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: cart.items.length,
                      itemBuilder: (ctx, i) {
                        final item = cart.items[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.glassCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            children: [
                              // Product image placeholder
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: item.product?.primaryImageUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          '${ApiConstants.serverUrl}${item.product!.primaryImageUrl}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.eco_rounded,
                                                  color: AppColors.accentGreen),
                                        ),
                                      )
                                    : const Icon(Icons.eco_rounded,
                                        color: AppColors.accentGreen),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product?.title ?? 'Product',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: Colors.white),
                                    ),
                                    Text(
                                      '${item.subtotal.toStringAsFixed(0)} DZD',
                                      style: const TextStyle(
                                          color: AppColors.accentGreen,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity controls
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (item.quantity <= 0.5) {
                                        ref
                                            .read(cartProvider.notifier)
                                            .removeItem(item.productId);
                                      } else {
                                        ref
                                            .read(cartProvider.notifier)
                                            .updateItem(item.productId,
                                                item.quantity - 0.5);
                                      }
                                    },
                                    icon: const Icon(Icons.remove_circle_outline,
                                        color: AppColors.error, size: 22),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      item.quantity % 1 == 0
                                          ? item.quantity.toInt().toString()
                                          : item.quantity.toStringAsFixed(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => ref
                                        .read(cartProvider.notifier)
                                        .updateItem(item.productId,
                                            item.quantity + 0.5),
                                    icon: const Icon(Icons.add_circle_outline,
                                        color: AppColors.accentGreen, size: 22),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Checkout panel
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.9),
                      border: const Border(
                          top: BorderSide(color: AppColors.glassBorder)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Delivery option toggle
                        Text('Delivery Option',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _DeliveryToggle(
                              label: 'With Delivery',
                              icon: Icons.local_shipping_rounded,
                              selected: _deliveryOption ==
                                  DeliveryOption.WITH_DELIVERY,
                              onTap: () => setState(() =>
                                  _deliveryOption = DeliveryOption.WITH_DELIVERY),
                            ),
                            const SizedBox(width: 10),
                            _DeliveryToggle(
                              label: 'Self Pickup',
                              icon: Icons.directions_walk_rounded,
                              selected: _deliveryOption ==
                                  DeliveryOption.WITHOUT_DELIVERY,
                              onTap: () => setState(() => _deliveryOption =
                                  DeliveryOption.WITHOUT_DELIVERY),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // ── Wilaya picker ─────────────────────────────────
                        ref.watch(wilayasProvider).when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: CircularProgressIndicator(
                                  color: AppColors.accentGreen, strokeWidth: 2),
                            ),
                          ),
                          error: (e, _) => TextButton.icon(
                            onPressed: () => ref.refresh(wilayasProvider),
                            icon: const Icon(Icons.refresh,
                                color: AppColors.error, size: 16),
                            label: const Text('Reload wilayas',
                                style: TextStyle(
                                    color: AppColors.error, fontSize: 12)),
                          ),
                          data: (wilayas) => DropdownButtonFormField<Wilaya>(
                            value: _selectedWilaya,
                            dropdownColor: AppColors.surface,
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Your Wilaya',
                              prefixIcon: Icon(Icons.map_outlined),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                            items: wilayas
                                .map((w) => DropdownMenuItem(
                                      value: w,
                                      child: Text(
                                        '${w.code.toString().padLeft(2, '0')} — ${w.nameLatin}',
                                      ),
                                    ))
                                .toList(),
                            onChanged: (w) => setState(() {
                              _selectedWilaya = w;
                              _selectedCommune = null;
                            }),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ── Commune picker (cascades from wilaya) ──────────
                        if (_selectedWilaya == null)
                          DropdownButtonFormField<Commune>(
                            value: null,
                            decoration: const InputDecoration(
                              labelText: 'Your Commune',
                              prefixIcon: Icon(Icons.location_on_outlined),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                            items: const [],
                            onChanged: null,
                            hint: const Text('Select a wilaya first',
                                style:
                                    TextStyle(color: AppColors.textMuted)),
                          )
                        else
                          ref
                              .watch(communesProvider(_selectedWilaya!.id))
                              .when(
                                loading: () => const Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8),
                                    child: CircularProgressIndicator(
                                        color: AppColors.accentGreen,
                                        strokeWidth: 2),
                                  ),
                                ),
                                error: (e, _) => TextButton.icon(
                                  onPressed: () => ref.refresh(
                                      communesProvider(_selectedWilaya!.id)),
                                  icon: const Icon(Icons.refresh,
                                      color: AppColors.error, size: 16),
                                  label: const Text('Reload communes',
                                      style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12)),
                                ),
                                data: (communes) =>
                                    DropdownButtonFormField<Commune>(
                                  value: _selectedCommune,
                                  dropdownColor: AppColors.surface,
                                  isExpanded: true,
                                  style:
                                      const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Your Commune',
                                    prefixIcon:
                                        Icon(Icons.location_on_outlined),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                  ),
                                  items: communes
                                      .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c.nameLatin)))
                                      .toList(),
                                  onChanged: (c) =>
                                      setState(() => _selectedCommune = c),
                                ),
                              ),
                        const SizedBox(height: 12),
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                                style: Theme.of(context).textTheme.titleLarge),
                            Text(
                              '${cart.total.toStringAsFixed(0)} DZD',
                              style: const TextStyle(
                                color: AppColors.accentGreen,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: 'Place Order',
                          icon: Icons.check_circle_rounded,
                          onPressed: _checkout,
                          isLoading: _isSubmitting,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DeliveryToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DeliveryToggle({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryGreen.withOpacity(0.3)
                : AppColors.glassCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primaryGreenLight : AppColors.glassBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? AppColors.accentGreen : AppColors.textMuted,
                  size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
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
