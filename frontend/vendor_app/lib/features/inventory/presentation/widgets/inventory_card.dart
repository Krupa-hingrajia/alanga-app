import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/inventory_model.dart';
import 'inventory_status_badge.dart';

class InventoryCard extends StatelessWidget {
  final InventoryModel inventory;
  final VoidCallback onUpdateTap;
  final VoidCallback onHistoryTap;

  const InventoryCard({
    super.key,
    required this.inventory,
    required this.onUpdateTap,
    required this.onHistoryTap,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    final day = dt.day.toString().padLeft(2, '0');
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = monthNames[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Variant Name & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inventory.variant.variantName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F8F5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'SKU: ${inventory.sku}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5A7265),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InventoryStatusBadge(status: inventory.inventoryStatus),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0F4F1)),
            const SizedBox(height: 14),

            // Stock Stats Matrix (2x2 Grid)
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    label: 'Current Stock',
                    value: '${inventory.currentStock}',
                    icon: Icons.inventory_2_outlined,
                    valueColor: const Color(0xFF11261B),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatTile(
                    label: 'Available Stock',
                    value: '${inventory.availableStock}',
                    icon: Icons.check_circle_outline,
                    valueColor: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    label: 'Reserved Stock',
                    value: '${inventory.reservedStock}',
                    icon: Icons.lock_clock_outlined,
                    valueColor: AppColors.brandOrange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatTile(
                    label: 'Minimum Alert',
                    value: '${inventory.minimumStock}',
                    icon: Icons.notifications_none_outlined,
                    valueColor: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Last Updated Timestamp
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Last updated: ${_formatDate(inventory.lastStockUpdatedAt)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Actions Row: Update Stock & View History
            Row(
              children: [
                // History Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onHistoryTap,
                    icon: const Icon(Icons.history_rounded, size: 16),
                    label: const Text('History', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF11261B),
                      side: const BorderSide(color: Color(0xFFD4E2D9)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Update Stock Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onUpdateTap,
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text('Update Stock', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBF0ED)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
