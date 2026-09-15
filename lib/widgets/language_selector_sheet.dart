import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/localization/app_language.dart';
import '../core/localization/app_localizations.dart';
import '../services/localization_service.dart';

/// Interactive modal sheet allowing the user to select their preferred language.
class LanguageSelectorSheet extends StatelessWidget {
  const LanguageSelectorSheet({super.key});

  /// Displays the language picker modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locService = LocalizationService.instance;
    final currentLang = locService.currentLanguage;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header with translation icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.translate_rounded, color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.selectLanguage,
                        style: AppTextStyles.title.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'SIH 2026 Multilingual Health Companion',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMutedLight, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.cardBorderDark, height: 1),
            const SizedBox(height: 10),

            // Language list
            ...AppLanguage.values.map((lang) {
              final isSelected = lang == currentLang;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent.withOpacity(0.12) : AppColors.surfaceDarkElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.cardBorderDark.withOpacity(0.5),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: Row(
                    children: [
                      Text(
                        lang.nativeName,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 16,
                          color: isSelected ? AppColors.accent : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${lang.englishName})',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: isSelected ? AppColors.accent.withOpacity(0.8) : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                  trailing: isSelected
                      ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 14, color: AppColors.bgDark),
                        )
                      : null,
                  onTap: () async {
                    Navigator.pop(context);
                    await locService.setLanguage(lang);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${lang.nativeName} (${lang.englishName}) selected',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: AppColors.accent,
                          duration: const Duration(milliseconds: 1500),
                        ),
                      );
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
