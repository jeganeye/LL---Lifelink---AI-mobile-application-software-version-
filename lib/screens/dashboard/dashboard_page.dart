import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../models/environmental_reading_model.dart';
import '../../models/medical_record_model.dart';
import '../../models/medication_model.dart';
import '../../models/risk_status.dart';
import '../../services/auth_service.dart';
import '../../services/emergency_service.dart';
import '../../services/environment_service.dart';
import '../../services/health_data_service.dart';
import '../../services/medical_record_service.dart';
import '../../services/medication_service.dart';
import '../../services/wearable_service.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/language_selector_sheet.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/risk_badge.dart';
import '../caregiver/caregiver_page.dart';
import '../emergency/emergency_page.dart';
import '../health_journey/patient_health_journey_page.dart';
import '../history/health_history_page.dart';
import '../live_monitoring/live_monitoring_page.dart';
import '../medication/medication_page.dart';
import '../notifications/notifications_page.dart';
import '../profile/profile_page.dart';
import '../wearable/wearable_page.dart';

/// Screen 4: DashboardPage
/// Central command center displaying all key vitals, risk status, and quick routes.
class DashboardPage extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;
  final VoidCallback? onOpenDrawer;

  const DashboardPage({super.key, this.onNavigateTab, this.onOpenDrawer});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final HealthDataService _healthService = HealthDataService();
  final WearableService _wearableService = WearableService();
  final EmergencyService _emergencyService = EmergencyService();
  final EnvironmentService _envService = EnvironmentService();
  final MedicalRecordService _recordService = MedicalRecordService();
  final MedicationService _medicationService = MedicationService();

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(),
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _healthService,
                  _wearableService,
                  _emergencyService,
                  _envService,
                  _recordService,
                  _medicationService,
                ]),
                builder: (context, _) {
                  final reading = _healthService.currentReading;
                  final device = _wearableService.device;
                  final env = _envService.currentReading;
                  final records = _recordService.records;
                  final medications = _medicationService.medications;
                  final trend = _recordService.overallHealthTrend;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      // User Greeting & Hardware Status
                      _buildHeader(user?.name ?? 'Ramesh Kumar', device.isConnected),

                      const SizedBox(height: 14),

                      // Prominent AI Risk Status Card (NORMAL / WARNING / EMERGENCY)
                      _buildRiskBanner(reading.riskStatus),

                      const SizedBox(height: 14),

                      // Quick Emergency SOS Action Strip
                      _buildSosQuickTrigger(),

                      const SizedBox(height: 14),

                      // Environmental Conditions Card (Ambient Temp & Humidity REQUIRED & prominently displayed)
                      _buildEnvironmentalConditionsCard(env),

                      const SizedBox(height: 14),

                      // Patient Health Journey Banner (Continuous Records & AI Trends)
                      _buildPatientHealthJourneyBanner(trend, records.length),

                      const SizedBox(height: 16),

                      // Section Header: Core Health Vitals
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Real-Time Health Vitals',
                            style: AppTextStyles.title.copyWith(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {
                              if (widget.onNavigateTab != null) {
                                widget.onNavigateTab!(1); // Go to Live tab
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LiveMonitoringPage(),
                                  ),
                                );
                              }
                            },
                            child: const Row(
                              children: [
                                Text('Live Stream', style: TextStyle(color: AppColors.accent, fontSize: 13)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.accent),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Grid of Core Health Vitals Cards
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: AppStrings.heartRate,
                              value: reading.heartRate.toStringAsFixed(0),
                              unit: 'BPM',
                              icon: Icons.favorite_rounded,
                              accentColor: AppColors.heartRate,
                              subtitle: 'Normal Sinus Rhythm',
                              onTap: () => _openLiveMonitoring(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              title: AppStrings.spo2,
                              value: reading.spo2.toStringAsFixed(0),
                              unit: '%',
                              icon: Icons.water_drop_rounded,
                              accentColor: AppColors.spo2,
                              subtitle: 'Optimal Oxygenation',
                              onTap: () => _openLiveMonitoring(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: AppStrings.temperature,
                              value: reading.temperature.toStringAsFixed(1),
                              unit: '°C',
                              icon: Icons.thermostat_rounded,
                              accentColor: AppColors.temperature,
                              subtitle: 'Body Temp (BME280)',
                              onTap: () => _openLiveMonitoring(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              title: AppStrings.activity,
                              value: reading.activity,
                              unit: '',
                              icon: Icons.directions_walk_rounded,
                              accentColor: AppColors.activity,
                              subtitle: 'Movement (MPU6050)',
                              onTap: () => _openLiveMonitoring(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: AppStrings.airQuality,
                              value: reading.airQuality,
                              unit: 'AQI ${reading.aqiValue}',
                              icon: Icons.air_rounded,
                              accentColor: AppColors.airQuality,
                              subtitle: 'MQ135 Gas Telemetry',
                              onTap: () => _openLiveMonitoring(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              title: AppStrings.wearableConnection,
                              value: device.isConnected ? 'Connected' : 'Offline',
                              unit: '${device.batteryLevel}%',
                              icon: Icons.watch_rounded,
                              accentColor: device.isConnected
                                  ? AppColors.statusNormal
                                  : AppColors.statusEmergency,
                              subtitle: device.deviceName,
                              onTap: () => _openWearablePage(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Recent Health Records (Checkups, Scans & Prescriptions)
                      _buildRecentRecordsSection(records),

                      const SizedBox(height: 14),

                      // Medication Quick Status & Daily Adherence
                      _buildMedicationQuickStatus(medications),

                      const SizedBox(height: 20),

                      // Quick Access Services Hub (Links to all project screens)
                      Text(
                        'Project Feature Hub (SIH 2026)',
                        style: AppTextStyles.title.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 10),

                      _buildFeatureHubGrid(),

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

  Widget _buildHeader(String name, bool isWearableConnected) {
    final loc = AppLocalizations.of(context);

    return Row(
      children: [
        IconButton(
          tooltip: 'Navigation Menu',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
          onPressed: widget.onOpenDrawer,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('helloPatient', params: {'name': name}),
                style: AppTextStyles.headline.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isWearableConnected
                          ? AppColors.statusNormal
                          : AppColors.statusEmergency,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      isWearableConnected
                          ? loc.wearablePaired
                          : 'Wearable Disconnected',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMutedLight,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        // Instant Language Switcher Button
        IconButton(
          tooltip: loc.selectLanguage,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const Icon(Icons.translate_rounded, color: AppColors.accent, size: 22),
          onPressed: () => LanguageSelectorSheet.show(context),
        ),
        // Wearable Watch Icon
        IconButton(
          tooltip: loc.wearableDevice,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const Icon(Icons.watch_rounded, color: AppColors.accent, size: 22),
          onPressed: _openWearablePage,
        ),
        // Notifications Bell
        IconButton(
          tooltip: loc.notificationsCenter,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.statusEmergency,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: _openNotificationsPage,
        ),
      ],
    );
  }

  Widget _buildRiskBanner(RiskStatus status) {
    final loc = AppLocalizations.of(context);
    final riskDesc = status == RiskStatus.normal
        ? loc.aiRiskNormalDesc
        : (status == RiskStatus.warning
            ? 'TinyML alert: Elevated telemetry detected. Take rest and hydrate.'
            : 'CRITICAL ALERT: Arrhythmia / Extreme threshold reached. Caregiver alerted.');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.color.withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: status.color.withOpacity(0.2),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(status.icon, color: status.color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI RISK: ${status.label}',
                      style: AppTextStyles.title.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    RiskBadge(status: status, isCompact: true),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  riskDesc,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textLight,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosQuickTrigger() {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.statusEmergencyBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.statusEmergency.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.emergency_rounded, color: AppColors.statusEmergency, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.emergencySosMode,
                        style: AppTextStyles.title.copyWith(
                          fontSize: 13.5,
                          color: AppColors.statusEmergency,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        loc.simulatedGpsBroadcast,
                        style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusEmergency,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _openEmergencyPage,
            child: Text(loc.openSos, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHubGrid() {
    final features = [
      {
        'title': 'Health Journey',
        'subtitle': 'Records & AI Trends',
        'icon': Icons.timeline_rounded,
        'color': const Color(0xFF00E5FF),
        'action': () => _openPatientHealthJourneyPage(),
      },
      {
        'title': 'Live Monitoring',
        'subtitle': 'ESP32 PPG & Stream',
        'icon': Icons.monitor_heart_outlined,
        'color': AppColors.heartRate,
        'action': () => _openLiveMonitoring(),
      },
      {
        'title': 'Emergency SOS',
        'subtitle': 'Fall & Heat Triggers',
        'icon': Icons.emergency_rounded,
        'color': AppColors.statusEmergency,
        'action': () => _openEmergencyPage(),
      },
      {
        'title': 'Health History',
        'subtitle': '7-Day Trend Charts',
        'icon': Icons.show_chart_rounded,
        'color': AppColors.accent,
        'action': () => _openHealthHistoryPage(),
      },
      {
        'title': 'Medication',
        'subtitle': 'Schedule & Reminders',
        'icon': Icons.medication_rounded,
        'color': AppColors.primaryLight,
        'action': () => _openMedicationPage(),
      },
      {
        'title': 'Wearable Watch',
        'subtitle': 'ESP32 & Sensors',
        'icon': Icons.watch_rounded,
        'color': AppColors.statusNormal,
        'action': () => _openWearablePage(),
      },
      {
        'title': 'Caregiver',
        'subtitle': 'Remote Support Log',
        'icon': Icons.people_alt_rounded,
        'color': AppColors.temperature,
        'action': () => _openCaregiverPage(),
      },
      {
        'title': 'Notifications',
        'subtitle': 'Health & System Alerts',
        'icon': Icons.notifications_rounded,
        'color': AppColors.activity,
        'action': () => _openNotificationsPage(),
      },
      {
        'title': 'Patient Profile',
        'subtitle': 'Vitals & Settings',
        'icon': Icons.person_rounded,
        'color': Colors.blueGrey,
        'action': () => _openProfilePage(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final f = features[index];
        final Color color = f['color'] as Color;

        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: f['action'] as VoidCallback,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(f['icon'] as IconData, color: color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f['title'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          f['subtitle'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMutedLight,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openLiveMonitoring() {
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(1);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveMonitoringPage()));
    }
  }

  void _openEmergencyPage() {
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(2);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyPage()));
    }
  }

  void _openMedicationPage() {
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(3);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationPage()));
    }
  }

  void _openProfilePage() {
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(4);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  void _openHealthHistoryPage() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthHistoryPage()));
  }

  void _openWearablePage() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const WearablePage()));
  }

  void _openCaregiverPage() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CaregiverPage()));
  }

  void _openNotificationsPage() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
  }

  void _openPatientHealthJourneyPage() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientHealthJourneyPage()));
  }

  // ===========================================================================
  // PROMINENT ENVIRONMENTAL CONDITIONS CARD (Required on Dashboard)
  // ===========================================================================
  Widget _buildEnvironmentalConditionsCard(EnvironmentalReading env) {
    final loc = AppLocalizations.of(context);
    final Color riskColor = env.environmentalRisk == 'HIGH'
        ? AppColors.statusEmergency
        : (env.environmentalRisk == 'MODERATE'
            ? AppColors.statusWarning
            : AppColors.statusNormal);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: riskColor.withOpacity(0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: riskColor.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.cloud_queue_rounded, color: riskColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.environmentalConditions,
                            style: AppTextStyles.title.copyWith(fontSize: 14.5, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'BME280 & MQ135 Telemetry • Ambient Context',
                            style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: riskColor),
                ),
                child: Text(
                  '${env.environmentalRisk} RISK',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: riskColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Primary metrics: Ambient Temperature & Humidity (REQUIRED on Dashboard)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDarkElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorderDark),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.thermostat_rounded, color: AppColors.temperature, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.ambientTemp,
                              style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${env.temperature.toStringAsFixed(1)}°C',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDarkElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorderDark),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop_outlined, color: AppColors.spo2, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.humidity,
                              style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${env.humidity.toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Secondary metrics: Air Quality & Update Timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.air_rounded, size: 14, color: AppColors.airQuality),
                  const SizedBox(width: 5),
                  Text(
                    '${loc.airQuality}: ${env.airQuality} (AQI ${env.aqiValue})',
                    style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                ],
              ),
              Text(
                'Updated ${AppDateFormatter.formatTime(env.timestamp)}',
                style: const TextStyle(fontSize: 10.5, color: AppColors.textMutedLight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PATIENT HEALTH JOURNEY BANNER
  // ===========================================================================
  Widget _buildPatientHealthJourneyBanner(HealthTrendDirection trend, int checkupCount) {
    final loc = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _openPatientHealthJourneyPage,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F2B48),
                AppColors.surfaceDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4), width: 1.2),
          ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timeline_rounded, color: Color(0xFF00E5FF), size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        loc.patientHealthJourney,
                        style: AppTextStyles.title.copyWith(fontSize: 14.5, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: trend.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: trend.color),
                      ),
                      child: Text(
                        trend.label,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: trend.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  loc.translate('recordedVisitsCount', params: {'count': checkupCount.toString()}),
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _openPatientHealthJourneyPage,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          loc.openContinuousRecords,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.accent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  // ===========================================================================
  // RECENT HEALTH RECORDS OVERVIEW
  // ===========================================================================
  Widget _buildRecentRecordsSection(List<MedicalRecord> records) {
    if (records.isEmpty) return const SizedBox.shrink();
    final latest = records.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Health Records',
                style: AppTextStyles.title.copyWith(fontSize: 15),
              ),
              TextButton(
                onPressed: _openPatientHealthJourneyPage,
                child: const Text('View All >', style: TextStyle(color: AppColors.accent, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDarkElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorderDark.withOpacity(0.6)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latest.hospitalName,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${latest.doctorName} • ${AppDateFormatter.formatDate(latest.checkupDate)}',
                        style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        latest.reason,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMutedLight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MEDICATION QUICK STATUS
  // ===========================================================================
  Widget _buildMedicationQuickStatus(List<Medication> medications) {
    final takenCount = medications.where((m) => m.isTaken).length;
    final totalCount = medications.length;
    final progress = totalCount > 0 ? (takenCount / totalCount) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Medication Adherence', style: AppTextStyles.title.copyWith(fontSize: 15)),
              Text(
                '$takenCount of $totalCount Taken (${(progress * 100).toInt()}%)',
                style: AppTextStyles.caption.copyWith(color: AppColors.statusNormal, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceDarkElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.statusNormal),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next: ${medications.isNotEmpty ? medications.first.name : "None"}',
                style: AppTextStyles.caption.copyWith(fontSize: 11),
              ),
              InkWell(
                onTap: _openMedicationPage,
                child: const Text(
                  'Manage Schedule >',
                  style: TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

