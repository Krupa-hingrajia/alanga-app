import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/bloc/language_bloc.dart';
import '../../../../core/localization/bloc/language_state.dart';
import '../../../../core/localization/widgets/language_selection_bottom_sheet.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../settings/presentation/widgets/delete_account_dialog.dart';
import '../../../profile/presentation/widgets/first_time_store_setup_sheet.dart';

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

  Widget _buildProfileDetailRow(IconData icon, String label, String value, {VoidCallback? onTap, bool isActionRequired = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isActionRequired ? AppColors.brandOrange : const Color(0xFF11261B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isActionRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.brandOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandOrange),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF7A9A86)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessName = userData?['businessName'] ?? 'Alanga Store';
    final fullName = userData?['fullName'] ?? 'Vendor User';
    final rawEmail = userData?['email'] ?? '';
    final isPlaceholderEmail = rawEmail.contains('@alanga.com') && rawEmail.startsWith('vendor_');
    final displayEmail = isPlaceholderEmail ? 'Not Set (Tap to add)' : rawEmail;

    final mobileNumber = userData?['mobileNumber'] ?? userData?['phoneNumber'] ?? '';
    final countryCode = userData?['countryCode'] ?? '+91';
    final String formattedMobile;
    if (mobileNumber.isEmpty) {
      formattedMobile = 'Not Provided';
    } else if (mobileNumber.startsWith('+')) {
      if (mobileNumber.startsWith('+91') && mobileNumber.length > 3) {
        formattedMobile = '+91 ${mobileNumber.substring(3)}';
      } else {
        formattedMobile = mobileNumber;
      }
    } else {
      formattedMobile = '$countryCode $mobileNumber';
    }

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
                  color: Colors.black.withValues(alpha: 0.02),
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
                  tooltip: context.tr('edit_profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Business Details
          Text(
            context.tr('details'),
            style: const TextStyle(
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
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileDetailRow(
                  Icons.email_outlined,
                  context.tr('email'),
                  displayEmail,
                  isActionRequired: isPlaceholderEmail,
                  onTap: () {
                    FirstTimeStoreSetupSheet.show(
                      context,
                      initialFullName: fullName,
                      initialBusinessName: businessName,
                      initialEmail: isPlaceholderEmail ? null : rawEmail,
                      onUpdated: onRefreshUser,
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                _buildProfileDetailRow(Icons.phone_outlined, context.tr('phone_number'), formattedMobile),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                _buildProfileDetailRow(Icons.badge_outlined, context.tr('status'), 'Verified Marketplace Partner'),
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
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Language Selection Option
                BlocBuilder<LanguageBloc, LanguageState>(
                  builder: (context, state) {
                    final code = state.locale.languageCode;
                    final flag = code == 'ar'
                        ? '🇸🇦'
                        : code == 'hi'
                            ? '🇮🇳'
                            : '🇬🇧';
                    final langName = code == 'ar'
                        ? 'العربية (Arabic)'
                        : code == 'hi'
                            ? 'हिंदी (Hindi)'
                            : 'English';
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.translate_rounded, color: Color(0xFF1A3827), size: 20),
                      ),
                      title: Text(
                        context.tr('language'),
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
                      ),
                      subtitle: Text(
                        '$flag $langName',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                      onTap: () => LanguageSelectionBottomSheet.show(context),
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF0284C7), size: 20),
                  ),
                  title: Text(context.tr('manage_inventory'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF11261B))),
                  subtitle: const Text('Live warehouse stock, reorder alerts', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () => context.push('/inventory'),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.verified_user_outlined, color: Color(0xFF1A3827), size: 20),
                  ),
                  title: Text(context.tr('kyc_verification'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF11261B))),
                  subtitle: Text(
                    kycStatus == 'VERIFIED'
                        ? 'Verified Partner ✓'
                        : kycStatus == 'PENDING'
                            ? 'Verification In Review ⏳'
                            : 'Action Required • Incomplete ⚠️',
                    style: TextStyle(
                      fontSize: 11.5,
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
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C6656).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.settings_outlined, color: Color(0xFF4C6656), size: 20),
                  ),
                  title: Text(context.tr('store_settings'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF11261B))),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () async {
                    await context.push('/settings');
                    onRefreshUser();
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C6656).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.headset_mic_outlined, color: Color(0xFF4C6656), size: 20),
                  ),
                  title: Text(context.tr('seller_support'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF11261B))),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () => context.push('/settings/support'),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C6656).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF4C6656), size: 20),
                  ),
                  title: Text(context.tr('privacy_policy'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF11261B))),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () => context.push('/settings/privacy-policy'),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandRed.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.brandRed, size: 20),
                  ),
                  title: Text(context.tr('delete_account'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.brandRed)),
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
            label: Text(
              context.tr('logout').toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
