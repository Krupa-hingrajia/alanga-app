import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_image_model.dart';
import '../../data/models/product_variant_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../sub_categories/domain/repositories/sub_category_repository.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<ProductImageModel> _images = [];
  List<ProductVariantModel> _variants = [];
  int _selectedIndex = 0;
  String? _categoryName;
  String? _subCategoryName;

  @override
  void initState() {
    super.initState();
    _categoryName = widget.product.categoryName;
    _subCategoryName = widget.product.subCategoryName;
    _fetchClassificationNames();
  }

  Future<void> _fetchClassificationNames() async {
    try {
      if (_categoryName == null && widget.product.categoryId.isNotEmpty) {
        final categoryRepo = sl<CategoryRepository>();
        final list = await categoryRepo.getCategories();
        final match = list.where((c) => c.id == widget.product.categoryId).firstOrNull;
        if (match != null && mounted) {
          setState(() {
            _categoryName = match.name;
          });
        }
      }
      if (_subCategoryName == null && widget.product.subCategoryId.isNotEmpty) {
        final subCategoryRepo = sl<SubCategoryRepository>();
        final list = await subCategoryRepo.getSubCategories(categoryId: widget.product.categoryId);
        final match = list.where((sc) => sc.id == widget.product.subCategoryId).firstOrNull;
        if (match != null && mounted) {
          setState(() {
            _subCategoryName = match.name;
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
        return Colors.blue;
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
    final statusColor = _getStatusColor(widget.product.status);
    final canEdit = widget.product.status.toUpperCase() == 'DRAFT' ||
        widget.product.status.toUpperCase() == 'PENDING' ||
        widget.product.status.toUpperCase() == 'REJECTED';
    final isDraft = widget.product.status.toUpperCase() == 'DRAFT';

    return BlocProvider(
      create: (_) => sl<ProductBloc>()
        ..add(FetchProductImagesEvent(productId: widget.product.id))
        ..add(FetchProductVariantsEvent(productId: widget.product.id)),
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
              onPressed: () {
                context.push('/products/inventory', extra: widget.product);
              },
            ),
            IconButton(
              icon: const Icon(Icons.local_shipping_outlined, color: Color(0xFF2563EB)),
              tooltip: 'Configure Shipping',
              onPressed: () {
                context.push('/products/shipping', extra: widget.product);
              },
            ),
            if (canEdit)
              Builder(
                builder: (blocContext) => IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.brandOrange),
                  onPressed: () async {
                    await context.push('/products/edit', extra: widget.product);
                    if (context.mounted) {
                      blocContext.read<ProductBloc>().add(FetchProductImagesEvent(productId: widget.product.id));
                      blocContext.read<ProductBloc>().add(FetchProductVariantsEvent(productId: widget.product.id));
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
              final sorted = List<ProductImageModel>.from(commonImages.isNotEmpty ? commonImages : state.images);
              sorted.sort((a, b) {
                if (a.isPrimary && !b.isPrimary) return -1;
                if (!a.isPrimary && b.isPrimary) return 1;
                return a.displayOrder.compareTo(b.displayOrder);
              });
              setState(() {
                _images = sorted;
                _selectedIndex = 0;
              });
            } else if (state is ProductVariantsLoadedState) {
              setState(() {
                _variants = state.variants.map((v) {
                  final variantImages = v.images.where((img) => img.productVariantId == v.id).toList();
                  return v.copyWith(images: variantImages);
                }).toList();
              });
            } else if (state is ProductActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.primaryGreen),
              );
              context.pop();
            } else if (state is ProductActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.brandRed),
              );
            }
          },
          builder: (context, state) {
            final activeImage = _images.isNotEmpty
                ? _images[_selectedIndex].imageUrl
                : widget.product.image;

            final bool isSelectedPrimary = _images.isNotEmpty
                ? _images[_selectedIndex].isPrimary
                : true;

            final isLoading = state is ProductImagesLoading && _images.isEmpty;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Product Images Gallery Header
                  Container(
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
                              height: 220,
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

                            // Primary Badge Overlay
                            if (isSelectedPrimary && !isLoading)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                      Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Primary Image',
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
                                    color: Colors.black.withValues(alpha: 0.6),
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

                        // Thumbnails List below main image (Horizontal gallery)
                        if (_images.length > 1 && !isLoading) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 64,
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
                                    width: 64,
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
                                            width: 64,
                                            height: 64,
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
                  ),
                  const SizedBox(height: 20),

                  // Basic Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4ECE8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 0.8),
                              ),
                              child: Text(
                                widget.product.status,
                                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SKU: ${widget.product.sku.isEmpty ? "N/A" : widget.product.sku}',
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.grey),
                        ),
                        if (widget.product.shortDescription != null && widget.product.shortDescription!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.product.shortDescription!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4C6656)),
                          ),
                        ],
                        if (widget.product.description != null && widget.product.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description!,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Classification Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4ECE8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Classification',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow('Category', _categoryName ?? 'Loading Category...'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Sub Category', _subCategoryName ?? 'Loading Sub Category...'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Variants Card (If any variants exist)
                  if (_variants.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE4ECE8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Available Variants',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_variants.length} Variants',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _variants.length,
                            separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFE8EFE9)),
                            itemBuilder: (ctx, i) {
                              final v = _variants[i];
                              final variantImages = v.images.where((img) => img.productVariantId == v.id).toList();
                              String? vImg;
                              if (variantImages.isNotEmpty) {
                                final primary = variantImages.firstWhere((img) => img.isPrimary, orElse: () => variantImages.first);
                                vImg = primary.imageUrl;
                              }

                              return Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F8F5),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE4ECE8)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(9),
                                      child: (vImg != null && vImg.isNotEmpty)
                                          ? CustomImageView(imageUrl: vImg, width: 40, height: 40, fit: BoxFit.cover)
                                          : const Icon(Icons.style_outlined, color: Color(0xFF1A3827), size: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v.variantName,
                                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'SKU: ${v.sku} | Stock: ${v.stock}',
                                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF7A9A86)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${v.price.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Pricing & Stock Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4ECE8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pricing & Stock',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Selling Price', '₹${widget.product.sellingPrice.toStringAsFixed(0)}', highlight: true),
                        const SizedBox(height: 12),
                        _buildDetailRow('Maximum Retail Price (MRP)', '₹${widget.product.mrp.toStringAsFixed(0)}'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Tax Rate', widget.product.taxPercentage != null ? '${widget.product.taxPercentage!.toStringAsFixed(0)}%' : 'N/A'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Available Stock', widget.product.stock != null ? '${widget.product.stock}' : 'N/A'),
                      ],
                    ),
                  ),
                  // Manage Variant Inventory Card Banner
                  GestureDetector(
                    onTap: () {
                      context.push('/products/inventory', extra: widget.product);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A3827), Color(0xFF2B543C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A3827).withValues(alpha: 0.15),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Manage Variant Inventory',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Update stock, thresholds & view audit history',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Configure Product Shipping Banner Card
                  GestureDetector(
                    onTap: () {
                      context.push('/products/shipping', extra: widget.product);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_shipping_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shipping Information',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Configure weight, dimensions, rates & COD',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Specifications Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4ECE8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Specifications',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Weight', widget.product.weight != null ? '${widget.product.weight} kg' : 'N/A'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Length', widget.product.length != null ? '${widget.product.length} cm' : 'N/A'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Width', widget.product.width != null ? '${widget.product.width} cm' : 'N/A'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Height', widget.product.height != null ? '${widget.product.height} cm' : 'N/A'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metadata Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4ECE8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Created Date', _formatDate(widget.product.createdAt)),
                        const SizedBox(height: 12),
                        _buildDetailRow('Last Updated', _formatDate(widget.product.updatedAt)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rejection reason
                  if (widget.product.status.toUpperCase() == 'REJECTED' &&
                      widget.product.rejectedReason != null &&
                      widget.product.rejectedReason!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.brandRed.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.report_problem_outlined, color: AppColors.brandRed, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Admin Rejection Reason',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.brandRed),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.rejectedReason!,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF11261B), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Bottom Action Buttons
                  if (state is ProductActionLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.brandOrange))
                  else ...[
                    if (isDraft)
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProductBloc>().add(SubmitProductForApprovalEvent(id: widget.product.id));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('SUBMIT FOR APPROVAL', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    if (canEdit) ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          _confirmDelete(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.brandRed),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('DELETE PRODUCT', style: TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.bold)),
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
              context.read<ProductBloc>().add(DeleteProductSubmittedEvent(id: widget.product.id));
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.brandRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 15 : 13,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
            color: highlight ? AppColors.primaryGreen : const Color(0xFF11261B),
          ),
        ),
      ],
    );
  }
}
