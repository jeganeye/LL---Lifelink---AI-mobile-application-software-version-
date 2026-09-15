import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/localization_service.dart';
import '../../widgets/language_selector_sheet.dart';
import '../caregiver/caregiver_page.dart';
import '../dashboard/dashboard_page.dart';
import '../emergency/emergency_page.dart';
import '../health_journey/patient_health_journey_page.dart';
import '../history/health_history_page.dart';
import '../live_monitoring/live_monitoring_page.dart';
import '../medication/medication_page.dart';
import '../notifications/notifications_page.dart';
import '../profile/profile_page.dart';
import '../wearable/wearable_page.dart';
import '../auth/login_page.dart';

/// Navigation shell wrapping primary tabs and providing a drawer for all 12 project screens.
class MainShellPage extends StatefulWidget {
  final int initialTabIndex;

  const MainShellPage({super.key, this.initialTabIndex = 0});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final screens = [
      DashboardPage(
        onNavigateTab: _onTabSelected,
        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      const LiveMonitoringPage(),
      const EmergencyPage(),
      const MedicationPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgDark,
      drawer: _buildAppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.cardBorderDark, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textMutedLight,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: loc.dashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.monitor_heart_rounded),
              label: loc.livePpg,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.emergency_rounded),
              label: loc.sosAlert,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.medication_rounded),
              label: loc.meds,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: loc.profile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDrawer() {
    final user = AuthService().currentUser;
    final loc = AppLocalizations.of(context);
    final currentLang = LocalizationService.instance.currentLanguage;

    return Drawer(
      backgroundColor: AppColors.surfaceDark,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.cardBorderDark),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.appName,
                          style: AppTextStyles.title.copyWith(fontSize: 16),
                        ),
                        Text(
                          user?.name ?? 'Ramesh Kumar',
                          style: AppTextStyles.caption.copyWith(color: AppColors.accent),
                        ),
                        Text(
                          loc.sihHackathon,
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Route Links (All 12 Screens)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: loc.dashboard,
                    isSelected: _currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabSelected(0);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.monitor_heart_rounded,
                    title: loc.liveTelemetryStream,
                    isSelected: _currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabSelected(1);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.emergency_rounded,
                    title: loc.emergencyAssistance,
                    isSelected: _currentIndex == 2,
                    color: AppColors.statusEmergency,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabSelected(2);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.show_chart_rounded,
                    title: loc.healthHistory,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthHistoryPage()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.auto_stories_rounded,
                    title: loc.patientHealthJourney,
                    color: AppColors.accent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientHealthJourneyPage()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.medication_rounded,
                    title: loc.medicationSchedule,
                    isSelected: _currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabSelected(3);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_rounded,
                    title: loc.notificationsCenter,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.watch_rounded,
                    title: loc.wearableDevice,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WearablePage()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.people_alt_rounded,
                    title: loc.caregiverSupport,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CaregiverPage()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_rounded,
                    title: loc.patientProfile,
                    isSelected: _currentIndex == 4,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabSelected(4);
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            // Language Switcher Tile
            ListTile(
              leading: const Icon(Icons.translate_rounded, color: AppColors.accent),
              title: Text(loc.language, style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(
                '${currentLang.nativeName} (${currentLang.englishName})',
                style: const TextStyle(color: AppColors.accent, fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMutedLight),
              onTap: () {
                Navigator.pop(context);
                LanguageSelectorSheet.show(context);
              },
            ),

            // Logout Option
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.statusEmergency),
              title: Text(loc.signOut, style: const TextStyle(color: AppColors.statusEmergency, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                AuthService().logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? color,
  }) {
    final activeColor = color ?? AppColors.accent;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? activeColor : (color ?? AppColors.textMutedLight),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? activeColor : AppColors.textLight,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      tileColor: isSelected ? activeColor.withOpacity(0.12) : null,
      onTap: onTap,
    );
  }
}
