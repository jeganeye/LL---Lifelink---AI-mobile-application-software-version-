import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/localization_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/language_selector_sheet.dart';
import '../auth/login_page.dart';

/// Screen 12: ProfilePage
/// Patient vitals overview, medical history, language selection, and settings.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserModel _user;
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = true;

  @override
  void initState() {
    super.initState();
    _user = AuthService().currentUser ?? UserModel.defaultDemo();
    _notificationsEnabled = _user.notificationsEnabled;
  }

  void _handleLogout() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: Text(loc.signOut, style: const TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to sign out of LL Lifelink AI companion?',
            style: TextStyle(color: AppColors.textMutedLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMutedLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusEmergency),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                AuthService().logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: Text(loc.signOut, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageSelector() {
    LanguageSelectorSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Patient Profile'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(
              message: 'PATIENT PROFILE • LOCAL DEMO HEALTH RECORD',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Profile Header Card
                  _buildProfileHeaderCard(),

                  const SizedBox(height: 16),

                  // Medical Baseline Info Grid
                  _buildMedicalVitalsGrid(),

                  const SizedBox(height: 16),

                  // Medical Conditions Tag Cloud
                  _buildMedicalConditionsCard(),

                  const SizedBox(height: 16),

                  // Application Preferences & Settings
                  _buildPreferencesCard(),

                  const SizedBox(height: 20),

                  // Logout Button
                  CustomButton(
                    label: 'Sign Out of LL Lifelink AI',
                    icon: Icons.logout_rounded,
                    backgroundColor: AppColors.statusEmergency,
                    onPressed: _handleLogout,
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: Text(
                      '${AppStrings.appName} • ${AppStrings.sihHackathon} v1.0.0',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMutedLight.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 38,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user.name,
                    style: AppTextStyles.headline.copyWith(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user.email,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDarkElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorderDark),
                    ),
                    child: Text(
                      'ID: ${_user.id}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMutedLight,
                        fontSize: 10,
                      ),
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

  Widget _buildMedicalVitalsGrid() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Baseline Clinical Parameters',
              style: AppTextStyles.title.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildParameterItem('Age', '${_user.age} yrs')),
                Expanded(child: _buildParameterItem('Blood Group', _user.bloodGroup)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildParameterItem('Weight', '${_user.weightKg} kg')),
                Expanded(child: _buildParameterItem('Height', '${_user.heightCm.toInt()} cm')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalConditionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Known Medical Conditions & Notes',
              style: AppTextStyles.title.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _user.medicalConditions.map((cond) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, color: AppColors.accent, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        cond,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    final loc = AppLocalizations.of(context);
    final currentLang = LocalizationService.instance.currentLanguage;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language_rounded, color: AppColors.accent),
            title: Text(loc.language, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('${currentLang.nativeName} (${currentLang.englishName})', style: AppTextStyles.caption.copyWith(color: AppColors.accent)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedLight),
            onTap: _showLanguageSelector,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.accent),
            title: const Text('Health Push Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('Receive vitals alarms & medication reminders', style: AppTextStyles.caption),
            value: _notificationsEnabled,
            activeColor: AppColors.accent,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.accent),
            title: const Text('Biometric Quick Unlock', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('Unlock dashboard with Fingerprint / Face', style: AppTextStyles.caption),
            value: _biometricsEnabled,
            activeColor: AppColors.accent,
            onChanged: (val) => setState(() => _biometricsEnabled = val),
          ),
        ],
      ),
    );
  }
}
