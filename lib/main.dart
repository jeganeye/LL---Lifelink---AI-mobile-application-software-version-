import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_strings.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/caregiver/caregiver_page.dart';
import 'screens/emergency/emergency_page.dart';
import 'screens/history/health_history_page.dart';
import 'screens/live_monitoring/live_monitoring_page.dart';
import 'screens/medication/medication_page.dart';
import 'screens/navigation/main_shell_page.dart';
import 'screens/notifications/notifications_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/splash/splash_page.dart';
import 'screens/wearable/wearable_page.dart';
import 'services/localization_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive status bar overlay matching dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B132B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const LifelinkApp());
}

/// Root Application Widget for LL Lifelink AI.
class LifelinkApp extends StatelessWidget {
  const LifelinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocalizationService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark, // Default to rich medical-tech dark mode
          locale: LocalizationService.instance.currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashPage(),
          routes: {
            '/splash': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/dashboard': (context) => const MainShellPage(),
            '/live': (context) => const LiveMonitoringPage(),
            '/emergency': (context) => const EmergencyPage(),
            '/history': (context) => const HealthHistoryPage(),
            '/medication': (context) => const MedicationPage(),
            '/notifications': (context) => const NotificationsPage(),
            '/wearable': (context) => const WearablePage(),
            '/caregiver': (context) => const CaregiverPage(),
            '/profile': (context) => const ProfilePage(),
          },
        );
      },
    );
  }
}
