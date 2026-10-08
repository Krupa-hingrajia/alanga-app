import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../app_localizations.dart';
import '../bloc/language_bloc.dart';
import '../bloc/language_event.dart';
import '../bloc/language_state.dart';

class LanguageSelectionBottomSheet extends StatelessWidget {
  const LanguageSelectionBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const LanguageSelectionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          final currentCode = state.locale.languageCode;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1DDD6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: Color(0xFF1A3827),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('select_language'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('choose_language'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFF4C6656)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Languages List
              _buildLanguageOption(
                context: context,
                code: 'en',
                title: 'English',
                subtitle: 'English',
                flag: '🇬🇧',
                isSelected: currentCode == 'en',
              ),
              const SizedBox(height: 12),

              _buildLanguageOption(
                context: context,
                code: 'ar',
                title: 'العربية',
                subtitle: 'Arabic (RTL)',
                flag: '🇸🇦',
                isSelected: currentCode == 'ar',
              ),
              const SizedBox(height: 12),

              _buildLanguageOption(
                context: context,
                code: 'hi',
                title: 'हिंदी',
                subtitle: 'Hindi',
                flag: '🇮🇳',
                isSelected: currentCode == 'hi',
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String code,
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        context.read<LanguageBloc>().add(ChangeLanguageEvent(Locale(code)));
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              code == 'ar'
                  ? 'تم تغيير اللغة بنجاح'
                  : code == 'hi'
                      ? 'भाषा सफलतापूर्वक बदल दी गई'
                      : 'Language changed to English',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF1A3827),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1A3827).withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A3827) : const Color(0xFFE4ECE8),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Flag/Icon Circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF1A3827).withValues(alpha: 0.1)
                    : const Color(0xFFF6F8F6),
              ),
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF11261B)
                          : const Color(0xFF2D3E35),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            // Radio / Checkmark
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF1A3827) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1A3827)
                      : const Color(0xFFB0C4B8),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 15,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
