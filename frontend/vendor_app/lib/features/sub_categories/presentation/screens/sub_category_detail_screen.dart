import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/sub_category_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';

class SubCategoryDetailScreen extends StatelessWidget {
  final SubCategoryModel subCategory;
  final String categoryName;

  const SubCategoryDetailScreen({
    super.key,
    required this.subCategory,
    required this.categoryName,
  });

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'APPROVED':
        return AppColors.primaryGreen;
      case 'PENDING':
        return AppColors.brandOrange;
      case 'REJECTED':
        return AppColors.brandRed;
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
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(subCategory.status);
    final canEdit = subCategory.status.toUpperCase() == 'PENDING' ||
        subCategory.status.toUpperCase() == 'REJECTED';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Sub Category Details',
          style: TextStyle(
            color: Color(0xFF11261B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF11261B)),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.brandOrange),
              onPressed: () {
                context.push('/subcategories/edit', extra: subCategory);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Header
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4ECE8)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomImageView(
                  imageUrl: subCategory.image,
                  fit: BoxFit.cover,
                  placeholderIcon: Icons.folder_copy_outlined,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Details Card
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
                          subCategory.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          subCategory.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Parent Category: $categoryName',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE4ECE8), height: 1),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subCategory.description ?? 'No description provided.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                      height: 1.4,
                    ),
                  ),
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
                  _buildMetaRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Created Date',
                    value: _formatDate(subCategory.createdAt),
                  ),
                  const SizedBox(height: 12),
                  _buildMetaRow(
                    icon: Icons.update_outlined,
                    label: 'Last Updated',
                    value: _formatDate(subCategory.updatedAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rejection reason if rejected
            if (subCategory.status.toUpperCase() == 'REJECTED' &&
                subCategory.rejectedReason != null &&
                subCategory.rejectedReason!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.brandRed.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.brandRed.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.report_problem_outlined,
                            color: AppColors.brandRed, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Admin Rejection Reason',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subCategory.rejectedReason!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF11261B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondaryLight, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
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
      ],
    );
  }
}
