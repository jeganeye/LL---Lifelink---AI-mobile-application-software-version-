import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/caregiver_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/language_selector_sheet.dart';

/// Screen 11: CaregiverPage
/// Caregiver liaison and remote monitoring support.
/// Features:
/// - Designated emergency contact profile
/// - Live link connection status
/// - Contact actions (Simulated Call/SMS)
/// - Escalation logs & alert history
class CaregiverPage extends StatefulWidget {
  const CaregiverPage({super.key});

  @override
  State<CaregiverPage> createState() => _CaregiverPageState();
}

class _CaregiverPageState extends State<CaregiverPage> {
  final Caregiver _caregiver = Caregiver.defaultDemo();
  bool _notifyOnWarning = true;
  bool _notifyOnFall = true;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(loc.caregiverSupport),
        actions: [
          IconButton(
            tooltip: loc.selectLanguage,
            icon: const Icon(Icons.translate_rounded),
            onPressed: () => LanguageSelectorSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(
              message: 'CAREGIVER SUPPORT • DEMO RECIPIENT & ALERT DISPATCH',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Caregiver Profile Card
                  _buildCaregiverHeroCard(),

                  const SizedBox(height: 16),

                  // Quick Action Call & SMS buttons
                  _buildQuickActionButtons(),

                  const SizedBox(height: 16),

                  // Escalation Settings Card
                  _buildEscalationSettingsCard(),

                  const SizedBox(height: 16),

                  // Recent Caregiver Alerts Card
                  _buildRecentAlertsCard(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaregiverHeroCard() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.surfaceDark,
              AppColors.primaryLight.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    'PS',
                    style: AppTextStyles.headline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _caregiver.name,
                              style: AppTextStyles.headline.copyWith(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.statusNormalBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'CONNECTED',
                              style: TextStyle(
                                color: AppColors.statusNormal,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _caregiver.relation,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _caregiver.lastActive,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Emergency Recipient Status Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceDarkElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorderDark),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_rounded,
                    color: AppColors.statusEmergency,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Primary Emergency SOS Recipient (SMS + Call)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
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

  Widget _buildQuickActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            label: 'Call Caregiver',
            icon: Icons.phone_rounded,
            backgroundColor: AppColors.statusNormal,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Simulated Call: Dialing ${_caregiver.phoneNumber}...'),
                  backgroundColor: AppColors.statusNormal,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomButton(
            label: 'Send Quick SMS',
            icon: Icons.chat_bubble_outline_rounded,
            isSecondary: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Simulated SMS: Sending "All vitals normal" to ${_caregiver.name}...'),
                  backgroundColor: AppColors.primaryDark,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEscalationSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Automated Alert Escalation Rules',
              style: AppTextStyles.title.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Notify on Warning Vitals (HR > 105, SpO2 < 95%)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text('Sends immediate push & SMS reminder', style: AppTextStyles.caption),
              value: _notifyOnWarning,
              activeColor: AppColors.accent,
              onChanged: (val) => setState(() => _notifyOnWarning = val),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-Dispatch on Sudden Fall Detection',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text('Broadcasts live GPS coordinates', style: AppTextStyles.caption),
              value: _notifyOnFall,
              activeColor: AppColors.accent,
              onChanged: (val) => setState(() => _notifyOnFall = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlertsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Caregiver Activity Log',
              style: AppTextStyles.title.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 10),
            ..._caregiver.recentAlerts.map((alert) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.statusNormal, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
