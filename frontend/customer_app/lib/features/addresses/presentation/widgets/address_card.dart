import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import 'default_badge.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const AddressCard({
    super.key,
    required this.address,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'OFFICE':
        return Icons.business_outlined;
      case 'OTHER':
        return Icons.place_outlined;
      case 'HOME':
      default:
        return Icons.home_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'OFFICE':
        return const Color(0xFF0284C7);
      case 'OTHER':
        return AppColors.brandOrange;
      case 'HOME':
      default:
        return AppColors.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(address.addressType);
    final typeIcon = _getTypeIcon(address.addressType);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryGreen
              : address.isDefault
                  ? AppColors.primaryGreen.withValues(alpha: 0.35)
                  : const Color(0xFFE4ECE8),
          width: isSelected ? 2 : (address.isDefault ? 1.4 : 1),
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primaryGreen.withValues(alpha: 0.1)
                : AppColors.darkGreen.withValues(alpha: 0.04),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Name, Address Type, Default Badge
                Row(
                  children: [
                    // Selection indicator (if in checkout or selection mode)
                    if (isSelectionMode) ...[
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? AppColors.primaryGreen
                            : const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Full Name
                    Expanded(
                      child: Text(
                        address.fullName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Address Type Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 12, color: typeColor),
                          const SizedBox(width: 4),
                          Text(
                            address.addressType.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Default Badge
                    if (address.isDefault) ...[
                      const SizedBox(width: 6),
                      const DefaultBadge(compact: true),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                // Formatted Address Line 1 & Line 2
                Text(
                  address.addressLine1 +
                      (address.addressLine2 != null && address.addressLine2!.isNotEmpty
                          ? ', ${address.addressLine2}'
                          : ''),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Landmark if present
                if (address.landmark != null && address.landmark!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.near_me_outlined, size: 12, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Landmark: ${address.landmark}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // City, State, Postal Code, Country
                const SizedBox(height: 4),
                Text(
                  '${address.city}, ${address.state} - ${address.postalCode}, ${address.country}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4C6656),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Phone numbers row
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 13, color: AppColors.primaryGreen),
                    const SizedBox(width: 5),
                    Text(
                      address.mobileNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF11261B),
                      ),
                    ),
                    if (address.alternateMobile != null && address.alternateMobile!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      const Text('•', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 6),
                      Text(
                        'Alt: ${address.alternateMobile}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),

                // Actions divider & buttons (Edit, Delete, Set Default)
                if (onEdit != null || onDelete != null || onSetDefault != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF3F6F4)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Set as default action
                      if (!address.isDefault && onSetDefault != null)
                        InkWell(
                          onTap: onSetDefault,
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline_rounded,
                                    size: 15, color: Color(0xFF4C6656)),
                                SizedBox(width: 4),
                                Text(
                                  'Set as Default',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4C6656),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),

                      // Action Icons: Edit & Delete
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onEdit != null)
                            InkWell(
                              onTap: onEdit,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F6F4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_outlined, size: 14, color: Color(0xFF11261B)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF11261B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (onDelete != null) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: onDelete,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.brandRed.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.delete_outline_rounded,
                                        size: 14, color: AppColors.brandRed),
                                    SizedBox(width: 4),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.brandRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
