import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_variant_model.dart';
import '../../data/models/product_image_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../../core/utils/category_cache.dart';
import '../../../wishlist/presentation/widgets/wishlist_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductModel _product;
  String _categoryName = '';
  String _brandName = '';

  int _selectedImageIndex = 0;
  List<ProductImageModel> _sortedImages = [];

  ProductVariantModel? _selectedVariant;
  final Map<String, String> _selectedAttributes = {};

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _categoryName = _product.categoryName ?? '';
    _brandName = _product.brandName ?? '';
    _setupVariants();
    _setupImages();
    _resolveMetadata();
    _fetchFullProductDetails();
  }

  Future<void> _fetchFullProductDetails() async {
    try {
      final response = await sl<ApiService>().get('/customer/products/${widget.product.id}');
      if (response.data != null && response.data['data'] != null) {
        final fetched = ProductModel.fromJson(response.data['data'] as Map<String, dynamic>);
        if (mounted) {
          setState(() {
            _product = fetched;
            _categoryName = fetched.categoryName ?? _categoryName;
            _brandName = fetched.brandName ?? _brandName;
            if (_selectedVariant != null) {
              final matched = fetched.variants.firstWhere(
                (v) => v.id == _selectedVariant!.id || v.sku == _selectedVariant!.sku,
                orElse: () => fetched.variants.isNotEmpty ? fetched.variants.first : _selectedVariant!,
              );
              _selectedVariant = matched;
            } else if (fetched.variants.isNotEmpty) {
              _selectedVariant = fetched.variants.first;
            }
            _setupVariants();
            _setupImages();
          });
        }
      }
    } catch (_) {}
  }

  void _setupImages() {
    List<ProductImageModel> sourceList = [];

    if (_selectedVariant != null) {
      final directImgs = _selectedVariant!.images
          .where((img) => img.productVariantId == _selectedVariant!.id)
          .toList();
      if (directImgs.isNotEmpty) {
        sourceList = directImgs;
      } else {
        final matchingImgs = _product.images
            .where((img) => img.productVariantId == _selectedVariant!.id)
            .toList();
        if (matchingImgs.isNotEmpty) {
          sourceList = matchingImgs;
        }
      }
    }

    if (sourceList.isEmpty) {
      sourceList = _product.images
          .where((img) => img.productVariantId == null || img.productVariantId!.isEmpty)
          .toList();
      if (sourceList.isEmpty) {
        sourceList = List.from(_product.images);
      }
    }

    if (sourceList.isNotEmpty) {
      final list = List<ProductImageModel>.from(sourceList);
      list.sort((a, b) {
        if (a.isPrimary && !b.isPrimary) return -1;
        if (!a.isPrimary && b.isPrimary) return 1;
        return a.displayOrder.compareTo(b.displayOrder);
      });
      _sortedImages = list;
      _selectedImageIndex = 0;
    } else {
      _sortedImages = [];
      _selectedImageIndex = 0;
    }
  }

  void _setupVariants() {
    if (_product.variants.isNotEmpty && _selectedVariant == null) {
      _selectedVariant = _product.variants.first;
      _selectedAttributes.clear();
      _selectedVariant!.attributes.forEach((key, val) {
        _selectedAttributes[key] = val;
      });
      _setupImages();
    }
  }

  Future<void> _resolveMetadata() async {
    if (_categoryName.isNotEmpty && _brandName.isNotEmpty) return;
    try {
      final responses = await Future.wait([
        sl<ApiService>().get('/customer/categories'),
        sl<ApiService>().get('/customer/brands'),
      ]);

      final categories = responses[0].data['data'] as List<dynamic>;
      final brands = responses[1].data['data'] as List<dynamic>;

      final matchedCat = categories.firstWhere((c) => c['id'] == widget.product.categoryId, orElse: () => null);
      final matchedBrand = brands.firstWhere((b) => b['id'] == widget.product.brandId, orElse: () => null);

      if (mounted) {
        setState(() {
          if (_categoryName.isEmpty) {
            _categoryName = matchedCat != null ? matchedCat['name'] as String : 'General';
          }
          if (_brandName.isEmpty) {
            _brandName = matchedBrand != null ? matchedBrand['name'] as String : 'Generic';
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

  void _onAttributeSelected(String attributeName, String attributeValue) {
    setState(() {
      _selectedAttributes[attributeName] = attributeValue;

      final matchedVariant = widget.product.variants.firstWhere(
        (v) {
          for (final entry in _selectedAttributes.entries) {
            if (v.attributes[entry.key] != entry.value) {
              return false;
            }
          }
          return true;
        },
        orElse: () => widget.product.variants.firstWhere(
          (v) => v.attributes[attributeName] == attributeValue,
          orElse: () => widget.product.variants.firstWhere(
            (v) => v.variantName.toLowerCase().contains(attributeValue.toLowerCase()),
            orElse: () => _selectedVariant!,
          ),
        ),
      );

      _selectedVariant = matchedVariant;
      _setupImages();
    });
  }

  void _onDirectVariantSelected(ProductVariantModel variant) {
    setState(() {
      _selectedVariant = variant;
      _selectedAttributes.clear();
      variant.attributes.forEach((key, val) {
        _selectedAttributes[key] = val;
      });
      _setupImages();
    });
  }

  // Dynamic state getters
  double get _currentPrice => _selectedVariant != null ? _selectedVariant!.price : _product.sellingPrice;
  int get _currentStock => _selectedVariant != null ? _selectedVariant!.stock : (_product.stock ?? 0);
  String get _currentSku => _selectedVariant != null ? _selectedVariant!.sku : _product.sku;

  bool get _isOutOfStock => _currentStock <= 0;
  bool get _isLowStock => _currentStock > 0 && _currentStock <= 5;

  String get _stockStatusLabel {
    if (_isOutOfStock) return 'Out of Stock';
    if (_isLowStock) return 'Low Stock ($_currentStock left)';
    return 'In Stock';
  }

  Color get _stockStatusColor {
    if (_isOutOfStock) return AppColors.brandRed;
    if (_isLowStock) return AppColors.brandOrange;
    return AppColors.primaryGreen;
  }

  List<String> get _allImageUrls {
    if (_sortedImages.isNotEmpty) {
      return _sortedImages.map((i) => i.imageUrl).toList();
    }
    if (_product.primaryImageUrl.isNotEmpty) {
      return [_product.primaryImageUrl];
    }
    final fallback = CategoryCache.getImageUrl(_product.categoryId);
    return [fallback ?? ''];
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
    final images = _allImageUrls;
    final activeImage = images.isNotEmpty ? images[_selectedImageIndex.clamp(0, images.length - 1)] : '';

    final discount = _product.mrp > _currentPrice
        ? (((_product.mrp - _currentPrice) / _product.mrp) * 100).round()
        : 0;

    final Map<String, Set<String>> availableAttributeOptions = {};
    for (final v in _product.variants) {
      v.attributes.forEach((key, val) {
        availableAttributeOptions.putIfAbsent(key, () => <String>{}).add(val);
      });
    }

    final hasVariants = _product.variants.isNotEmpty;
    final shipping = _product.shipping;

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
              key: ValueKey('${_product.id}_${_selectedVariant?.id}'),
              productId: _product.id,
              productVariantId: _selectedVariant?.id,
              initialIsWishlisted: _product.isWishlisted ?? false,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF11261B)),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Price',
                      style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '₹${_currentPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isOutOfStock
                      ? null
                      : () {
                          final variantNameInfo = _selectedVariant != null ? ' (${_selectedVariant!.variantName})' : '';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${widget.product.name}$variantNameInfo to cart!'),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOutOfStock ? Colors.grey : const Color(0xFF1A3827),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE4ECE8),
                    disabledForegroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _isOutOfStock ? 'OUT OF STOCK' : 'ADD TO CART',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
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
            // 1. Image Preview Gallery (Primary Image First)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 270,
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
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeIn,
                              switchOutCurve: Curves.easeOut,
                              child: KeyedSubtree(
                                key: ValueKey(activeImage),
                                child: CustomImageView(
                                  imageUrl: activeImage,
                                  placeholderIcon: Icons.shopping_bag_outlined,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          if (discount > 0)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.brandRed,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$discount% OFF',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                          final isSelected = i == _selectedImageIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImageIndex = i;
                              });
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
                            widget.product.name,
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
                            color: _stockStatusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _stockStatusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _stockStatusLabel,
                            style: TextStyle(
                              color: _stockStatusColor,
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded, color: Color(0xFFFF9800), size: 14),
                              SizedBox(width: 3),
                              Text(
                                '4.5',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                              SizedBox(width: 3),
                              Text(
                                '(128)',
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
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
                          '₹${_currentPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.product.mrp > _currentPrice) ...[
                          Text(
                            'MRP ₹${widget.product.mrp.toStringAsFixed(0)}',
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
                          if (_selectedVariant != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F8F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _selectedVariant!.variantName,
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
                          final selectedValue = _selectedAttributes[attrName] ?? optionsList.first;

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
                                      selectedValue,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF11261B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: optionsList.map((optionVal) {
                                    final isSelected = selectedValue.toLowerCase() == optionVal.toLowerCase();

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
                                          _onAttributeSelected(attrName, optionVal);
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        }),
                      ] else ...[
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: widget.product.variants.map((v) {
                            final isSelected = _selectedVariant?.id == v.id;

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
                          'Delivery & Shipping',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (shipping != null) ...[
                      // Free Delivery vs Standard Shipping
                      Row(
                        children: [
                          Icon(
                            (shipping.isFreeShipping || shipping.shippingCharge == 0)
                                ? Icons.verified_rounded
                                : Icons.local_shipping_outlined,
                            color: (shipping.isFreeShipping || shipping.shippingCharge == 0)
                                ? AppColors.primaryGreen
                                : const Color(0xFF1F2937),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (shipping.isFreeShipping || shipping.shippingCharge == 0)
                                      ? 'FREE Delivery'
                                      : 'Shipping Charge: ₹${shipping.shippingCharge.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: (shipping.isFreeShipping || shipping.shippingCharge == 0)
                                        ? AppColors.primaryGreen
                                        : const Color(0xFF111827),
                                  ),
                                ),
                                if (shipping.isFreeShipping &&
                                    shipping.freeShippingAboveAmount != null &&
                                    shipping.freeShippingAboveAmount! > 0)
                                  Text(
                                    'Free delivery on orders above ₹${shipping.freeShippingAboveAmount!.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Estimated Delivery Date Range
                      Row(
                        children: [
                          const Icon(Icons.event_available_rounded, color: Color(0xFF2563EB), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Delivery in ',
                            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                          ),
                          Text(
                            _formatDeliveryDateRange(
                              shipping.estimatedDeliveryMinDays,
                              shipping.estimatedDeliveryMaxDays,
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            ' (${shipping.estimatedDeliveryMinDays}-${shipping.estimatedDeliveryMaxDays} Days)',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Cash on Delivery Tag
                      Row(
                        children: [
                          Icon(
                            shipping.codAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: shipping.codAvailable ? AppColors.primaryGreen : AppColors.brandRed,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            shipping.codAvailable ? 'Cash on Delivery Available' : 'Cash on Delivery Not Available',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: shipping.codAvailable ? AppColors.primaryGreen : AppColors.brandRed,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Empty state when shipping info is unavailable
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.grey.shade400, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Shipping information is not available.',
                            style: TextStyle(fontSize: 12.5, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 5. Product Description Card
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
                    const Text(
                      'Product Description',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11261B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.product.shortDescription != null && widget.product.shortDescription!.isNotEmpty) ...[
                      Text(
                        widget.product.shortDescription!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4C6656),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      widget.product.description ?? 'No description provided for this product.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 6. Product Specifications Card
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
                    const Text(
                      'Specifications',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11261B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSpecificationRow('SKU Code', _currentSku.isEmpty ? 'N/A' : _currentSku),
                    _buildSpecificationRow('Stock Status', _stockStatusLabel),
                    _buildSpecificationRow(
                      'Weight',
                      shipping != null && shipping.weight > 0
                          ? '${shipping.weight} ${shipping.weightUnit}'
                          : (widget.product.weight != null ? '${widget.product.weight} kg' : 'N/A'),
                    ),
                    _buildSpecificationRow(
                      'Dimensions (L x W x H)',
                      shipping != null && (shipping.length > 0 || shipping.width > 0 || shipping.height > 0)
                          ? '${shipping.length} x ${shipping.width} x ${shipping.height} ${shipping.dimensionUnit}'
                          : (widget.product.length != null
                              ? '${widget.product.length} x ${widget.product.width} x ${widget.product.height} cm'
                              : 'N/A'),
                    ),
                    _buildSpecificationRow(
                      'Tax Rate',
                      widget.product.taxPercentage != null ? '${widget.product.taxPercentage!.toStringAsFixed(0)}%' : 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
}
