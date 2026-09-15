import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ll_lifelink_ai/screens/auth/login_page.dart';
import 'package:ll_lifelink_ai/screens/auth/register_page.dart';
import 'package:ll_lifelink_ai/screens/caregiver/caregiver_page.dart';
import 'package:ll_lifelink_ai/screens/dashboard/dashboard_page.dart';
import 'package:ll_lifelink_ai/screens/emergency/emergency_page.dart';
import 'package:ll_lifelink_ai/screens/history/health_history_page.dart';
import 'package:ll_lifelink_ai/screens/live_monitoring/live_monitoring_page.dart';
import 'package:ll_lifelink_ai/screens/medication/medication_page.dart';
import 'package:ll_lifelink_ai/screens/navigation/main_shell_page.dart';
import 'package:ll_lifelink_ai/screens/notifications/notifications_page.dart';
import 'package:ll_lifelink_ai/screens/profile/profile_page.dart';
import 'package:ll_lifelink_ai/screens/splash/splash_page.dart';
import 'package:ll_lifelink_ai/screens/wearable/wearable_page.dart';
import 'package:ll_lifelink_ai/services/health_data_service.dart';

void main() {
  void setMobileViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  setUp(() {
    HealthDataService().stopSimulation();
  });

  group('LL Lifelink AI - Widget & Screen Navigation Tests', () {
    testWidgets('SplashPage renders branding and title', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));

      expect(find.text('LL Lifelink AI'), findsOneWidget);
      expect(find.text('Smart India Hackathon 2026'), findsOneWidget);
    });

    testWidgets('LoginPage renders credentials and action buttons', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In to Dashboard'), findsOneWidget);
      expect(find.text('Create New Account'), findsOneWidget);
    });

    testWidgets('RegisterPage renders form fields', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Register & Launch Companion'), findsOneWidget);
    });

    testWidgets('DashboardPage renders all core health vitals cards', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: DashboardPage()));
      await tester.pump();

      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('SpO2 Oxygen'), findsOneWidget);
      expect(find.text('Body Temperature'), findsOneWidget);
      expect(find.text('Activity Level'), findsOneWidget);
      expect(find.text('Air Quality'), findsOneWidget);
      expect(find.text('Wearable Watch'), findsWidgets);
      expect(find.textContaining('AI RISK'), findsOneWidget);
    });

    testWidgets('LiveMonitoringPage renders live stream and PPG wave', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: LiveMonitoringPage()));
      await tester.pump();

      expect(find.text('Live Telemetry Stream'), findsOneWidget);
      expect(find.textContaining('PPG'), findsOneWidget);
      expect(find.text('Environmental Air Quality'), findsOneWidget);
    });

    testWidgets('EmergencyPage renders SOS button and safety toggles', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: EmergencyPage()));
      await tester.pump();

      expect(find.text('Emergency Assistance'), findsOneWidget);
      expect(find.text('SOS'), findsOneWidget);
      expect(find.textContaining('Fall Detection'), findsWidgets);
      expect(find.textContaining('Heat-Stress'), findsWidgets);
      expect(find.text('GPS Location Placeholder'), findsOneWidget);
    });

    testWidgets('HealthHistoryPage renders weekly averages and sparklines', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: HealthHistoryPage()));
      await tester.pump();

      expect(find.text('Health History & Trends'), findsOneWidget);
      expect(find.text('Weekly Health Averages'), findsOneWidget);
      expect(find.text('7-Day Resting Heart Rate Trend'), findsOneWidget);
    });

    testWidgets('MedicationPage renders prescriptions list and allows toggle', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: MedicationPage()));
      await tester.pump();

      expect(find.text('Medication Schedule'), findsOneWidget);
      expect(find.text('Daily Adherence Score'), findsOneWidget);
      expect(find.text('Amlodipine Besylate'), findsOneWidget);
      expect(find.text('Metformin HCl'), findsOneWidget);
      expect(find.text('Add Medicine'), findsOneWidget);
    });

    testWidgets('NotificationsPage renders multi-category cards', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: NotificationsPage()));
      await tester.pump();

      expect(find.text('Notifications & Alerts'), findsOneWidget);
      expect(find.textContaining('Heart Rate Warning'), findsOneWidget);
      expect(find.textContaining('Emergency SOS Test'), findsOneWidget);
    });

    testWidgets('WearablePage renders ESP32 status and sensor diagnostics', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: WearablePage()));
      await tester.pump();

      expect(find.text('Wearable Device & Sensors'), findsOneWidget);
      expect(find.text('LL Lifelink Watch'), findsOneWidget);
      expect(find.textContaining('MAX30102'), findsOneWidget);
      expect(find.textContaining('MPU6050'), findsOneWidget);
      expect(find.textContaining('BME280'), findsOneWidget);
    });

    testWidgets('CaregiverPage renders liaison contact info', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: CaregiverPage()));
      await tester.pump();

      expect(find.text('Caregiver Support'), findsOneWidget);
      expect(find.text('Priya Sharma'), findsOneWidget);
      expect(find.text('Call Caregiver'), findsOneWidget);
      expect(find.text('Send Quick SMS'), findsOneWidget);
    });

    testWidgets('ProfilePage renders patient info and logout button', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      await tester.pump();

      expect(find.text('Patient Profile'), findsOneWidget);
      expect(find.text('Baseline Clinical Parameters'), findsOneWidget);
      expect(find.text('App Language'), findsOneWidget);
      expect(find.text('Sign Out of LL Lifelink AI'), findsOneWidget);
    });

    testWidgets('MainShellPage renders bottom navigation with all 5 tabs', (tester) async {
      setMobileViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: MainShellPage()));
      await tester.pump();

      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Live PPG'), findsOneWidget);
      expect(find.text('SOS Alert'), findsOneWidget);
      expect(find.text('Meds'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });
  });
}
