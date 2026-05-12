import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../core/widgets/glass_button.dart';
import '../providers/my_products_provider.dart';
import '../../../router/app_router.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;
  const ProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _priceUnitCtrl = TextEditingController(text: 'kg');
  final _qtyCtrl = TextEditingController();
  int? _categoryId;
  bool _isLoading = false;
  bool _isLoadingProduct = false;

  List<Category> _categories = [];
  List<String> _newImagePaths = [];
  List<ProductImage> _existingImages = [];
  Product? _existingProduct;

  bool get isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (isEdit) _loadProduct();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ref.read(apiServiceProvider).getCategories();
      setState(() => _categories = cats);
    } catch (_) {}
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoadingProduct = true);
    try {
      final p = await ref.read(apiServiceProvider).getProduct(widget.productId!);
      setState(() {
        _existingProduct = p;
        _titleCtrl.text = p.title;
        _descCtrl.text = p.description ?? '';
        _priceCtrl.text = p.price.toString();
        _priceUnitCtrl.text = p.priceUnit;
        _qtyCtrl.text = p.quantity.toString();
        _categoryId = p.categoryId;
        _existingImages = p.images;
      });
    } catch (_) {}
    setState(() => _isLoadingProduct = false);
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _newImagePaths.addAll(picked.map((f) => f.path));
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text),
        'priceUnit': _priceUnitCtrl.text.trim(),
        'categoryId': _categoryId,
        'quantity': double.parse(_qtyCtrl.text),
      };

      Product product;
      if (isEdit) {
        product = await api.updateProduct(widget.productId!, data);
      } else {
        product = await api.createProduct(data);
      }

      // Upload new images
      if (_newImagePaths.isNotEmpty) {
        await api.uploadProductImages(product.id, _newImagePaths);
      }

      ref.read(myProductsProvider.notifier).load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isEdit
                  ? 'Product updated!'
                  : 'Product created!')),
        );
        context.go(AppRoutes.myProducts);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _priceCtrl.dispose(); _priceUnitCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: _isLoadingProduct
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accentGreen))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(isEdit ? 'Edit Product' : 'New Product',
                            style:
                                Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 24),

                        // Images section
                        Text('Photos',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              // Existing images
                              ..._existingImages.map((img) => Stack(
                                    children: [
                                      Container(
                                        width: 90,
                                        height: 90,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: AppColors.glassBorder),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            '${ApiConstants.serverUrl}${img.url}',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await ref
                                                .read(apiServiceProvider)
                                                .deleteProductImage(
                                                    widget.productId!, img.id);
                                            setState(() => _existingImages
                                                .removeWhere(
                                                    (i) => i.id == img.id));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: AppColors.error,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close,
                                                color: Colors.white, size: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                              // New image previews
                              ..._newImagePaths.map((p) => Container(
                                    width: 90,
                                    height: 90,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppColors.primaryGreenLight),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(p, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.image_rounded)),
                                    ),
                                  )),
                              // Add button
                              GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: AppColors.glassCard,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.glassBorder,
                                        style: BorderStyle.solid),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_rounded,
                                          color: AppColors.accentGreen,
                                          size: 32),
                                      SizedBox(height: 4),
                                      Text('Add Photo',
                                          style: TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        _f(_titleCtrl, 'Title', Icons.label_outline),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            prefixIcon: Icon(Icons.description_outlined),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _f(_priceCtrl, 'Price (DZD)',
                                  Icons.attach_money_rounded,
                                  type: TextInputType.number),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _f(_priceUnitCtrl, 'Unit',
                                  Icons.scale_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _f(_qtyCtrl, 'Available Quantity',
                            Icons.inventory_rounded,
                            type: TextInputType.number),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          value: _categoryId,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: _categories
                              .map((c) => DropdownMenuItem(
                                  value: c.id, child: Text(c.name)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _categoryId = v),
                          validator: (v) =>
                              v == null ? 'Select a category' : null,
                        ),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          label: isEdit ? 'Save Changes' : 'Create Product',
                          icon: Icons.check_circle_rounded,
                          onPressed: _submit,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _f(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (v) => v!.isEmpty ? '$label is required' : null,
    );
  }
}
