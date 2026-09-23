import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../widgets/delete_account_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await sl<SecureStorageService>().getUserData();
    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.brandRed, size: 22),
            SizedBox(width: 8),
            Text(
              'Confirm Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF11261B),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your ALANGA Vendor account?',
          style: TextStyle(fontSize: 14, color: Color(0xFF4C6656)),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF4C6656), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await sl<AuthRepository>().logout();
              } catch (_) {
                await sl<SecureStorageService>().clearAll();
              }
              if (mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F8F6),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1A3827))),
      );
    }
    final businessName = _userData?['businessName'] ?? 'Alanga Vendor Store';
    final email = _userData?['email'] ?? 'vendor@alanga.com';
    final initials = businessName.isNotEmpty ? businessName.substring(0, 1).toUpperCase() : 'V';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Store Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF11261B),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF11261B), size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Store Header Quick Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A3827),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            businessName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF11261B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        await context.push('/profile/edit');
                        _loadUser();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A3827),
                        side: const BorderSide(color: Color(0xFF1A3827)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Account & Security Section
              _buildSectionHeader('Account & Security'),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile & Store Details',
                  subtitle: 'Update business name, phone, address',
                  onTap: () async {
                    await context.push('/profile/edit');
                    _loadUser();
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your account login password',
                  onTap: () => context.push('/settings/change-password'),
                ),
              ]),
              const SizedBox(height: 20),

              // Support & Help
              _buildSectionHeader('Support & Help'),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'Seller Support',
                  subtitle: 'Help center, queries, and helpline',
                  onTap: () => context.push('/settings/support'),
                ),
              ]),
              const SizedBox(height: 20),

              // Legal & Policies
              _buildSectionHeader('Legal & Compliance'),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Data usage & privacy protection guidelines',
                  onTap: () => context.push('/settings/privacy-policy'),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                _buildSettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  subtitle: 'Merchant service terms & responsibilities',
                  onTap: () => context.push('/settings/terms'),
                ),
              ]),
              const SizedBox(height: 20),

              // Danger Zone / Account Deletion
              _buildSectionHeader('Account Actions'),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.delete_forever_outlined,
                  iconColor: AppColors.brandRed,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your vendor store and data',
                  titleColor: AppColors.brandRed,
                  onTap: () => DeleteAccountDialog.show(context),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                _buildSettingsTile(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFF4C6656),
                  title: 'Logout',
                  subtitle: 'Sign out of this device',
                  onTap: _showLogoutDialog,
                ),
              ]),
              const SizedBox(height: 24),

              // App Version
              const Center(
                child: Text(
                  'Alanga Vendor App v1.0.2 (Build 3)\nApple App Store Review Ready',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B9E94),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4C6656),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFF1A3827)).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? const Color(0xFF1A3827), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: titleColor ?? const Color(0xFF11261B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11.5,
          color: AppColors.textSecondaryLight,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
      onTap: onTap,
    );
  }
}
