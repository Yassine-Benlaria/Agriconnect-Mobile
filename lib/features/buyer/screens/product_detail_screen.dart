import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      body: FarmBackground(
        child: productAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accentGreen)),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (product) => CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primaryGreenDark,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: product.images.isNotEmpty
                      ? PageView.builder(
                          itemCount: product.images.length,
                          itemBuilder: (ctx, i) => Image.network(
                            '${ApiConstants.serverUrl}${product.images[i].url}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primaryGreenDark,
                              child: const Icon(Icons.eco_rounded,
                                  color: AppColors.accentGreen, size: 80),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primaryGreenDark,
                          child: const Icon(Icons.eco_rounded,
                              color: AppColors.accentGreen, size: 80),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(product.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium),
                          ),
                          Text(
                            product.formattedPrice,
                            style: const TextStyle(
                              color: AppColors.accentGreen,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Available quantity
                      Text(
                        'Available: ${product.quantity} ${product.priceUnit}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      if (product.description != null) ...[
                        Text('Description',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(product.description!,
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 16),
                      ],
                      // Farmer info
                      if (product.farmerName != null) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.glassCard,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    AppColors.primaryGreen.withOpacity(0.4),
                                backgroundImage: product.farmerAvatarUrl != null
                                    ? NetworkImage(
                                        '${ApiConstants.serverUrl}${product.farmerAvatarUrl}')
                                    : null,
                                child: product.farmerAvatarUrl == null
                                    ? Text(
                                        product.farmerName![0].toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(product.farmerName!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    if (product.farmerRating != null)
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded,
                                              size: 14,
                                              color: Color(0xFFFFC107)),
                                          const SizedBox(width: 4),
                                          Text(
                                            product.farmerRating!
                                                .toStringAsFixed(1),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.agriculture_rounded,
                                  color: AppColors.accentGreen),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      _AddToCartButton(productId: product.id),
                      const SizedBox(height: 32),
                    ],
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

class _AddToCartButton extends ConsumerStatefulWidget {
  final String productId;
  const _AddToCartButton({required this.productId});

  @override
  ConsumerState<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends ConsumerState<_AddToCartButton> {
  double _qty = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quantity selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _qty > 0.5
                  ? () => setState(() => _qty = (_qty - 0.5).clamp(0.5, 999))
                  : null,
              icon: const Icon(Icons.remove_circle_outline,
                  color: AppColors.accentGreen),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _qty % 1 == 0
                    ? _qty.toInt().toString()
                    : _qty.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            IconButton(
              onPressed: () =>
                  setState(() => _qty = (_qty + 0.5).clamp(0.5, 999)),
              icon: const Icon(Icons.add_circle_outline,
                  color: AppColors.accentGreen),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Add to Cart',
          icon: Icons.shopping_cart_rounded,
          isLoading: _isLoading,
          onPressed: () async {
            setState(() => _isLoading = true);
            try {
              await ref
                  .read(cartProvider.notifier)
                  .addItem(widget.productId, _qty);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to cart!')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed: $e'),
                      backgroundColor: AppColors.error),
                );
              }
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
        ),
      ],
    );
  }
}
