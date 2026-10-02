import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_image_model.dart';
import '../../data/models/product_variant_model.dart';
import '../../data/models/attribute_model.dart';
import '../../data/models/attribute_value_model.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../widgets/add_edit_variant_bottom_sheet.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../sub_categories/domain/repositories/sub_category_repository.dart';
import '../../../brands/domain/repositories/brand_repository.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductModel _product;
  List<ProductImageModel> _images = [];
  List<ProductVariantModel> _variants = [];
  List<AttributeModel> _availableAttributes = [];
  int _selectedIndex = 0;
  String? _categoryName;
  String? _subCategoryName;
  String? _brandName;

  List<AttributeModel> get _effectiveAttributes {
    if (_availableAttributes.isNotEmpty) return _availableAttributes;
    return [
      AttributeModel(
        id: 'color',
        name: 'Color',
        status: 'ACTIVE',
        values: [
          AttributeValueModel(id: 'c1', attributeId: 'color', value: 'Red'),
          AttributeValueModel(id: 'c2', attributeId: 'color', value: 'Blue'),
          AttributeValueModel(id: 'c3', attributeId: 'color', value: 'Black'),
          AttributeValueModel(id: 'c4', attributeId: 'color', value: 'White'),
        ],
      ),
      AttributeModel(
        id: 'size',
        name: 'Size',
        status: 'ACTIVE',
        values: [
          AttributeValueModel(id: 's1', attributeId: 'size', value: 'S'),
          AttributeValueModel(id: 's2', attributeId: 'size', value: 'M'),
          AttributeValueModel(id: 's3', attributeId: 'size', value: 'L'),
          AttributeValueModel(id: 's4', attributeId: 'size', value: 'XL'),
          AttributeValueModel(id: 's5', attributeId: 'size', value: 'XXL'),
        ],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _categoryName = widget.product.categoryName;
    _subCategoryName = widget.product.subCategoryName;
    _brandName = widget.product.brandName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(const FetchAttributesEvent());
      context.read<ProductBloc>().add(FetchProductVariantsEvent(productId: widget.product.id));
      context.read<ProductBloc>().add(FetchProductImagesEvent(productId: widget.product.id));
    });

    final commonImages = widget.product.images
        .where((img) => img.productVariantId == null || img.productVariantId!.isEmpty)
        .toList();
    if (commonImages.isNotEmpty) {
      _images = List.from(commonImages);
    }
    if (widget.product.variants.isNotEmpty) {
      _variants = widget.product.variants.map((v) {
        final variantImages = v.images.where((img) => img.productVariantId == v.id).toList();
        return v.copyWith(images: variantImages);
      }).toList();
    }

    _fetchClassificationNames();
    _refreshProduct();
  }

  Future<void> _refreshProduct() async {
    try {
      final fresh = await sl<ProductRepository>().getProductById(widget.product.id);
      if (mounted) {
        setState(() {
          _product = fresh;
          if (fresh.categoryName != null) _categoryName = fresh.categoryName;
          if (fresh.subCategoryName != null) _subCategoryName = fresh.subCategoryName;
          if (fresh.brandName != null) _brandName = fresh.brandName;
          if (fresh.variants.isNotEmpty) {
            _variants = fresh.variants.map((v) {
              final variantImages = v.images.where((img) => img.productVariantId == v.id).toList();
              return v.copyWith(images: variantImages);
            }).toList();
          }
          final commonImages = fresh.images
              .where((img) => img.productVariantId == null || img.productVariantId!.isEmpty)
              .toList();
          if (commonImages.isNotEmpty) {
            _images = List.from(commonImages);
          }
        });
        _fetchClassificationNames();
      }
    } catch (_) {}
  }

  Future<void> _fetchClassificationNames() async {
    try {
      if (_categoryName == null && _product.categoryId.isNotEmpty) {
        final categoryRepo = sl<CategoryRepository>();
        final list = await categoryRepo.getCategories();
        final match = list.where((c) => c.id == _product.categoryId).firstOrNull;
        if (match != null && mounted) {
          setState(() {
            _categoryName = match.name;
          });
        }
      }
      if (_subCategoryName == null && _product.subCategoryId.isNotEmpty) {
        final subCategoryRepo = sl<SubCategoryRepository>();
        final list = await subCategoryRepo.getSubCategories(categoryId: _product.categoryId);
        final match = list.where((sc) => sc.id == _product.subCategoryId).firstOrNull;
        if (match != null && mounted) {
          setState(() {
            _subCategoryName = match.name;
          });
        }
      }
      if (_brandName == null && _product.brandId.isNotEmpty) {
        final brandRepo = sl<BrandRepository>();
        final list = await brandRepo.getBrands();
        final match = list.where((b) => b.id == _product.brandId).firstOrNull;
        if (match != null && mounted) {
          setState(() {
            _brandName = match.name;
          });
        }
      }
    } catch (_) {}
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return AppColors.primaryGreen;
      case 'PENDING':
        return AppColors.brandOrange;
      case 'REJECTED':
      case 'SUSPENDED':
        return AppColors.brandRed;
      case 'DRAFT':
        return const Color(0xFF2563EB);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_product.status);
    final canEdit = _product.status.toUpperCase() == 'DRAFT' ||
        _product.status.toUpperCase() == 'PENDING' ||
        _product.status.toUpperCase() == 'REJECTED';
    final isDraft = _product.status.toUpperCase() == 'DRAFT';

    return BlocProvider(
      create: (_) => sl<ProductBloc>()
        ..add(FetchProductImagesEvent(productId: _product.id))
        ..add(FetchProductVariantsEvent(productId: _product.id)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F8F6),
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leadingWidth: 56,
          leading: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE4ECE8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: Color(0xFF1A3827),
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          title: const Text(
            'Product Details',
            style: TextStyle(
              color: Color(0xFF11261B),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryGreen),
              tooltip: 'Manage Inventory',
              onPressed: () async {
                await context.push('/products/inventory', extra: _product);
                _refreshProduct();
              },
            ),
            IconButton(
              icon: const Icon(Icons.local_shipping_outlined, color: Color(0xFF2563EB)),
              tooltip: 'Configure Shipping',
              onPressed: () async {
                await context.push('/products/shipping', extra: _product);
                _refreshProduct();
              },
            ),
            if (canEdit)
              Builder(
                builder: (blocContext) => IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.brandOrange),
                  tooltip: 'Edit Product',
                  onPressed: () async {
                    await context.push('/products/edit', extra: _product);
                    if (context.mounted) {
                      _refreshProduct();
                      blocContext.read<ProductBloc>().add(FetchProductImagesEvent(productId: _product.id));
                      blocContext.read<ProductBloc>().add(FetchProductVariantsEvent(productId: _product.id));
                    }
                  },
                ),
              ),
          ],
        ),
        body: BlocConsumer<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductImagesLoaded) {
              final commonImages = state.images
                  .where((img) => img.productVariantId == null || img.productVariantId!.isEmpty)
                  .toList();
              final sorted = List<ProductImageModel>.from(commonImages);
              sorted.sort((a, b) {
                if (a.isPrimary && !b.isPrimary) return -1;
                if (!a.isPrimary && b.isPrimary) return 1;
                return a.displayOrder.compareTo(b.displayOrder);
              });
              setState(() {
                _images = sorted;
                if (_selectedIndex >= sorted.length) {
                  _selectedIndex = 0;
                }
              });
            } else if (state is ProductVariantsLoadedState) {
              setState(() {
                _variants = state.variants.map((v) {
                  final variantImages = v.images.where((img) => img.productVariantId == v.id).toList();
                  return v.copyWith(images: variantImages);
                }).toList();
              });
            } else if (state is ProductVariantActionSuccess) {
              setState(() {
                _variants = state.variants.map((v) {
                  final variantImages = v.images.where((img) => img.productVariantId == v.id).toList();
                  return v.copyWith(images: variantImages);
                }).toList();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.primaryGreen),
              );
            } else if (state is AttributesLoadedState) {
              setState(() {
                _availableAttributes = state.attributes;
              });
            } else if (state is ProductActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.primaryGreen),
              );
              if (state.message.toLowerCase().contains('delete')) {
                context.go('/products', extra: {'initialStatus': _product.status});
              } else {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/products');
                }
              }
            } else if (state is ProductActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.brandRed),
              );
            }
          },
          builder: (context, state) {
            final activeImage = _images.isNotEmpty
                ? _images[_selectedIndex].imageUrl
                : (_product.primaryImageUrl ?? _product.image);

            final bool isSelectedPrimary = _images.isNotEmpty
                ? _images[_selectedIndex].isPrimary
                : true;

            final isLoading = state is ProductImagesLoading && _images.isEmpty;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TOP MEDIA CARD: Gallery & Image Preview
                  _buildGalleryCard(activeImage, isSelectedPrimary, isLoading, statusColor),
                  const SizedBox(height: 16),

                  // STEP 1: Classification & Brand
                  _buildSectionCard(
                    step: '1',
                    icon: Icons.category_outlined,
                    title: 'Classification & Brand',
                    subtitle: 'Category hierarchy and brand assignment',
                    children: [
                      _buildInfoTile(
                        icon: Icons.folder_outlined,
                        label: 'Category',
                        value: _categoryName ?? (_product.categoryName ?? 'Not Assigned'),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoTile(
                        icon: Icons.subdirectory_arrow_right_rounded,
                        label: 'Sub-Category',
                        value: _subCategoryName ?? (_product.subCategoryName ?? 'Not Assigned'),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoTile(
                        icon: Icons.verified_outlined,
                        label: 'Brand',
                        value: _brandName ?? (_product.brandName ?? 'Generic / No Brand'),
                      ),
                    ],
                  ),

                  // STEP 2: Basic Information
                  _buildSectionCard(
                    step: '2',
                    icon: Icons.info_outline_rounded,
                    title: 'Basic Information',
                    subtitle: 'Product identification, descriptions and SKU',
                    children: [
                      Text(
                        _product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE4ECE8)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'SKU: ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B8A78),
                                  ),
                                ),
                                Text(
                                  _product.sku.isEmpty ? 'N/A' : _product.sku,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF11261B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              if (_product.sku.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: _product.sku));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('SKU copied to clipboard'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.copy_rounded, size: 14, color: AppColors.primaryGreen),
                                  SizedBox(width: 4),
                                  Text(
                                    'Copy SKU',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_product.shortDescription != null && _product.shortDescription!.trim().isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAF9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE8EFEA)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Short Description',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B8A78),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _product.shortDescription!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF26382E),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_product.description != null && _product.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Detailed Description',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B8A78),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _product.description!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF3B4E43),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // STEP 3: Pricing & Inventory
                  _buildSectionCard(
                    step: '3',
                    icon: Icons.sell_outlined,
                    title: 'Pricing & Inventory',
                    subtitle: 'Base pricing, MRP and stock availability',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selling Price',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4C6656),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${_product.sellingPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FBF9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE4ECE8)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'MRP',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${_product.mrp.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF11261B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              label: 'Tax Rate',
                              value: _product.taxPercentage != null
                                  ? '${_product.taxPercentage!.toStringAsFixed(0)}%'
                                  : '0%',
                              icon: Icons.percent_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricTile(
                              label: 'Stock Quantity',
                              value: _product.stock != null ? '${_product.stock} units' : 'N/A',
                              icon: Icons.inventory_2_outlined,
                              valueColor: (_product.stock != null && _product.stock! > 0)
                                  ? AppColors.primaryGreen
                                  : AppColors.brandRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // STEP 4: Product Specifications & Packaging
                  _buildSectionCard(
                    step: '4',
                    icon: Icons.straighten_rounded,
                    title: 'Specifications & Packaging',
                    subtitle: 'Product physical weight and package box dimensions',
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAF9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE4ECE8)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSpecItem(
                                    icon: Icons.scale_outlined,
                                    title: 'Weight',
                                    value: _product.weight != null
                                        ? '${_product.weight} kg'
                                        : 'Not Specified',
                                    isHighlighted: _product.weight != null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSpecItem(
                                    icon: Icons.open_in_full_rounded,
                                    title: 'Length',
                                    value: _product.length != null
                                        ? '${_product.length} cm'
                                        : 'Not Specified',
                                    isHighlighted: _product.length != null,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1, color: Color(0xFFE8EFEA)),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSpecItem(
                                    icon: Icons.swap_horiz_rounded,
                                    title: 'Width',
                                    value: _product.width != null
                                        ? '${_product.width} cm'
                                        : 'Not Specified',
                                    isHighlighted: _product.width != null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSpecItem(
                                    icon: Icons.swap_vert_rounded,
                                    title: 'Height',
                                    value: _product.height != null
                                        ? '${_product.height} cm'
                                        : 'Not Specified',
                                    isHighlighted: _product.height != null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: Color(0xFF7A9A86)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _product.weight != null || _product.length != null
                                  ? 'Specifications synced with logistics and fulfillment.'
                                  : 'No packaging specs added. Edit product or configure shipping to add them.',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF7A9A86)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // STEP 5: Variants & Attributes
                  _buildSectionCard(
                    step: '5',
                    icon: Icons.style_outlined,
                    title: 'Variants & Attributes',
                    subtitle: 'Product variations, colors, sizes and SKU splits',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_variants.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_variants.length} Variants',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        InkWell(
                          onTap: () => _openAddVariantSheet(),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A3827),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Add Variant',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      if (_variants.isEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FBF9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8EFEA)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 36, color: Color(0xFF9EAEA4)),
                              const SizedBox(height: 8),
                              const Text(
                                'No Product Variants',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'This product operates as a single standalone item.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF6B8A78)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: () => _openAddVariantSheet(),
                                icon: const Icon(Icons.add_circle_outline, size: 16),
                                label: const Text('Add First Variant'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A3827),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _variants.length,
                          separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFE8EFE9)),
                          itemBuilder: (ctx, i) {
                            final v = _variants[i];
                            final variantImages = v.images.where((img) => img.productVariantId == v.id).toList();
                            String? vImg;
                            if (variantImages.isNotEmpty) {
                              final primary = variantImages.firstWhere((img) => img.isPrimary, orElse: () => variantImages.first);
                              vImg = primary.imageUrl;
                            }

                            return InkWell(
                              onTap: () => _showVariantDetailsModal(context, v),
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F8F5),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFE4ECE8)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(9),
                                        child: (vImg != null && vImg.isNotEmpty)
                                            ? CustomImageView(imageUrl: vImg, width: 46, height: 46, fit: BoxFit.cover)
                                            : const Icon(Icons.style_outlined, color: Color(0xFF1A3827), size: 22),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  v.variantName,
                                                  style: const TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF11261B),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (v.isDefault) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'Default',
                                                    style: TextStyle(
                                                      fontSize: 9.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.primaryGreen,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'SKU: ${v.sku} | Stock: ${v.stock}',
                                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF7A9A86)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${v.price.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                        ),
                                        const SizedBox(height: 2),
                                        const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'View',
                                              style: TextStyle(fontSize: 11, color: Color(0xFF1A3827), fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(width: 2),
                                            Icon(Icons.chevron_right, size: 14, color: Color(0xFF1A3827)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 14),
                      // Action to manage variant inventory
                      InkWell(
                        onTap: () async {
                          await context.push('/products/inventory', extra: _product);
                          _refreshProduct();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F6F3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD6E4DB)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.primaryGreen),
                              SizedBox(width: 8),
                              Text(
                                'Manage Variant Inventory & Stock',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3827),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF1A3827)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // STEP 6: Shipping & Logistics Card
                  _buildSectionCard(
                    step: '6',
                    icon: Icons.local_shipping_outlined,
                    title: 'Shipping & Fulfillment',
                    subtitle: 'Delivery rates, estimated turnaround and COD rules',
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.local_shipping_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Product Shipping Profile',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Configure rates, free delivery rules and cash on delivery',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await context.push('/products/shipping', extra: _product);
                                _refreshProduct();
                              },
                              icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // AUDIT & METADATA CARD
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4ECE8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Audit & Timeline',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Created Date', _formatDate(_product.createdAt)),
                        const SizedBox(height: 8),
                        _buildDetailRow('Last Updated', _formatDate(_product.updatedAt)),
                        if (_product.status.toUpperCase() == 'REJECTED' &&
                            _product.rejectedReason != null &&
                            _product.rejectedReason!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.brandRed.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.report_problem_outlined, color: AppColors.brandRed, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Admin Rejection Reason',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandRed),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _product.rejectedReason!,
                                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF11261B), height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // BOTTOM ACTIONS
                  if (state is ProductActionLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.brandOrange))
                  else ...[
                    if (isDraft) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<ProductBloc>().add(SubmitProductForApprovalEvent(id: _product.id));
                        },
                        icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                        label: const Text('SUBMIT FOR APPROVAL', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (canEdit) ...[
                      ElevatedButton.icon(
                        onPressed: () async {
                          await context.push('/products/edit', extra: _product);
                          if (context.mounted) {
                            _refreshProduct();
                            context.read<ProductBloc>().add(FetchProductImagesEvent(productId: _product.id));
                            context.read<ProductBloc>().add(FetchProductVariantsEvent(productId: _product.id));
                          }
                        },
                        icon: const Icon(Icons.edit_note_rounded, size: 20),
                        label: const Text('EDIT PRODUCT DETAILS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3827),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.brandRed),
                        label: const Text('DELETE PRODUCT', style: TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.brandRed),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- GALLERY WIDGET ---
  Widget _buildGalleryCard(String? activeImage, bool isSelectedPrimary, bool isLoading, Color statusColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Main Display Card
          Stack(
            children: [
              Container(
                height: 230,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBF9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primaryGreen,
                          ),
                        )
                      : CustomImageView(
                          imageUrl: activeImage,
                          fit: BoxFit.contain,
                          placeholderIcon: Icons.shopping_bag_outlined,
                        ),
                ),
              ),

              // Status Badge Overlay
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    _product.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              // Primary Badge Overlay
              if (isSelectedPrimary && !isLoading)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3827),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Color(0xFFFFD700), size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Primary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Count Badge Overlay
              if (_images.isNotEmpty && !isLoading)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedIndex + 1}/${_images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Thumbnails List below main image
          if (_images.length > 1 && !isLoading) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (ctx, i) {
                  final img = _images[i];
                  final isSelected = i == _selectedIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = i;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : const Color(0xFFE4ECE8),
                          width: isSelected ? 2.5 : 1.0,
                        ),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomImageView(
                              imageUrl: img.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (img.isPrimary)
                            Positioned(
                              top: 3,
                              right: 3,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A3827),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFD700),
                                  size: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- SECTION CARD BUILDER MATCHING ADD/EDIT SCREEN ---
  Widget _buildSectionCard({
    required String step,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'STEP $step',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11261B),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EFEA)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4C6656)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B8A78),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EFEA)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B8A78)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B8A78)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? const Color(0xFF11261B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem({
    required IconData icon,
    required String title,
    required String value,
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.primaryGreen.withValues(alpha: 0.1) : const Color(0xFFEAEFEA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isHighlighted ? AppColors.primaryGreen : Colors.grey,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B8A78)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isHighlighted ? const Color(0xFF11261B) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF11261B),
          ),
        ),
      ],
    );
  }

  void _showVariantDetailsModal(BuildContext context, ProductVariantModel v) {
    final List<ProductImageModel> variantImages = v.images.where((img) => img.productVariantId == v.id).toList();
    if (variantImages.isEmpty && v.images.isNotEmpty) {
      variantImages.addAll(v.images);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        int selectedImgIdx = 0;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final activeImgUrl = variantImages.isNotEmpty
                ? variantImages[selectedImgIdx].imageUrl
                : null;

            final Map<String, String> displayAttrs = {};
            if (v.color != null && v.color!.trim().isNotEmpty) {
              displayAttrs['Color'] = v.color!.trim();
            }
            if (v.size != null && v.size!.trim().isNotEmpty) {
              displayAttrs['Size'] = v.size!.trim();
            }
            if (v.storage != null && v.storage!.trim().isNotEmpty) {
              displayAttrs['Storage'] = v.storage!.trim();
            }
            v.attributes.forEach((key, val) {
              if (val.trim().isNotEmpty && !displayAttrs.containsKey(key)) {
                displayAttrs[key] = val.trim();
              }
            });

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCE5DF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.variantName.isNotEmpty ? v.variantName : 'Variant Details',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'SKU: ${v.sku}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF7A9A86),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (v.isDefault)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFC8E6C9)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 13, color: AppColors.primaryGreen),
                                SizedBox(width: 4),
                                Text(
                                  'Default',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        IconButton(
                          onPressed: () => Navigator.pop(modalCtx),
                          icon: const Icon(Icons.close, color: Color(0xFF556960)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 16, color: Color(0xFFE8EFE9)),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 220,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6FAF7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE4ECE8)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: (activeImgUrl != null && activeImgUrl.isNotEmpty)
                                  ? CustomImageView(
                                      imageUrl: activeImgUrl,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: 220,
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.image_not_supported_outlined, size: 48, color: Color(0xFF9EAEA4)),
                                        SizedBox(height: 8),
                                        Text(
                                          'No variant image uploaded',
                                          style: TextStyle(fontSize: 13, color: Color(0xFF7A9A86)),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          if (variantImages.length > 1) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 60,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: variantImages.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 8),
                                itemBuilder: (_, imgIndex) {
                                  final isSelected = selectedImgIdx == imgIndex;
                                  return GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        selectedImgIdx = imgIndex;
                                      });
                                    },
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primaryGreen : const Color(0xFFE4ECE8),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CustomImageView(
                                          imageUrl: variantImages[imgIndex].imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Price',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7A9A86)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${v.price.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: (v.stock > 0 ? const Color(0xFF2E7D32) : AppColors.brandRed).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: (v.stock > 0 ? const Color(0xFF2E7D32) : AppColors.brandRed).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Stock Status',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7A9A86)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        v.stock > 0 ? '${v.stock} in stock' : 'Out of Stock',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: v.stock > 0 ? const Color(0xFF2E7D32) : AppColors.brandRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          if (displayAttrs.isNotEmpty) ...[
                            const Text(
                              'Attributes',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: displayAttrs.entries.map((entry) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F8F5),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE4ECE8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${entry.key}: ',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF556960),
                                        ),
                                      ),
                                      Text(
                                        entry.value,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF11261B),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                          ],

                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FBF9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE8EFE9)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Variant Status',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF556960), fontWeight: FontWeight.w500),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: v.status.toUpperCase() == 'ACTIVE'
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    v.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: v.status.toUpperCase() == 'ACTIVE'
                                          ? const Color(0xFF2E7D32)
                                          : AppColors.brandRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(modalCtx);
                            _confirmDeleteVariant(v);
                          },
                          icon: const Icon(Icons.delete_outline, color: AppColors.brandRed),
                          tooltip: 'Delete Variant',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(modalCtx);
                              _openEditVariantSheet(v);
                            },
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Edit Variant'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1A3827),
                              side: const BorderSide(color: Color(0xFF1A3827)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(modalCtx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3827),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openAddVariantSheet() {
    final existingSkus = _variants.map((v) => v.sku.toUpperCase()).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditVariantBottomSheet(
        availableAttributes: _effectiveAttributes,
        existingSkus: existingSkus,
        onSave: (newVariant) {
          context.read<ProductBloc>().add(
                CreateProductVariantEvent(
                  productId: _product.id,
                  data: newVariant.toCreateJson(),
                  pendingImagePaths: newVariant.pendingLocalPaths,
                ),
              );
        },
      ),
    );
  }

  void _openEditVariantSheet(ProductVariantModel v) {
    final existingSkus = _variants
        .where((x) => x.id != v.id)
        .map((x) => x.sku.toUpperCase())
        .toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditVariantBottomSheet(
        initialVariant: v,
        availableAttributes: _effectiveAttributes,
        existingSkus: existingSkus,
        onSave: (updatedVariant) {
          context.read<ProductBloc>().add(
                UpdateProductVariantEvent(
                  productId: _product.id,
                  variantId: updatedVariant.id,
                  data: updatedVariant.toCreateJson(),
                ),
              );
        },
      ),
    );
  }

  void _confirmDeleteVariant(ProductVariantModel v) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Variant'),
        content: Text('Are you sure you want to delete "${v.variantName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProductBloc>().add(
                    DeleteProductVariantEvent(
                      productId: _product.id,
                      variantId: v.id,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product? This action is irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<ProductBloc>().add(DeleteProductSubmittedEvent(id: _product.id));
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.brandRed)),
          ),
        ],
      ),
    );
  }
}
