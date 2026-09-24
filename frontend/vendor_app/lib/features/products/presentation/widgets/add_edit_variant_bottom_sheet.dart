import 'package:flutter/material.dart';
import '../../data/models/product_variant_model.dart';
import '../../data/models/attribute_model.dart';
import '../../../../core/constants/app_colors.dart';

class AddEditVariantBottomSheet extends StatefulWidget {
  final ProductVariantModel? initialVariant;
  final List<AttributeModel> availableAttributes;
  final List<String> existingSkus;
  final Function(ProductVariantModel variant) onSave;

  const AddEditVariantBottomSheet({
    super.key,
    this.initialVariant,
    required this.availableAttributes,
    required this.existingSkus,
    required this.onSave,
  });

  @override
  State<AddEditVariantBottomSheet> createState() => _AddEditVariantBottomSheetState();
}

class _AddEditVariantBottomSheetState extends State<AddEditVariantBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _variantNameCtrl;
  late TextEditingController _skuCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;

  // List of dynamic attribute key-value pairs
  final List<MapEntry<String, String>> _attributePairs = [];
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final v = widget.initialVariant;

    _variantNameCtrl = TextEditingController(text: v?.variantName ?? '');
    _skuCtrl = TextEditingController(text: v?.sku ?? '');
    _priceCtrl = TextEditingController(text: v != null ? v.price.toStringAsFixed(0) : '');
    _stockCtrl = TextEditingController(text: v != null ? v.stock.toString() : '0');
    _isDefault = v?.isDefault ?? false;

    if (v != null && v.attributes.isNotEmpty) {
      v.attributes.forEach((key, value) {
        _attributePairs.add(MapEntry(key, value));
      });
    } else {
      // Initialize with 1 default attribute pair if available
      if (widget.availableAttributes.isNotEmpty) {
        final firstAttr = widget.availableAttributes.first;
        final firstVal = firstAttr.values.isNotEmpty ? firstAttr.values.first.value : '';
        _attributePairs.add(MapEntry(firstAttr.name, firstVal));
      } else {
        _attributePairs.add(const MapEntry('Color', 'Black'));
      }
      _autoGenerateVariantName();
    }
  }

  @override
  void dispose() {
    _variantNameCtrl.dispose();
    _skuCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _autoGenerateVariantName() {
    final values = _attributePairs
        .map((p) => p.value.trim())
        .where((val) => val.isNotEmpty)
        .toList();
    if (values.isNotEmpty) {
      _variantNameCtrl.text = values.join(' / ');
    }
  }

  void _addAttributePair() {
    String defaultKey = 'Attribute';
    String defaultVal = '';

    if (widget.availableAttributes.isNotEmpty) {
      final unusedAttr = widget.availableAttributes.firstWhere(
        (a) => !_attributePairs.any((p) => p.key.toLowerCase() == a.name.toLowerCase()),
        orElse: () => widget.availableAttributes.first,
      );
      defaultKey = unusedAttr.name;
      defaultVal = unusedAttr.values.isNotEmpty ? unusedAttr.values.first.value : '';
    }

    setState(() {
      _attributePairs.add(MapEntry(defaultKey, defaultVal));
      _autoGenerateVariantName();
    });
  }

  void _removeAttributePair(int index) {
    if (_attributePairs.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one attribute is required.')),
      );
      return;
    }
    setState(() {
      _attributePairs.removeAt(index);
      _autoGenerateVariantName();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_attributePairs.isEmpty || _attributePairs.every((p) => p.key.isEmpty || p.value.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one attribute is required.')),
      );
      return;
    }

    final sku = _skuCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;
    final variantName = _variantNameCtrl.text.trim();

    // Check SKU Uniqueness
    final isEditingSameSku = widget.initialVariant != null && widget.initialVariant!.sku == sku;
    if (!isEditingSameSku && widget.existingSkus.contains(sku.toUpperCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SKU "$sku" is already in use. Please enter a unique SKU.')),
      );
      return;
    }

    Map<String, String> attributesMap = {};
    for (final pair in _attributePairs) {
      if (pair.key.trim().isNotEmpty && pair.value.trim().isNotEmpty) {
        attributesMap[pair.key.trim()] = pair.value.trim();
      }
    }

    final updatedVariant = ProductVariantModel(
      id: widget.initialVariant?.id ?? '',
      productId: widget.initialVariant?.productId ?? '',
      sku: sku,
      variantName: variantName,
      price: price,
      stock: stock,
      color: attributesMap['Color'],
      size: attributesMap['Size'],
      storage: attributesMap['Storage'],
      attributes: attributesMap,
      isDefault: _isDefault,
    );

    widget.onSave(updatedVariant);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialVariant != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Modal Handle Bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4E2D9),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Product Variant' : 'Add Product Variant',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11261B),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dynamic Attributes Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attributes *',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11261B),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addAttributePair,
                      icon: const Icon(Icons.add, size: 16, color: Color(0xFF1A3827)),
                      label: const Text(
                        '+ Add another Attribute',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3827),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Dynamic Attribute Pairs List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _attributePairs.length,
                  itemBuilder: (ctx, i) {
                    final pair = _attributePairs[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE4ECE8)),
                      ),
                      child: Row(
                        children: [
                          // Attribute Name Selection (Dropdown or Input)
                          Expanded(
                            flex: 4,
                            child: widget.availableAttributes.isNotEmpty
                                ? DropdownButtonFormField<String>(
                                    value: widget.availableAttributes.any((a) => a.name.toLowerCase() == pair.key.toLowerCase())
                                        ? widget.availableAttributes.firstWhere((a) => a.name.toLowerCase() == pair.key.toLowerCase()).name
                                        : widget.availableAttributes.first.name,
                                    decoration: const InputDecoration(
                                      labelText: 'Attribute',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: widget.availableAttributes.map((attr) {
                                      return DropdownMenuItem<String>(
                                        value: attr.name,
                                        child: Text(attr.name, style: const TextStyle(fontSize: 13)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        final matchedAttr = widget.availableAttributes.firstWhere((a) => a.name == val);
                                        final defaultVal = matchedAttr.values.isNotEmpty ? matchedAttr.values.first.value : '';
                                        setState(() {
                                          _attributePairs[i] = MapEntry(val, defaultVal);
                                          _autoGenerateVariantName();
                                        });
                                      }
                                    },
                                  )
                                : TextFormField(
                                    initialValue: pair.key,
                                    decoration: const InputDecoration(
                                      labelText: 'Attribute Name',
                                      hintText: 'e.g. Color',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val) {
                                      _attributePairs[i] = MapEntry(val, pair.value);
                                      _autoGenerateVariantName();
                                    },
                                  ),
                          ),
                          const SizedBox(width: 8),

                          // Attribute Value Selection (Dropdown or Input)
                          Expanded(
                            flex: 5,
                            child: () {
                              final matchedAttr = widget.availableAttributes.firstWhere(
                                (a) => a.name.toLowerCase() == pair.key.toLowerCase(),
                                orElse: () => AttributeModel(id: '', name: '', status: '', values: []),
                              );
                              if (matchedAttr.values.isNotEmpty) {
                                return DropdownButtonFormField<String>(
                                  value: matchedAttr.values.any((v) => v.value.toLowerCase() == pair.value.toLowerCase())
                                      ? matchedAttr.values.firstWhere((v) => v.value.toLowerCase() == pair.value.toLowerCase()).value
                                      : matchedAttr.values.first.value,
                                  decoration: const InputDecoration(
                                    labelText: 'Value',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: matchedAttr.values.map((v) {
                                    return DropdownMenuItem<String>(
                                      value: v.value,
                                      child: Text(v.value, style: const TextStyle(fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _attributePairs[i] = MapEntry(pair.key, val);
                                        _autoGenerateVariantName();
                                      });
                                    }
                                  },
                                );
                              } else {
                                return TextFormField(
                                  initialValue: pair.value,
                                  decoration: const InputDecoration(
                                    labelText: 'Value',
                                    hintText: 'e.g. Black / 128 GB',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    _attributePairs[i] = MapEntry(pair.key, val);
                                    _autoGenerateVariantName();
                                  },
                                );
                              }
                            }(),
                          ),

                          // Delete Pair Button
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.brandRed, size: 20),
                            onPressed: () => _removeAttributePair(i),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Variant Name Field
                TextFormField(
                  controller: _variantNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Variant Name *',
                    hintText: 'e.g. Black / XL',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Variant name is required.' : null,
                ),
                const SizedBox(height: 12),

                // SKU Field
                TextFormField(
                  controller: _skuCtrl,
                  decoration: const InputDecoration(
                    labelText: 'SKU (Stock Keeping Unit) *',
                    hintText: 'e.g. TSHIRT-BLK-XL-001',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'SKU is required.' : null,
                ),
                const SizedBox(height: 12),

                // Price & Stock Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Price (₹) *',
                          hintText: '999',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Price required';
                          final numVal = double.tryParse(val.trim());
                          if (numVal == null || numVal <= 0) return 'Price > 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockCtrl,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: const InputDecoration(
                          labelText: 'Stock Quantity *',
                          hintText: '50',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Stock required';
                          final numVal = int.tryParse(val.trim());
                          if (numVal == null || numVal < 0) return 'Stock >= 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Default Variant Switch
                SwitchListTile(
                  title: const Text(
                    'Default Variant',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                    ),
                  ),
                  subtitle: const Text(
                    'Set this variant as the default variant for this product.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF5A7265)),
                  ),
                  value: _isDefault,
                  onChanged: (val) {
                    setState(() {
                      _isDefault = val;
                    });
                  },
                  activeColor: AppColors.primaryGreen,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),

                // Save Variant Button
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3827),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isEdit ? 'Save Changes' : 'Save Variant',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
