import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/sub_category_bloc.dart';
import '../bloc/sub_category_event.dart';
import '../bloc/sub_category_state.dart';
import '../widgets/sub_category_card.dart';
import '../../data/models/sub_category_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/widgets/delete_confirmation_dialog.dart';
import '../../../categories/domain/repositories/category_repository.dart';

class SubCategoryListScreen extends StatefulWidget {
  const SubCategoryListScreen({super.key});

  @override
  State<SubCategoryListScreen> createState() => _SubCategoryListScreenState();
}

class _SubCategoryListScreenState extends State<SubCategoryListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All';

  Map<String, String> _categoryNameMap = {};
  bool _loadingCategories = true;
  List<SubCategoryModel> _cachedSubCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categoryRepo = sl<CategoryRepository>();
      final list = await categoryRepo.getCategories();
      final Map<String, String> tempMap = {};
      for (final item in list) {
        tempMap[item.id] = item.name;
      }
      setState(() {
        _categoryNameMap = tempMap;
        _loadingCategories = false;
      });
    } catch (_) {
      setState(() {
        _loadingCategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SubCategoryBloc>()..add(const FetchSubCategoriesEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6F4),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Sub Categories',
            style: TextStyle(
              color: Color(0xFF11261B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF11261B)),
        ),
        floatingActionButton: null,
        body: _loadingCategories
            ? const Center(child: CircularProgressIndicator(color: AppColors.brandOrange))
            : BlocConsumer<SubCategoryBloc, SubCategoryState>(
                listener: (context, state) {
                  if (state is SubCategoryDeleteSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.read<SubCategoryBloc>().add(const FetchSubCategoriesEvent(isRefresh: true));
                  } else if (state is SubCategoryActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.read<SubCategoryBloc>().add(const FetchSubCategoriesEvent(isRefresh: true));
                  } else if (state is SubCategoryActionError) {
                    showValidationErrorDialog(
                      context: context,
                      title: 'Delete Sub Category',
                      message: state.message,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is SubCategoryListLoading && _cachedSubCategories.isEmpty) {
                    return _buildSkeletonLoader();
                  } else if (state is SubCategoryListError && _cachedSubCategories.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.brandRed, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF11261B)),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<SubCategoryBloc>().add(const FetchSubCategoriesEvent());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is SubCategoryListLoaded) {
                    _cachedSubCategories = state.subCategories;
                  }

                  final isActionLoading = state is SubCategoryActionLoading;

                  final filteredList = _cachedSubCategories.where((s) {
                    final catName = _categoryNameMap[s.categoryId] ?? 'N/A';
                    final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        catName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        (s.description ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesStatus = _selectedStatus == 'All' ||
                        s.status.toUpperCase() == _selectedStatus.toUpperCase();
                    return matchesSearch && matchesStatus;
                  }).toList();

                  return Stack(
                    children: [
                      AbsorbPointer(
                        absorbing: isActionLoading,
                        child: RefreshIndicator(
                          color: AppColors.brandOrange,
                          backgroundColor: Colors.white,
                          onRefresh: () async {
                            context.read<SubCategoryBloc>().add(const FetchSubCategoriesEvent(isRefresh: true));
                          },
                          child: Column(
                            children: [
                              if (isActionLoading)
                                const LinearProgressIndicator(
                                  color: AppColors.brandOrange,
                                  backgroundColor: Color(0xFFFFF3E0),
                                ),
                              _buildSearchBar(context),
                              _buildFilterRow(),
                              Expanded(
                                child: filteredList.isEmpty
                                    ? _buildEmptyState()
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        itemCount: filteredList.length,
                                        itemBuilder: (context, index) {
                                          final subCategory = filteredList[index];
                                          final catName = _categoryNameMap[subCategory.categoryId] ?? 'Category';
                                          return SubCategoryCard(
                                            subCategory: subCategory,
                                            categoryName: catName,
                                            onTap: () => context.push('/subcategories/details', extra: {
                                              'subCategory': subCategory,
                                              'categoryName': catName,
                                            }),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search subcategories...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF3F6F4),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    final statuses = ['All', 'PENDING', 'ACTIVE', 'REJECTED'];
    return Container(
      color: Colors.white,
      height: 48,
      padding: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final s = statuses[index];
          final isSelected = _selectedStatus == s;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                s == 'ACTIVE' ? 'APPROVED' : s,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF4C6656),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedStatus = s;
                  });
                }
              },
              selectedColor: AppColors.brandOrange,
              backgroundColor: const Color(0xFFF3F6F4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_copy,
            size: 64,
            color: Color(0xFFD1DDD6),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Sub Categories Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty || _selectedStatus != 'All'
                ? 'Try adjusting your search filters'
                : 'Click "Add Sub Category" to submit your first subcategory',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4C6656),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE4ECE8)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        color: Colors.grey[200],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
