import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/farm_background.dart';
import '../providers/my_products_provider.dart';
import '../../../router/app_router.dart';

class MyProductsScreen extends ConsumerWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(myProductsProvider);

    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text('My Products',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              Expanded(
                child: productsAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentGreen)),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (result) => result.data.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inventory_2_outlined,
                                  size: 80, color: AppColors.textMuted),
                              const SizedBox(height: 16),
                              Text('No products yet',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: 8),
                              Text('Tap + to add your first product',
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.accentGreen,
                          onRefresh: () =>
                              ref.read(myProductsProvider.notifier).load(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: result.data.length,
                            itemBuilder: (ctx, i) {
                              final p = result.data[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.glassCard,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: p.isAvailable
                                        ? AppColors.glassBorder
                                        : AppColors.error.withOpacity(0.3),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  leading: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: p.primaryImageUrl != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              '${ApiConstants.serverUrl}${p.primaryImageUrl}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(Icons.eco_rounded,
                                                      color:
                                                          AppColors.accentGreen),
                                            ),
                                          )
                                        : const Icon(Icons.eco_rounded,
                                            color: AppColors.accentGreen),
                                  ),
                                  title: Text(p.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                    p.formattedPrice,
                                    style: const TextStyle(
                                        color: AppColors.accentGreen),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    color: AppColors.surface,
                                    icon: const Icon(Icons.more_vert,
                                        color: Colors.white),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        context.go(
                                            '/farmer/products/${p.id}/edit');
                                      } else if (value == 'toggle') {
                                        await ref
                                            .read(myProductsProvider.notifier)
                                            .toggleAvailability(
                                                p.id, !p.isAvailable);
                                      } else if (value == 'delete') {
                                        await ref
                                            .read(myProductsProvider.notifier)
                                            .deleteProduct(p.id);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: ListTile(
                                          leading: Icon(Icons.edit_rounded,
                                              color: Colors.white),
                                          title: Text('Edit',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'toggle',
                                        child: ListTile(
                                          leading: Icon(
                                            p.isAvailable
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: Colors.white,
                                          ),
                                          title: Text(
                                            p.isAvailable
                                                ? 'Mark Unavailable'
                                                : 'Mark Available',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(Icons.delete_rounded,
                                              color: AppColors.error),
                                          title: Text('Delete',
                                              style: TextStyle(
                                                  color: AppColors.error)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.addProduct),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product'),
      ),
    );
  }
}
