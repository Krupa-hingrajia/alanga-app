import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/sub_category_bloc.dart';
import '../bloc/sub_category_event.dart';
import '../bloc/sub_category_state.dart';
import '../../data/models/sub_category_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/widgets/image_picker_widget.dart';

class AddEditSubCategoryScreen extends StatefulWidget {
  final SubCategoryModel? subCategory;

  const AddEditSubCategoryScreen({super.key, this.subCategory});

  @override
  State<AddEditSubCategoryScreen> createState() => _AddEditSubCategoryScreenState();
}

class _AddEditSubCategoryScreenState extends State<AddEditSubCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;

  bool get isEdit => widget.subCategory != null;

  List<dynamic> _approvedCategories = [];
  bool _loadingCategories = true;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subCategory?.name ?? '');
    _descriptionController = TextEditingController(text: widget.subCategory?.description ?? '');
    _imageController = TextEditingController(text: widget.subCategory?.image ?? '');
    _selectedCategoryId = widget.subCategory?.categoryId;

    _loadApprovedCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _loadApprovedCategories() async {
    try {
      final response = await sl<ApiService>().get('/vendor/categories');
      final list = response.data['data'] as List<dynamic>;

      // Filter: Only ACTIVE / APPROVED categories belonging to the vendor
      final filteredList = list.where((item) {
        final status = (item['status'] as String).toUpperCase();
        return status == 'ACTIVE' || status == 'APPROVED';
      }).toList();

      setState(() {
        _approvedCategories = filteredList;
        _loadingCategories = false;
      });
    } catch (_) {
      setState(() {
        _loadingCategories = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load categories list')),
        );
      }
    }
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a parent Category')),
        );
        return;
      }

      if (isEdit) {
        context.read<SubCategoryBloc>().add(
              UpdateSubCategorySubmittedEvent(
                id: widget.subCategory!.id,
                categoryId: _selectedCategoryId!,
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                image: _imageController.text.trim(),
              ),
            );
      } else {
        context.read<SubCategoryBloc>().add(
              CreateSubCategorySubmittedEvent(
                categoryId: _selectedCategoryId!,
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                image: _imageController.text.trim(),
              ),
            );
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4C6656),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop(); // Dismiss Dialog
                    context.pop(); // Pop AddEditSubCategoryScreen back to list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SubCategoryBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            isEdit ? 'Edit Sub Category' : 'Add Sub Category',
            style: const TextStyle(
              color: Color(0xFF11261B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF11261B)),
        ),
        body: _loadingCategories
            ? const Center(child: CircularProgressIndicator(color: AppColors.brandOrange))
            : BlocConsumer<SubCategoryBloc, SubCategoryState>(
                listener: (context, state) {
                  if (state is SubCategoryActionSuccess) {
                    _showSuccessDialog(context, state.message);
                  } else if (state is SubCategoryActionError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.brandRed,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Sub Category Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF11261B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Select a parent Category and define the Sub Category details. All submissions will require Admin review.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Parent Category Selection Dropdown
                          DropdownButtonFormField<String>(
                            value: _approvedCategories.any((cat) => cat['id'] == _selectedCategoryId)
                                ? _selectedCategoryId
                                : null,
                            decoration: _inputDecoration('Parent Category *', Icons.list),
                            hint: const Text('Select parent category', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondaryLight),
                            items: _approvedCategories.map<DropdownMenuItem<String>>((item) {
                              return DropdownMenuItem<String>(
                                value: item['id'] as String,
                                child: Text(
                                  item['name'] as String,
                                  style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCategoryId = val;
                              });
                            },
                            validator: (val) => val == null ? 'Please select a Category' : null,
                          ),
                          const SizedBox(height: 20),

                          // Sub Category Name Field
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
                            decoration: _inputDecoration('Sub Category Name *', Icons.folder_copy_outlined),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter subcategory name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Description Field
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
                            decoration: _inputDecoration('Description', Icons.description_outlined),
                          ),
                          const SizedBox(height: 20),

                           // Image Picker
                           ImagePickerWidget(
                             initialValue: widget.subCategory?.image,
                             label: 'Sub Category Image',
                             onImageChanged: (val) {
                               _imageController.text = val;
                             },
                           ),
                           const SizedBox(height: 32),

                          // Submit Button
                          ElevatedButton(
                            onPressed: state is SubCategoryActionLoading ? null : () => _submitForm(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.brandOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: state is SubCategoryActionLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isEdit ? 'RESUBMIT FOR APPROVAL' : 'SUBMIT FOR APPROVAL',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
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
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.textSecondaryLight, size: 20),
      filled: true,
      fillColor: const Color(0xFFFFF9F2),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF9DCC4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF9DCC4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brandOrange, width: 1.5),
      ),
    );
  }
}
