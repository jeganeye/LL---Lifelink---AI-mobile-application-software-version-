import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../models/emergency_evidence_model.dart';
import '../../models/risk_status.dart';
import '../../services/emergency_service.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/risk_badge.dart';
import '../../widgets/sos_button.dart';

/// Screen 6: EmergencyPage
/// Emergency Assistance Command Center.
/// Features:
/// - Interactive Large SOS Button with 5s countdown
/// - Fall Detection (MPU6050) & Heat-Stress monitoring toggles
/// - Simulated GPS Location placeholder
/// - Emergency contact routing
/// - Incident history log
class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final EmergencyService _emergencyService = EmergencyService();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(loc.emergencyAssistance),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(
              message: AppStrings.emergencyDisclaimer,
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _emergencyService,
                builder: (context, _) {
                  final isTriggered = _emergencyService.isSosTriggered;
                  final countdown = _emergencyService.countdownSeconds;

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    children: [
                      // Active Safety Confirmation Prompt (if triggered)
                      if (_emergencyService.isSafetyPromptActive) ...[
                        _buildSafetyPromptCard(),
                        const SizedBox(height: 16),
                      ],

                      // Active Emergency Warning Alert
                      if (isTriggered) ...[
                        _buildActiveEmergencyBanner(countdown),
                        const SizedBox(height: 16),
                      ],

                      // SIH 2026 Live Demo Scenario Trigger Card
                      _buildDemoScenarioActionCard(),

                      const SizedBox(height: 16),

                      // Big SOS Button Section
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isTriggered
                                ? AppColors.statusEmergency
                                : AppColors.cardBorderDark,
                            width: isTriggered ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            SosButton(
                              isTriggered: isTriggered,
                              countdownSeconds: countdown,
                              onPressed: () {
                                if (isTriggered) {
                                  _emergencyService.cancelSos();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Simulated SOS cancelled.'),
                                      backgroundColor: AppColors.primary,
                                    ),
                                  );
                                } else {
                                  _emergencyService.triggerSos();
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isTriggered
                                  ? (countdown > 0
                                      ? loc.dispatchingAlertIn(countdown)
                                      : loc.alertLoggedDemo)
                                  : loc.tapToTriggerSos,
                              style: AppTextStyles.title.copyWith(
                                color: isTriggered
                                    ? AppColors.statusEmergency
                                    : AppColors.textLight,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isTriggered
                                  ? loc.tapSosToCancel
                                  : loc.sendsAutomatedTelemetry,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Context-Aware Evidence Used in Assessment Card
                      _buildEvidenceChecklistCard(_emergencyService.currentEvidence),

                      const SizedBox(height: 16),

                      // Environmental Context Captured at Event
                      _buildEnvironmentalContextCard(_emergencyService.currentEvidence),

                      const SizedBox(height: 16),

                      // Caregiver Notification Status Card
                      _buildCaregiverAlertCard(),

                      const SizedBox(height: 16),

                      // Safety Monitoring Subsystems (Fall Detection & Heat Stress)
                      _buildSafetySubsystems(),

                      const SizedBox(height: 16),

                      // Designated Emergency Contact Card
                      _buildEmergencyContactCard(),

                      const SizedBox(height: 16),

                      // GPS Location Placeholder Card
                      _buildGpsCard(),

                      const SizedBox(height: 16),

                      // Incident History / Past Dispatch Logs
                      _buildEventHistorySection(),

                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyPromptCard() {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1015),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.statusEmergency, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.statusEmergency.withOpacity(0.35),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.statusEmergency,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.safetyCheckTitle,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.statusEmergency,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      loc.safetyCheckCountdown(_emergencyService.safetyPromptCountdown),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            loc.fallDetectedInstruction,
            style: AppTextStyles.caption.copyWith(color: AppColors.textLight, height: 1.35),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusNormal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(loc.iAmOkay, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  onPressed: () => _emergencyService.respondToSafetyPrompt(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusEmergency,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.emergency_rounded, size: 18),
                  label: Text(loc.needHelpNow, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  onPressed: () => _emergencyService.respondToSafetyPrompt(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoScenarioActionCard() {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1635),
            AppColors.surfaceDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.science_rounded, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                loc.sihDemoScenarioTitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loc.fallSimulationTitle,
            style: AppTextStyles.title.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            loc.fallSimulationDesc,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMutedLight, height: 1.3),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
              label: Text(
                loc.runFallScenario,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
              ),
              onPressed: () {
                _emergencyService.simulateFallAndLostPulseScenario();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Simulating: Fall detected & Pulse sensor detached...'),
                    backgroundColor: AppColors.primary,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceChecklistCard(EmergencyEvidence evidence) {
    final loc = AppLocalizations.of(context);
    final checklist = evidence.evidenceChecklist;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.fact_check_rounded, color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loc.evidenceUsedInAssessment,
                          style: AppTextStyles.title.copyWith(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                RiskBadge(
                  status: evidence.isFallDetected ? RiskStatus.emergency : RiskStatus.normal,
                  isCompact: true,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Multi-sensor fusion evaluation checklist for explainable AI triage:',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMutedLight),
            ),
            const SizedBox(height: 12),

            // Checklist items
            ...checklist.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDarkElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: item.isSupported
                        ? AppColors.statusEmergency.withOpacity(0.3)
                        : AppColors.cardBorderDark.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.isSupported ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                      color: item.isSupported ? AppColors.statusEmergency : AppColors.textMutedLight,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            item.details,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                              color: item.isSupported
                                  ? (item.details.contains('Unavailable') || item.details.contains('Lost')
                                      ? AppColors.statusWarning
                                      : AppColors.accent)
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.isSupported
                            ? AppColors.statusEmergency.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.isSupported ? 'ACTIVE' : 'BASELINE',
                        style: TextStyle(
                          color: item.isSupported ? AppColors.statusEmergency : AppColors.textMutedLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            // Explanation note container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF131F37),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryLight.withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      evidence.assessmentExplanation,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textLight,
                        fontSize: 11,
                        height: 1.35,
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

  Widget _buildEnvironmentalContextCard(EmergencyEvidence evidence) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.thermostat_auto_rounded, color: AppColors.accent, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'Environmental Context at Event',
                  style: AppTextStyles.title.copyWith(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Ambient conditions logged simultaneously during emergency escalation:',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMutedLight),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDarkElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ambient Temp', style: AppTextStyles.caption.copyWith(fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(
                          '${evidence.ambientTemp.toStringAsFixed(1)}°C',
                          style: AppTextStyles.title.copyWith(
                            color: evidence.ambientTemp > 38 ? AppColors.temperature : AppColors.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text('BME280', style: AppTextStyles.caption.copyWith(fontSize: 9)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDarkElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rel. Humidity', style: AppTextStyles.caption.copyWith(fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(
                          '${evidence.humidity.toStringAsFixed(0)}%',
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.spo2,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text('BME280', style: AppTextStyles.caption.copyWith(fontSize: 9)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDarkElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Air Quality', style: AppTextStyles.caption.copyWith(fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(
                          evidence.airQuality,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.airQuality,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text('MQ135', style: AppTextStyles.caption.copyWith(fontSize: 9)),
                      ],
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

  Widget _buildCaregiverAlertCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF14241B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.statusNormal.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.send_rounded, color: AppColors.statusNormal, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Caregiver Alert: DEMO — Emergency notification prepared',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.statusNormal,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Target Recipient: Priya Sharma (+91 98401 23456). In production ESP32 hardware, SIM800L sends automated SMS with Google Maps coordinates and vital telemetry context.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLight,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveEmergencyBanner(int countdown) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.statusEmergencyBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.statusEmergency, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.statusEmergency,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  countdown > 0 ? 'EMERGENCY COUNTDOWN ACTIVE' : 'SIMULATED SOS RECORDED',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.statusEmergency,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'SIH Prototype: Demonstrating dispatch trigger pipeline.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetySubsystems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Autonomous Safety Triggers',
              style: AppTextStyles.title.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.activity.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.accessibility_new_rounded,
                    color: AppColors.activity),
              ),
              title: const Text('Fall Detection (MPU6050 IMU)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(
                'Auto-detects sudden drops and impact vectors',
                style: AppTextStyles.caption,
              ),
              value: _emergencyService.isFallDetectionEnabled,
              activeColor: AppColors.accent,
              onChanged: (_) => _emergencyService.toggleFallDetection(),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.temperature.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: AppColors.temperature),
              ),
              title: const Text('Heat-Stress & Dehydration Monitor',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(
                'Cross-analyzes skin temp (BME280) and HR spike',
                style: AppTextStyles.caption,
              ),
              value: _emergencyService.isHeatStressMonitorEnabled,
              activeColor: AppColors.accent,
              onChanged: (_) => _emergencyService.toggleHeatStressMonitor(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Designated Alert Recipient',
                  style: AppTextStyles.title.copyWith(fontSize: 15),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusNormalBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'REACHABLE',
                    style: TextStyle(
                      color: AppColors.statusNormal,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Text('PS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              title: const Text('Priya Sharma (Daughter)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('+91 98401 23456 • Primary Emergency Contact'),
              trailing: IconButton(
                icon: const Icon(Icons.phone_rounded, color: AppColors.statusNormal),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Simulated Call: Dialing Priya Sharma (+91 98401 23456)...'),
                      backgroundColor: AppColors.primaryDark,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: AppColors.statusEmergency, size: 20),
                const SizedBox(width: 8),
                Text(
                  'GPS Location Placeholder',
                  style: AppTextStyles.title.copyWith(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDarkElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _emergencyService.gpsAddress,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lat: ${_emergencyService.latitude}° N, Lon: ${_emergencyService.longitude}° E  (Accuracy: ±${_emergencyService.gpsAccuracyMeters}m)',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
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

  Widget _buildEventHistorySection() {
    final events = _emergencyService.events;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Event History (Demo Log)',
          style: AppTextStyles.title.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...events.map((event) {
          final env = event.environmentalContext;
          final evidence = event.evidence;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.statusEmergencyBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.history_rounded,
                            color: AppColors.statusEmergency, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.triggerType,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              '${Formatters.formatDateTime(event.timestamp)} • ${Formatters.timeAgo(event.timestamp)}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textMutedLight, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.statusNormal, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.status,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.statusEmergency,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  if (event.caregiverAlertStatus.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.caregiverAlertStatus,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.statusNormal,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Environmental & Biometric Pills
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildEventPill(
                        Icons.favorite_rounded,
                        evidence != null && !evidence.isHrAvailable
                            ? 'HR: UNAVAILABLE'
                            : 'HR: ${event.heartRateAtEvent.toInt()} BPM',
                        evidence != null && !evidence.isHrAvailable
                            ? AppColors.statusWarning
                            : AppColors.heartRate,
                      ),
                      if (env != null) ...[
                        _buildEventPill(
                          Icons.device_thermostat_rounded,
                          'Env: ${env.ambientTemperature.toStringAsFixed(1)}°C',
                          env.ambientTemperature > 38 ? AppColors.temperature : AppColors.accent,
                        ),
                        _buildEventPill(
                          Icons.water_rounded,
                          'Hum: ${env.relativeHumidity.toStringAsFixed(0)}%',
                          AppColors.spo2,
                        ),
                        _buildEventPill(
                          Icons.air_rounded,
                          'AQI: ${env.aqiValue}',
                          AppColors.airQuality,
                        ),
                      ],
                      if (evidence != null && evidence.isFallDetected) ...[
                        _buildEventPill(
                          Icons.accessibility_new_rounded,
                          'Fall Confirmed',
                          AppColors.statusEmergency,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEventPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
