import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_image_model.dart';
import '../../data/models/product_variant_model.dart';
import '../../data/models/attribute_model.dart';
import '../widgets/product_images_section.dart';
import '../widgets/product_variants_section.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../core/widgets/searchable_dropdown_field.dart';
import '../../../brands/presentation/widgets/request_brand_bottom_sheet.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../brands/domain/repositories/brand_repository.dart';
import '../../../sub_categories/domain/repositories/sub_category_repository.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _shortDescController;
  late final TextEditingController _descController;
  late final TextEditingController _mrpController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _taxController;
  late final TextEditingController _weightController;
  late final TextEditingController _lengthController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  late final TextEditingController _stockController;

  bool get isEdit => widget.product != null;

  List<dynamic> _categories = [];
  List<dynamic> _subCategories = [];
  List<dynamic> _brands = [];

  String? _selectedCategoryId;
  String? _selectedSubCategoryId;
  String? _selectedBrandId;

  bool _loadingDropdowns = true;
  bool _loadingSubCategories = false;

  // Product Images State
  List<ProductImageModel> _uploadedImages = [];
  List<String> _pendingLocalPaths = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Product Variants State
  List<ProductVariantModel> _productVariants = [];
  List<AttributeModel> _availableAttributes = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _shortDescController = TextEditingController(text: widget.product?.shortDescription ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _mrpController = TextEditingController(text: widget.product?.mrp != null ? widget.product!.mrp.toStringAsFixed(0) : '');
    _sellingPriceController = TextEditingController(text: widget.product?.sellingPrice != null ? widget.product!.sellingPrice.toStringAsFixed(0) : '');
    _taxController = TextEditingController(text: widget.product?.taxPercentage != null ? widget.product!.taxPercentage!.toStringAsFixed(0) : '');
    _weightController = TextEditingController(text: widget.product?.weight != null ? widget.product!.weight.toString() : '');
    _lengthController = TextEditingController(text: widget.product?.length != null ? widget.product!.length.toString() : '');
    _widthController = TextEditingController(text: widget.product?.width != null ? widget.product!.width.toString() : '');
    _heightController = TextEditingController(text: widget.product?.height != null ? widget.product!.height.toString() : '');
    _stockController = TextEditingController(text: widget.product?.stock != null ? widget.product!.stock.toString() : '');

    _selectedCategoryId = widget.product?.categoryId;
    _selectedSubCategoryId = widget.product?.subCategoryId;
    _selectedBrandId = widget.product?.brandId;

    if (widget.product != null) {
      _uploadedImages = widget.product!.images
          .where((img) => img.productVariantId == null || img.productVariantId!.isEmpty)
          .toList();
      _productVariants = widget.product!.variants;
    }

    _loadDropdownData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _mrpController.dispose();
    _sellingPriceController.dispose();
    _taxController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    try {
      final categoryRepo = sl<CategoryRepository>();
      final brandRepo = sl<BrandRepository>();

      final results = await Future.wait([
        categoryRepo.getCategories(),
        brandRepo.getBrands(),
      ]);

      setState(() {
        _categories = results[0];
        _brands = results[1];
        _loadingDropdowns = false;
      });

      if (_selectedCategoryId != null) {
        _loadSubCategories(_selectedCategoryId!);
      }
    } catch (e) {
      setState(() {
        _loadingDropdowns = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load master metadata')),
      );
    }
  }

  Future<void> _loadSubCategories(String categoryId) async {
    setState(() {
      _loadingSubCategories = true;
      _subCategories = [];
    });
    try {
      final subCategoryRepo = sl<SubCategoryRepository>();
      final list = await subCategoryRepo.getSubCategories(categoryId: categoryId);
      setState(() {
        _subCategories = list;
        _loadingSubCategories = false;
      });
    } catch (e) {
      setState(() {
        _loadingSubCategories = false;
      });
    }
  }

  void _submitForm(BuildContext context, String targetStatus) {
    if (_isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for image upload to complete.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null || _selectedSubCategoryId == null || _selectedBrandId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Category, Sub Category, and Brand')),
        );
        return;
      }

      final double mrp = double.parse(_mrpController.text.trim());
      final double sellingPrice = double.parse(_sellingPriceController.text.trim());

      if (mrp <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MRP must be greater than zero')),
        );
        return;
      }

      if (sellingPrice > mrp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selling Price cannot exceed MRP')),
        );
        return;
      }

      final payload = {
        'name': _nameController.text.trim(),
        'shortDescription': _shortDescController.text.trim(),
        'description': _descController.text.trim(),
        'categoryId': _selectedCategoryId,
        'subCategoryId': _selectedSubCategoryId,
        'brandId': _selectedBrandId,
        'mrp': mrp,
        'sellingPrice': sellingPrice,
        'status': targetStatus,
        if (_taxController.text.isNotEmpty) 'taxPercentage': double.tryParse(_taxController.text.trim()),
        if (_stockController.text.isNotEmpty) 'stock': int.tryParse(_stockController.text.trim()),
        if (_weightController.text.isNotEmpty) 'weight': double.tryParse(_weightController.text.trim()),
        if (_lengthController.text.isNotEmpty) 'length': double.tryParse(_lengthController.text.trim()),
        if (_widthController.text.isNotEmpty) 'width': double.tryParse(_widthController.text.trim()),
        if (_heightController.text.isNotEmpty) 'height': double.tryParse(_heightController.text.trim()),
      };

      if (isEdit) {
        context.read<ProductBloc>().add(
              UpdateProductSubmittedEvent(
                id: widget.product!.id,
                data: payload,
                pendingImagePaths: _pendingLocalPaths,
              ),
            );
      } else {
        context.read<ProductBloc>().add(
              CreateProductSubmittedEvent(
                data: payload,
                pendingImagePaths: _pendingLocalPaths,
                variants: _productVariants,
              ),
            );
      }
    }
  }

  Widget _buildSectionCard({
    required String step,
    required String title,
    required IconData icon,
    required List<Widget> children,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EFEA)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, Color(0xFF2E6B48)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'STEP $step',
                            style: const TextStyle(
                              fontSize: 10.5,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11261B),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<ProductBloc>();
        bloc.add(const FetchAttributesEvent());
        return bloc;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F8F6),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
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
          title: Text(
            isEdit ? 'Edit Product' : 'Add New Product',
            style: const TextStyle(
              color: Color(0xFF11261B),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _loadingDropdowns
                    ? const DropdownSkeleton()
                    : BlocConsumer<ProductBloc, ProductState>(
                        listener: (context, state) {
                          if (state is AttributesLoadedState) {
                            setState(() {
                              _availableAttributes = state.attributes;
                            });
                          } else if (state is ProductImagesUploading) {
                            setState(() {
                              _isUploading = true;
                              _uploadProgress = state.progress;
                            });
                          } else if (state is ProductImageActionSuccess) {
                            setState(() {
                              _isUploading = false;
                              if (state.productVariantId == null || state.productVariantId!.isEmpty) {
                                _uploadedImages = state.images;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: AppColors.primaryGreen,
                              ),
                            );
                          } else if (state is ProductImageActionError) {
                            setState(() {
                              _isUploading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: AppColors.brandRed,
                              ),
                            );
                          } else if (state is ProductVariantsLoadedState) {
                            setState(() {
                              _productVariants = state.variants;
                            });
                          } else if (state is ProductVariantActionSuccess) {
                            setState(() {
                              _productVariants = state.variants;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message), backgroundColor: AppColors.primaryGreen),
                            );
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
                          final bool isSaveDisabled = _isUploading || state is ProductActionLoading;

                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // STEP 1: Product Classification (Category -> Sub Category -> Brand FIRST!)
                                  _buildSectionCard(
                                    step: '1',
                                    title: 'Product Classification',
                                    subtitle: 'Select category, sub category & marketplace brand',
                                    icon: Icons.grid_view_rounded,
                                    children: [
                                      SearchableDropdownField(
                                        label: 'Category *',
                                        value: _selectedCategoryId,
                                        items: _categories,
                                        placeholder: 'Select Category',
                                        emptyStateMessage: 'No Categories Available',
                                        loading: _loadingDropdowns,
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) {
                                            return 'Category is required';
                                          }
                                          return null;
                                        },
                                        onChanged: (id, name) {
                                          setState(() {
                                            _selectedCategoryId = id;
                                            _selectedSubCategoryId = null;
                                          });
                                          if (id != null) {
                                            _loadSubCategories(id);
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      SearchableDropdownField(
                                        label: 'Sub Category *',
                                        value: _selectedSubCategoryId,
                                        items: _subCategories,
                                        placeholder: _selectedCategoryId == null ? 'Select a Category first' : 'Select Sub Category',
                                        emptyStateMessage: _selectedCategoryId == null ? 'Please select a Category first' : 'No Sub Categories Available',
                                        loading: _loadingSubCategories,
                                        disabled: _selectedCategoryId == null,
                                        disabledHint: 'Select a Category first',
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) {
                                            return 'Sub Category is required';
                                          }
                                          return null;
                                        },
                                        onChanged: (id, name) {
                                          setState(() {
                                            _selectedSubCategoryId = id;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      SearchableDropdownField(
                                        label: 'Brand *',
                                        value: _selectedBrandId,
                                        items: _brands,
                                        placeholder: 'Select Brand',
                                        emptyStateMessage: 'No Brands Available',
                                        loading: _loadingDropdowns,
                                        onRequestBrand: () => RequestBrandBottomSheet.show(context),
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) {
                                            return 'Brand is required';
                                          }
                                          return null;
                                        },
                                        onChanged: (id, name) {
                                          setState(() {
                                            _selectedBrandId = id;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // STEP 2: Basic Info
                                  _buildSectionCard(
                                    step: '2',
                                    title: 'Basic Information',
                                    subtitle: 'Product name, summary and detailed description',
                                    icon: Icons.assignment_outlined,
                                    children: [
                                      TextFormField(
                                        controller: _nameController,
                                        decoration: _inputDecoration('Product Name *', Icons.shopping_bag_outlined),
                                        validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _shortDescController,
                                        decoration: _inputDecoration('Short Description', Icons.notes_outlined),
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _descController,
                                        maxLines: 3,
                                        decoration: _inputDecoration('Full Description', Icons.description_outlined),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // STEP 3: Pricing & Stock
                                  _buildSectionCard(
                                    step: '3',
                                    title: 'Pricing & Stock',
                                    subtitle: 'MRP, selling price, tax % and inventory',
                                    icon: Icons.sell_outlined,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _mrpController,
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              textInputAction: TextInputAction.next,
                                              decoration: _inputDecoration('MRP (₹) *', Icons.money),
                                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _sellingPriceController,
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              textInputAction: TextInputAction.next,
                                              decoration: _inputDecoration('Selling Price (₹) *', Icons.sell_outlined),
                                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _taxController,
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              textInputAction: TextInputAction.next,
                                              decoration: _inputDecoration('Tax %', Icons.percent_outlined),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _stockController,
                                              keyboardType: TextInputType.number,
                                              textInputAction: TextInputAction.done,
                                              onFieldSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                                              decoration: _inputDecoration('Initial Stock', Icons.storage_outlined),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // STEP 4: Product Media & Gallery
                                  ProductImagesSection(
                                    productId: widget.product?.id,
                                    uploadedImages: _uploadedImages,
                                    pendingLocalPaths: _pendingLocalPaths,
                                    isUploading: _isUploading,
                                    uploadProgress: _uploadProgress,
                                    onAddLocalImages: (newPaths) {
                                      setState(() {
                                        _pendingLocalPaths = [..._pendingLocalPaths, ...newPaths];
                                      });
                                    },
                                    onDeleteImage: (item) {
                                      if (item.isUploaded && item.id != null) {
                                        context.read<ProductBloc>().add(
                                              DeleteProductImageEvent(
                                                productId: widget.product!.id,
                                                imageId: item.id!,
                                              ),
                                            );
                                      } else if (item.localPath != null) {
                                        setState(() {
                                          _pendingLocalPaths = _pendingLocalPaths
                                              .where((p) => p != item.localPath)
                                              .toList();
                                        });
                                      }
                                    },
                                    onSetPrimary: (item) {
                                      if (item.isUploaded && item.id != null) {
                                        context.read<ProductBloc>().add(
                                              SetPrimaryProductImageEvent(
                                                productId: widget.product!.id,
                                                imageId: item.id!,
                                              ),
                                            );
                                      }
                                    },
                                    onReorderImages: (reorderedList) {},
                                  ),
                                  const SizedBox(height: 16),

                                  // STEP 5: Product Variants & Options
                                  ProductVariantsSection(
                                    productId: widget.product?.id,
                                    variants: _productVariants,
                                    availableAttributes: _availableAttributes,
                                    onAddVariant: (newVariant) {
                                      setState(() {
                                        if (newVariant.isDefault) {
                                          for (int i = 0; i < _productVariants.length; i++) {
                                            _productVariants[i] = _productVariants[i].copyWith(isDefault: false);
                                          }
                                        }
                                        _productVariants.add(newVariant);
                                      });
                                      if (isEdit) {
                                        context.read<ProductBloc>().add(
                                              CreateProductVariantEvent(
                                                productId: widget.product!.id,
                                                data: newVariant.toJson(),
                                                pendingImagePaths: newVariant.pendingLocalPaths,
                                              ),
                                            );
                                      }
                                    },
                                    onUpdateVariant: (updatedVariant) {
                                      final index = _productVariants.indexWhere((v) => v.id == updatedVariant.id || v.sku == updatedVariant.sku);
                                      if (index != -1) {
                                        setState(() {
                                          if (updatedVariant.isDefault) {
                                            for (int i = 0; i < _productVariants.length; i++) {
                                              _productVariants[i] = _productVariants[i].copyWith(isDefault: false);
                                            }
                                          }
                                          _productVariants[index] = updatedVariant;
                                        });
                                        if (isEdit && updatedVariant.id.isNotEmpty) {
                                          context.read<ProductBloc>().add(
                                                UpdateProductVariantEvent(
                                                  productId: widget.product!.id,
                                                  variantId: updatedVariant.id,
                                                  data: updatedVariant.toJson(),
                                                ),
                                              );
                                        }
                                      }
                                    },
                                    onDeleteVariant: (variantToDelete) {
                                      if (isEdit && variantToDelete.id.isNotEmpty) {
                                        context.read<ProductBloc>().add(
                                              DeleteProductVariantEvent(
                                                productId: widget.product!.id,
                                                variantId: variantToDelete.id,
                                              ),
                                            );
                                      } else {
                                        setState(() {
                                          _productVariants.removeWhere((v) => v.sku == variantToDelete.sku);
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // STEP 6: Shipping Information
                                  if (isEdit)
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(color: const Color(0xFFE6EFEA)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryGreen.withValues(alpha: 0.04),
                                            blurRadius: 18,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [AppColors.primaryGreen, Color(0xFF2E6B48)],
                                                  ),
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 20),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: const Text(
                                                        'STEP 6',
                                                        style: TextStyle(
                                                          fontSize: 10.5,
                                                          fontWeight: FontWeight.w800,
                                                          color: AppColors.primaryGreen,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    const Text(
                                                      'Shipping Information',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF11261B),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Configure product weight, dimensions, shipping rates, estimated delivery days, and Cash on Delivery availability.',
                                            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton.icon(
                                              onPressed: () {
                                                context.push('/products/shipping', extra: widget.product);
                                              },
                                              icon: const Icon(Icons.tune_rounded, size: 18),
                                              label: const Text('CONFIGURE SHIPPING INFORMATION'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(0xFF1A3827),
                                                side: const BorderSide(color: Color(0xFF1A3827), width: 1.2),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 28),

                                  // Action Buttons (Save Draft & Submit)
                                  if (isSaveDisabled)
                                    Shimmer.fromColors(
                                      baseColor: const Color(0xFFE4EDE7),
                                      highlightColor: const Color(0xFFF2F7F4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 52,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              height: 52,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _submitForm(context, 'DRAFT'),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              side: const BorderSide(color: Color(0xFF1A3827), width: 1.5),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            ),
                                            child: const Text(
                                              'Save Draft',
                                              style: TextStyle(
                                                color: Color(0xFF1A3827),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _submitForm(context, 'PENDING'),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              backgroundColor: const Color(0xFF1A3827),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                              elevation: 1,
                                              shadowColor: const Color(0xFF1A3827).withValues(alpha: 0.3),
                                            ),
                                            child: const Text(
                                              'Submit Product',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF5A7265), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF1A3827), size: 20),
      filled: true,
      fillColor: const Color(0xFFF4F8F5),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD4E2D9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD4E2D9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1A3827), width: 1.5),
      ),
    );
  }
}
