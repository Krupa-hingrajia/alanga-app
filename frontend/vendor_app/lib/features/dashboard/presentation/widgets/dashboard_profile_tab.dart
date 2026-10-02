import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../settings/presentation/widgets/delete_account_dialog.dart';

class DashboardProfileTab extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final String? kycStatus;
  final Future<void> Function() onRefreshUser;
  final Future<void> Function() onRefreshDashboard;
  final VoidCallback onLogout;

  const DashboardProfileTab({
    super.key,
    required this.userData,
    required this.kycStatus,
    required this.onRefreshUser,
    required this.onRefreshDashboard,
    required this.onLogout,
  });

  Widget _buildAvatarWidget({
    required double size,
    required String? imagePath,
    required String initials,
    required double fontSize,
  }) {
    if (imagePath != null && imagePath.trim().isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE4ECE8), width: 1.5),
        ),
        child: ClipOval(
          child: CustomImageView(
            imageUrl: imagePath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholderIcon: Icons.storefront_rounded,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1A3827),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1A3827)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessName = userData?['businessName'] ?? 'Alanga Store';
    final fullName = userData?['fullName'] ?? 'Vendor User';
    final email = userData?['email'] ?? 'vendor@alanga.com';
    final mobileNumber = userData?['mobileNumber'] ?? '';
    final countryCode = userData?['countryCode'] ?? '+91';
    final formattedMobile = mobileNumber.isNotEmpty ? '$countryCode $mobileNumber' : 'Not Provided';
    final initials = businessName.isNotEmpty ? businessName.substring(0, 1).toUpperCase() : 'V';
    final profileImage = userData?['profileImage'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Card Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildAvatarWidget(
                  size: 60,
                  imagePath: profileImage,
                  initials: initials,
                  fontSize: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              businessName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AppColors.primaryGreen, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Owner: $fullName',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await context.push('/profile/edit');
                    await onRefreshUser();
                  },
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF1A3827), size: 20),
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Business Details
          const Text(
            'Business Profile Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileDetailRow(Icons.email_outlined, 'Registered Email', email),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                _buildProfileDetailRow(Icons.phone_outlined, 'Contact Mobile', formattedMobile),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                _buildProfileDetailRow(Icons.badge_outlined, 'Seller Status', 'Verified Marketplace Partner'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Items
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: Color(0xFF0284C7)),
                  title: const Text('Global Inventory & Stock Management', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Live warehouse stock, reorder alerts', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () => context.push('/inventory'),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined, color: Color(0xFF1A3827)),
                  title: const Text('Store KYC & Bank Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    kycStatus == 'VERIFIED'
                        ? 'Verified Partner ✓'
                        : kycStatus == 'PENDING'
                            ? 'Verification In Review ⏳'
                            : 'Action Required • Incomplete ⚠️',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kycStatus == 'VERIFIED'
                          ? AppColors.primaryGreen
                          : kycStatus == 'PENDING'
                              ? const Color(0xFFE65100)
                              : AppColors.brandRed,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () async {
                    await context.push('/kyc');
                    onRefreshDashboard();
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: Color(0xFF4C6656)),
                  title: const Text('Store Settings', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () async {
                    await context.push('/settings');
                    onRefreshUser();
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                ListTile(
                  leading: const Icon(Icons.headset_mic_outlined, color: Color(0xFF4C6656)),
                  title: const Text('Alanga Seller Support', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () => context.push('/settings/support'),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF4C6656)),
                  title: const Text('Privacy Policy & Legal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () => context.push('/settings/privacy-policy'),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.brandRed),
                  title: const Text('Delete Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brandRed)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () => DeleteAccountDialog.show(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Logout Action
          ElevatedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_outlined, size: 16),
            label: const Text(
              'LOGOUT FROM CENTRAL',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
