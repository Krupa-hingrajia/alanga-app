import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_variant_model.dart';
import '../../data/models/product_image_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../../core/utils/category_cache.dart';
import '../../../wishlist/presentation/widgets/wishlist_button.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product_details_cubit.dart';
import '../../../reviews/presentation/widgets/product_reviews_section.dart';

import '../../domain/repositories/product_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../categories/data/models/category_model.dart';
import '../../data/models/brand_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductDetailsCubit _cubit;
  late final PageController _pageController;
  String _categoryName = '';
  String _brandName = '';
  int _selectedImageIndex = 0;

  // Pincode & Delivery Estimator
  final TextEditingController _pincodeController = TextEditingController(text: '395006');
  bool _isCheckingPincode = false;
  String? _verifiedPincode = '395006';
  bool _isDeliverable = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _cubit = ProductDetailsCubit(product: widget.product);
    _categoryName = widget.product.categoryName ?? '';
    _brandName = widget.product.brandName ?? '';
    _resolveMetadata();
    _cubit.fetchProductDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pincodeController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _openFullScreenImageViewer(BuildContext context, List<String> images, int initialIndex) {
    if (images.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          final pageController = PageController(initialPage: initialIndex);
          int currentIndex = initialIndex;

          return StatefulBuilder(
            builder: (context, setModalState) {
              return Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  centerTitle: true,
                  title: Text(
                    '${currentIndex + 1} of ${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                body: Stack(
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setModalState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: Center(
                            child: CustomImageView(
                              imageUrl: images[index],
                              fit: BoxFit.contain,
                              placeholderIcon: Icons.image_rounded,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Pinch to zoom',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _checkPincode() async {
    final code = _pincodeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit Pincode'),
          backgroundColor: AppColors.brandRed,
        ),
      );
      return;
    }
    setState(() => _isCheckingPincode = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _isCheckingPincode = false;
        _verifiedPincode = code;
        _isDeliverable = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delivery available at $code'),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _resolveMetadata() async {
    if (_categoryName.isNotEmpty && _brandName.isNotEmpty) return;
    try {
      final categoryRepo = sl<CategoryRepository>();
      final productRepo = sl<ProductRepository>();

      final results = await Future.wait([
        categoryRepo.getCategories(),
        productRepo.getBrands(),
      ]);

      final categories = results[0] as List<CategoryModel>;
      final brands = results[1] as List<BrandModel>;

      final matchedCat = categories.where((c) => c.id == widget.product.categoryId).firstOrNull;
      final matchedBrand = brands.where((b) => b.id == widget.product.brandId).firstOrNull;

      if (mounted) {
        setState(() {
          if (_categoryName.isEmpty) {
            _categoryName = matchedCat != null ? matchedCat.name : 'General';
          }
          if (_brandName.isEmpty) {
            _brandName = matchedBrand != null ? matchedBrand.name : 'Generic';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (_categoryName.isEmpty) _categoryName = 'General';
          if (_brandName.isEmpty) _brandName = 'Generic';
        });
      }
    }
  }

  Color? _mapColorNameToColor(String colorName) {
    final name = colorName.toLowerCase().trim();
    switch (name) {
      case 'black': return Colors.black;
      case 'blue': return Colors.blue;
      case 'white': return Colors.white;
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'orange': return Colors.orange;
      case 'pink': return Colors.pink;
      case 'purple': return Colors.purple;
      case 'grey':
      case 'gray': return Colors.grey;
      case 'brown': return Colors.brown;
      case 'cyan': return Colors.cyan;
      case 'amber': return Colors.amber;
      case 'indigo': return Colors.indigo;
      case 'teal': return Colors.teal;
      default: return null;
    }
  }

  void _onAttributeSelected(ProductModel product, ProductVariantModel? currentVariant, String attributeName, String attributeValue) {
    final tempAttributes = Map<String, String>.from(currentVariant?.attributes ?? {});
    tempAttributes[attributeName] = attributeValue;

    final matchedVariant = product.variants.firstWhere(
      (v) {
        for (final entry in tempAttributes.entries) {
          if (v.attributes[entry.key] != entry.value) {
            return false;
          }
        }
        return true;
      },
      orElse: () => product.variants.firstWhere(
        (v) => v.attributes[attributeName] == attributeValue,
        orElse: () => product.variants.firstWhere(
          (v) => v.variantName.toLowerCase().contains(attributeValue.toLowerCase()),
          orElse: () => currentVariant ?? product.variants.first,
        ),
      ),
    );

    _cubit.selectVariant(matchedVariant.id);
    setState(() {
      _selectedImageIndex = 0; // Reset image index on variant change!
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _onDirectVariantSelected(ProductVariantModel variant) {
    _cubit.selectVariant(variant.id);
    setState(() {
      _selectedImageIndex = 0; // Reset image index on variant change!
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  String _formatDeliveryDateRange(int minDays, int maxDays) {
    final now = DateTime.now();
    final minDate = now.add(Duration(days: minDays));
    final maxDate = now.add(Duration(days: maxDays));
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    if (minDays == maxDays) {
      return '${minDate.day} ${months[minDate.month - 1]}';
    }

    if (minDate.month == maxDate.month) {
      return '${minDate.day} ${months[minDate.month - 1]} - ${maxDate.day} ${months[maxDate.month - 1]}';
    }

    return '${minDate.day} ${months[minDate.month - 1]} - ${maxDate.day} ${months[maxDate.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          final product = state.product;
          final selectedVariantId = state.selectedVariantId;

          final selectedVariant = (selectedVariantId != null && product.variants.isNotEmpty)
              ? product.variants.firstWhere(
                  (v) => v.id == selectedVariantId,
                  orElse: () => product.defaultVariant ?? product.variants.first,
                )
              : null;

          final activeVariant = selectedVariant ?? product.defaultVariant ?? (product.variants.isNotEmpty ? product.variants.first : null);

          final currentPrice = activeVariant != null ? activeVariant.price : product.sellingPrice;
          final currentStock = activeVariant != null ? activeVariant.stock : (product.stock ?? 0);
          final currentSku = activeVariant != null ? activeVariant.sku : product.sku;

          final isOutOfStock = currentStock <= 0;
          final isLowStock = currentStock > 0 && currentStock <= 5;

          final stockStatusLabel = isOutOfStock
              ? 'Out of Stock'
              : (isLowStock ? 'Low Stock ($currentStock left)' : 'In Stock');

          final stockStatusColor = isOutOfStock
              ? AppColors.brandRed
              : (isLowStock ? AppColors.brandOrange : AppColors.primaryGreen);

          // Image Hierarchy (Amazon / Myntra style):
          // 1. Initial Load (selectedVariantId == null): Always display Product Primary & Common Images.
          // 2. Variant Selected (selectedVariantId != null): Display Variant Images if exist, else fallback to Product Common Images.
          List<ProductImageModel> sortedImages = [];
          if (selectedVariantId != null && selectedVariant != null) {
            if (selectedVariant.images.isNotEmpty) {
              sortedImages = List.from(selectedVariant.images);
            } else {
              final matchingImgs = product.images
                  .where((img) => img.productVariantId == selectedVariant.id)
                  .toList();
              if (matchingImgs.isNotEmpty) {
                sortedImages = matchingImgs;
              }
            }
          }

          if (sortedImages.isEmpty) {
            sortedImages = product.images
                .where((img) => img.productVariantId == null || img.productVariantId!.isEmpty)
                .toList();
            if (sortedImages.isEmpty) {
              sortedImages = List.from(product.images);
            }
          }

          if (sortedImages.isNotEmpty) {
            sortedImages.sort((a, b) {
              if (a.isPrimary && !b.isPrimary) return -1;
              if (!a.isPrimary && b.isPrimary) return 1;
              return a.displayOrder.compareTo(b.displayOrder);
            });
          }

          List<String> allImageUrls = [];
          if (sortedImages.isNotEmpty) {
            allImageUrls = sortedImages.map((i) => i.imageUrl).toList();
          } else if (product.primaryImageUrl.isNotEmpty) {
            allImageUrls = [product.primaryImageUrl];
          } else {
            final fallback = CategoryCache.getImageUrl(product.categoryId);
            allImageUrls = [fallback ?? ''];
          }

          final images = allImageUrls;
          final displayIndex = _selectedImageIndex.clamp(0, images.isNotEmpty ? images.length - 1 : 0);

          final discount = product.mrp > currentPrice
              ? (((product.mrp - currentPrice) / product.mrp) * 100).round()
              : 0;

          final Map<String, Set<String>> availableAttributeOptions = {};
          for (final v in product.variants) {
            v.attributes.forEach((key, val) {
              availableAttributeOptions.putIfAbsent(key, () => <String>{}).add(val);
            });
          }

          final hasVariants = product.variants.isNotEmpty;
          final shipping = product.shipping;
          final selectedAttributes = selectedVariant?.attributes ?? {};

          return Scaffold(
            backgroundColor: const Color(0xFFF6F8F6),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Product Details',
                style: TextStyle(
                  color: Color(0xFF11261B),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFF11261B)),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: WishlistButton(
                    key: ValueKey('${product.id}_${selectedVariant?.id ?? 'default'}'),
                    productId: product.id,
                    productVariantId: selectedVariant?.id ?? activeVariant?.id,
                    initialIsWishlisted: product.isWishlisted ?? false,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Color(0xFF11261B)),
                  onPressed: () {},
                ),
              ],
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Price Summary Column
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.mrp > currentPrice)
                          Text(
                            'MRP ₹${product.mrp.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Row(
                          children: [
                            Text(
                              '₹${currentPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF11261B),
                              ),
                            ),
                            if (discount > 0) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.brandRed.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$discount% OFF',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.brandRed,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Dual CTA Buttons (Add to Cart + Buy Now)
                    Expanded(
                      child: isOutOfStock
                          ? Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'OUT OF STOCK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                // 1. Add to Cart Button (Tinted Style)
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        final targetVariant = selectedVariant ?? activeVariant ?? product.defaultVariant ?? (product.variants.isNotEmpty ? product.variants.first : null);
                                        final targetVariantId = targetVariant?.id;

                                        if (targetVariantId == null || targetVariantId.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please select a product variant.'),
                                              backgroundColor: AppColors.brandRed,
                                            ),
                                          );
                                          return;
                                        }

                                        try {
                                          await context.read<CartCubit>().addToCart(
                                                productId: product.id,
                                                variantId: targetVariantId,
                                                quantity: 1,
                                              );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Row(
                                                  children: [
                                                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                                    SizedBox(width: 10),
                                                    Text('Added to Cart', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                                backgroundColor: AppColors.primaryGreen,
                                                duration: const Duration(seconds: 3),
                                                action: SnackBarAction(
                                                  label: 'VIEW CART',
                                                  textColor: Colors.amber,
                                                  onPressed: () => context.push('/cart'),
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          final errorMsg = e.toString().replaceAll('Exception: ', '');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(errorMsg),
                                                backgroundColor: AppColors.brandRed,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primaryGreen,
                                        backgroundColor: const Color(0xFFF0FDF4),
                                        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_shopping_cart_rounded, size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            'ADD TO CART',
                                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // 2. Buy Now Button (High Conversion Solid Button)
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final targetVariant = selectedVariant ?? activeVariant ?? product.defaultVariant ?? (product.variants.isNotEmpty ? product.variants.first : null);
                                        final targetVariantId = targetVariant?.id;

                                        if (targetVariantId == null || targetVariantId.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please select a product variant.'),
                                              backgroundColor: AppColors.brandRed,
                                            ),
                                          );
                                          return;
                                        }

                                        try {
                                          // Add to cart and navigate immediately to checkout
                                          await context.read<CartCubit>().addToCart(
                                                productId: product.id,
                                                variantId: targetVariantId,
                                                quantity: 1,
                                              );
                                          if (context.mounted) {
                                            context.push('/checkout');
                                          }
                                        } catch (e) {
                                          final errorMsg = e.toString().replaceAll('Exception: ', '');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(errorMsg),
                                                backgroundColor: AppColors.brandRed,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF143021),
                                        foregroundColor: Colors.white,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.bolt_rounded, size: 18, color: Color(0xFFFBBF24)),
                                          SizedBox(width: 2),
                                          Text(
                                            'BUY NOW',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Amazon / Myntra Style Image Gallery with Tap-To-Zoom & Dot Indicators
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _openFullScreenImageViewer(context, images, displayIndex),
                          child: Container(
                            height: 310,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFCFA),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE4ECE8)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: PageView.builder(
                                      controller: _pageController,
                                      itemCount: images.isNotEmpty ? images.length : 1,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _selectedImageIndex = index;
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        final imgUrl = images.isNotEmpty ? images[index] : '';
                                        return CustomImageView(
                                          imageUrl: imgUrl,
                                          placeholderIcon: Icons.shopping_bag_outlined,
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                                  ),
                                  if (discount > 0)
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [AppColors.brandRed, Color(0xFFFF5252)],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.brandRed.withValues(alpha: 0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '$discount% OFF',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Zoom Hint & Image Counter Badge
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                                          SizedBox(width: 4),
                                          Text(
                                            'Tap to zoom',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${images.isNotEmpty ? displayIndex + 1 : 0}/${images.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Animated Indicator Dots
                                  if (images.length > 1)
                                    Positioned(
                                      bottom: 12,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(images.length, (i) {
                                          final isCur = i == displayIndex;
                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 250),
                                            margin: const EdgeInsets.symmetric(horizontal: 3),
                                            width: isCur ? 18 : 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: isCur ? AppColors.primaryGreen : Colors.grey.shade400,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (images.length > 1) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 64,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (ctx, i) {
                                final isSelected = i == displayIndex;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImageIndex = i;
                                    });
                                    if (_pageController.hasClients) {
                                      _pageController.animateToPage(
                                        i,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 64,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primaryGreen : const Color(0xFFE4ECE8),
                                        width: isSelected ? 2.5 : 1.0,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CustomImageView(
                                        imageUrl: images[i],
                                        fit: BoxFit.cover,
                                        width: 64,
                                        height: 64,
                                      ),
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
                  const SizedBox(height: 12),

                  // 2. Product Information Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          if (_brandName.isNotEmpty) ...[
                            Text(
                              _brandName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7A9A86),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF11261B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: stockStatusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: stockStatusColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  stockStatusLabel,
                                  style: TextStyle(
                                    color: stockStatusColor,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E7),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFFE0B2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, color: Color(0xFFFF9800), size: 14),
                                    const SizedBox(width: 3),
                                    Text(
                                      product.averageRating > 0
                                          ? product.averageRating.toStringAsFixed(1)
                                          : 'New',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE65100),
                                      ),
                                    ),
                                    if (product.totalReviews > 0) ...[
                                      const SizedBox(width: 3),
                                      Text(
                                        '(${product.totalReviews})',
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (_categoryName.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F8F5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _categoryName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF5A7265),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE4ECE8), height: 1),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₹${currentPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (product.mrp > currentPrice) ...[
                                Text(
                                  'MRP ₹${product.mrp.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '($discount% OFF)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.brandRed,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Variant Selection Card (Hidden if variants are unavailable)
                  if (hasVariants) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Select Variant',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF11261B),
                                  ),
                                ),
                                if (selectedVariant != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F8F5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      selectedVariant.variantName,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            if (availableAttributeOptions.isNotEmpty) ...[
                              ...availableAttributeOptions.entries.map((attrEntry) {
                                final attrName = attrEntry.key;
                                final optionsList = attrEntry.value.toList();
                                final selectedValue = selectedAttributes[attrName];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '$attrName: ',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF5A7265),
                                            ),
                                          ),
                                          Text(
                                            selectedValue ?? 'Select $attrName',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: selectedValue != null ? const Color(0xFF11261B) : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (attrName.toLowerCase() == 'color') ...[
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 10,
                                          children: optionsList.map((optionVal) {
                                            final isSelected = selectedValue != null && selectedValue.toLowerCase() == optionVal.toLowerCase();
                                            final mappedColor = _mapColorNameToColor(optionVal);

                                            return GestureDetector(
                                              onTap: () => _onAttributeSelected(product, selectedVariant, attrName, optionVal),
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: mappedColor ?? const Color(0xFFE4ECE8),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: (mappedColor == Colors.white || mappedColor == null)
                                                          ? const Color(0xFFD4E2D9)
                                                          : Colors.transparent,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.05),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: isSelected
                                                        ? Icon(
                                                            Icons.check_rounded,
                                                            size: 16,
                                                            color: mappedColor == Colors.white ? Colors.black : Colors.white,
                                                          )
                                                        : (mappedColor == null
                                                            ? Text(
                                                                optionVal.substring(0, 1).toUpperCase(),
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Color(0xFF11261B),
                                                                ),
                                                              )
                                                            : null),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ] else if (attrName.toLowerCase() == 'size') ...[
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: optionsList.map((optionVal) {
                                            final isSelected = selectedValue != null && selectedValue.toLowerCase() == optionVal.toLowerCase();

                                            return GestureDetector(
                                              onTap: () => _onAttributeSelected(product, selectedVariant, attrName, optionVal),
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: isSelected ? AppColors.primaryGreen : Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: isSelected ? AppColors.primaryGreen : const Color(0xFFD4E2D9),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Text(
                                                  optionVal.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected ? Colors.white : const Color(0xFF11261B),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ] else ...[
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: optionsList.map((optionVal) {
                                            final isSelected = selectedValue != null && selectedValue.toLowerCase() == optionVal.toLowerCase();

                                            return ChoiceChip(
                                              label: Text(optionVal),
                                              selected: isSelected,
                                              selectedColor: AppColors.primaryGreen,
                                              backgroundColor: const Color(0xFFF4F8F5),
                                              labelStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                color: isSelected ? Colors.white : const Color(0xFF11261B),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(
                                                  color: isSelected ? AppColors.primaryGreen : const Color(0xFFD4E2D9),
                                                ),
                                              ),
                                              onSelected: (selected) {
                                                if (selected) {
                                                  _onAttributeSelected(product, selectedVariant, attrName, optionVal);
                                                }
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                            ] else ...[
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: product.variants.map((v) {
                                  final isSelected = selectedVariantId == v.id;

                                  return ChoiceChip(
                                    label: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v.variantName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : const Color(0xFF11261B),
                                          ),
                                        ),
                                        Text(
                                          '₹${v.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isSelected ? Colors.white70 : AppColors.primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                    selected: isSelected,
                                    selectedColor: AppColors.primaryGreen,
                                    backgroundColor: const Color(0xFFF4F8F5),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: isSelected ? AppColors.primaryGreen : const Color(0xFFD4E2D9),
                                      ),
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        _onDirectVariantSelected(v);
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 4. Shipping Information Card (Amazon / Flipkart / Myntra Style)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          const Row(
                            children: [
                              Icon(Icons.local_shipping_outlined, color: AppColors.primaryGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Delivery & Shipping Options',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Pincode Input Box (Amazon / Myntra Style)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FBFA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD4E2D9)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primaryGreen),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _pincodeController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF11261B),
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter 6-digit Pincode',
                                      hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey, fontWeight: FontWeight.normal),
                                      border: InputBorder.none,
                                      counterText: '',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                                _isCheckingPincode
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                                      )
                                    : TextButton(
                                        onPressed: _checkPincode,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Check',
                                          style: TextStyle(
                                            color: AppColors.primaryGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          if (shipping != null && _isDeliverable) ...[
                            // Estimated Delivery Date Range
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.bolt_rounded, color: Color(0xFF059669), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Delivery by ',
                                            style: TextStyle(fontSize: 13, color: Color(0xFF111827)),
                                          ),
                                          Text(
                                            _formatDeliveryDateRange(
                                              shipping.estimatedDeliveryMinDays,
                                              shipping.estimatedDeliveryMaxDays,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        (shipping.isFreeShipping || shipping.shippingCharge == 0)
                                            ? 'FREE Fast Delivery to ${_verifiedPincode ?? "your address"}'
                                            : 'Standard Shipping: ₹${shipping.shippingCharge.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: (shipping.isFreeShipping || shipping.shippingCharge == 0)
                                              ? const Color(0xFF047857)
                                              : Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Cash on Delivery Tag
                            Row(
                              children: [
                                Icon(
                                  shipping.codAvailable ? Icons.payments_outlined : Icons.money_off_rounded,
                                  color: shipping.codAvailable ? AppColors.primaryGreen : AppColors.brandRed,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  shipping.codAvailable ? 'Cash on Delivery is available' : 'Cash on Delivery is not available',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: shipping.codAvailable ? const Color(0xFF11261B) : AppColors.brandRed,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // 7 Days Replacement / Return Tag
                            const Row(
                              children: [
                                Icon(Icons.sync_rounded, color: AppColors.primaryGreen, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  '7 Days Easy Replacement / Return Policy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF11261B),
                                  ),
                                ),
                              ],
                            ),
                          ] else if (!_isDeliverable) ...[
                            Row(
                              children: [
                                const Icon(Icons.cancel_outlined, color: AppColors.brandRed, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Delivery is currently not available for ${_pincodeController.text}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.brandRed, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ] else ...[
                            // Standard fallback info
                            const Row(
                              children: [
                                Icon(Icons.verified_outlined, color: AppColors.primaryGreen, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Standard Shipping: Delivery in 3-5 business days',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF11261B)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. About this Item Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          const Row(
                            children: [
                              Icon(Icons.description_outlined, color: AppColors.primaryGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'About this Item',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            product.description ?? 'No description available for this product.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4C6656),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 6. Specifications Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          const Row(
                            children: [
                              Icon(Icons.settings_outlined, color: AppColors.primaryGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Specifications',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSpecificationRow('SKU Code', currentSku.isEmpty ? 'N/A' : currentSku),
                          _buildSpecificationRow('Stock Status', stockStatusLabel),
                          _buildSpecificationRow(
                            'Weight',
                            shipping != null && shipping.weight > 0
                                ? '${shipping.weight} ${shipping.weightUnit}'
                                : (product.weight != null ? '${product.weight} kg' : 'N/A'),
                          ),
                          _buildSpecificationRow(
                            'Dimensions (L x W x H)',
                            shipping != null && (shipping.length > 0 || shipping.width > 0 || shipping.height > 0)
                                ? '${shipping.length} x ${shipping.width} x ${shipping.height} ${shipping.dimensionUnit}'
                                : (product.length != null
                                    ? '${product.length} x ${product.width} x ${product.height} cm'
                                    : 'N/A'),
                          ),
                          _buildSpecificationRow(
                            'Tax Rate',
                            product.taxPercentage != null ? '${product.taxPercentage!.toStringAsFixed(0)}%' : 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 7. Trust & Buyer Protection Badges Card (Amazon / Myntra Style)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE4ECE8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTrustBadgeItem(
                            icon: Icons.verified_user_rounded,
                            iconColor: AppColors.primaryGreen,
                            title: '100% Genuine',
                            subtitle: 'Direct from sellers',
                          ),
                          Container(width: 1, height: 40, color: const Color(0xFFEEF3F0)),
                          _buildTrustBadgeItem(
                            icon: Icons.local_shipping_rounded,
                            iconColor: const Color(0xFF2563EB),
                            title: 'Fast Delivery',
                            subtitle: 'Free & insured',
                          ),
                          Container(width: 1, height: 40, color: const Color(0xFFEEF3F0)),
                          _buildTrustBadgeItem(
                            icon: Icons.replay_rounded,
                            iconColor: AppColors.brandOrange,
                            title: '7-Day Return',
                            subtitle: 'Easy replacements',
                          ),
                          Container(width: 1, height: 40, color: const Color(0xFFEEF3F0)),
                          _buildTrustBadgeItem(
                            icon: Icons.lock_outline_rounded,
                            iconColor: const Color(0xFF059669),
                            title: 'Safe Pay',
                            subtitle: 'Encrypted checkout',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 8. Customer Reviews Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ProductReviewsSection(
                      productId: product.id,
                      productName: product.name,
                      productImage: product.image ?? (product.images.isNotEmpty ? product.images.first.imageUrl : null),
                      onReviewSubmitted: () => _cubit.fetchProductDetails(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF7A9A86),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF11261B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadgeItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF11261B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 9.5,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
