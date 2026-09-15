import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ll_lifelink_ai/core/localization/app_language.dart';
import 'package:ll_lifelink_ai/core/localization/app_localizations.dart';
import 'package:ll_lifelink_ai/models/medical_record_model.dart';
import 'package:ll_lifelink_ai/services/localization_service.dart';

void main() {
  setUp(() {
    LocalizationService.instance.resetForTesting();
  });

  tearDown(() {
    LocalizationService.instance.resetForTesting();
  });

  group('Multilingual Health Companion - Core Tests', () {
    test('All 8 Indian languages are defined with native script and voice config', () {
      expect(AppLanguage.values.length, 8);

      final expectedLanguages = {
        'en': 'English',
        'ta': 'தமிழ்',
        'hi': 'हिन्दी',
        'te': 'తెలుగు',
        'kn': 'ಕನ್ನಡ',
        'ml': 'മലയാളം',
        'bn': 'বাংলা',
        'mr': 'मराठी',
      };

      for (final entry in expectedLanguages.entries) {
        final lang = AppLanguage.fromCode(entry.key);
        expect(lang.code, entry.key);
        expect(lang.nativeName, entry.value);
        expect(lang.voiceLocaleCode, '${entry.key}-IN');
        expect(lang.voiceConfig.voiceLocaleCode, '${entry.key}-IN');
        expect(lang.voiceConfig.isVoiceSupported, true);
      }
    });

    test('AppLocalizations delegate supports all 8 locales', () {
      const delegate = AppLocalizations.delegate;
      for (final lang in AppLanguage.values) {
        expect(delegate.isSupported(lang.locale), true);
      }
      expect(delegate.isSupported(const Locale('fr')), false);
    });

    test('English translations provide full vocabulary and parameter substitution', () {
      final loc = AppLocalizations(const Locale('en'));
      expect(loc.appName, 'LL Lifelink AI');
      expect(loc.dashboard, 'Dashboard');
      expect(loc.emergencyAssistance, 'Emergency Assistance');
      expect(loc.safetyCheckTitle, 'SAFETY CHECK: ARE YOU OKAY?');
      expect(loc.iAmOkay, 'I AM OKAY');
      expect(loc.needHelpNow, 'NEED HELP NOW');
      expect(loc.safetyCheckCountdown(15), 'Auto-escalating in 15s if no response');
      expect(loc.dispatchingAlertIn(5), 'DISPATCHING SIMULATED ALERT IN 5s');
      expect(loc.recordedVisitsCount, contains('{count}'));
      expect(loc.translate('recordedVisitsCount', params: {'count': '3'}), '3 Recorded Visits • Scans & Prescriptions');
    });

    test('Tamil (தமிழ்) translations include exact required safety & emergency phrases', () {
      final loc = AppLocalizations(const Locale('ta'));
      expect(loc.appName, 'LL லைப்லிங்க் AI');
      expect(loc.dashboard, 'முகப்பு');
      expect(loc.safetyCheckTitle, 'பாதுகாப்பு சரிபார்ப்பு: நீங்கள் நலமாக உள்ளீர்களா?');
      expect(loc.iAmOkay, 'நான் நலமாக உள்ளேன்');
      expect(loc.needHelpNow, 'உடனடி உதவி தேவை');
      expect(loc.evidenceUsedInAssessment, 'மதிப்பீட்டில் பயன்படுத்தப்பட்ட சான்றுகள்');
      expect(loc.safetyCheckCountdown(15), contains('15'));
      expect(loc.medicalDisclaimer, contains('மருத்துவ நோயறிதலுக்கு'));
    });

    test('Hindi (हिन्दी) translations include exact required safety & emergency phrases', () {
      final loc = AppLocalizations(const Locale('hi'));
      expect(loc.appName, 'LL लाइफलिंक AI');
      expect(loc.dashboard, 'डैशबोर्ड');
      expect(loc.safetyCheckTitle, 'सुरक्षा जांच: क्या आप ठीक हैं?');
      expect(loc.iAmOkay, 'मैं ठीक हूँ');
      expect(loc.needHelpNow, 'तुरंत मदद चाहिए');
      expect(loc.evidenceUsedInAssessment, 'मूल्यांकन में प्रयुक्त साक्ष्य');
      expect(loc.safetyCheckCountdown(15), contains('15'));
      expect(loc.medicalDisclaimer, contains('नैदानिक निदान'));
    });

    test('Telugu, Kannada, Malayalam, Bengali, Marathi locales load correctly', () {
      for (final code in ['te', 'kn', 'ml', 'bn', 'mr']) {
        final loc = AppLocalizations(Locale(code));
        expect(loc.appName.isNotEmpty, true);
        expect(loc.safetyCheckTitle.isNotEmpty, true);
        expect(loc.iAmOkay.isNotEmpty, true);
        expect(loc.needHelpNow.isNotEmpty, true);
        expect(loc.patientHealthJourney.isNotEmpty, true);
        expect(loc.emergencyAssistance.isNotEmpty, true);
      }
    });

    test('LocalizationService switches language and notifies listeners', () async {
      final service = LocalizationService.instance;
      bool notified = false;
      void listener() => notified = true;

      service.addListener(listener);
      await service.setLanguage(AppLanguage.tamil);

      expect(service.currentLanguage, AppLanguage.tamil);
      expect(service.currentLanguageCode, 'ta');
      expect(service.currentVoiceConfig.voiceLocaleCode, 'ta-IN');
      expect(notified, true);

      // Switch to Hindi
      notified = false;
      await service.setLanguageByCode('hi');
      expect(service.currentLanguage, AppLanguage.hindi);
      expect(service.currentVoiceConfig.voiceLocaleCode, 'hi-IN');
      expect(notified, true);

      // Revert back to English
      await service.setLanguage(AppLanguage.english);
      expect(service.currentLanguage, AppLanguage.english);

      service.removeListener(listener);
    });

    test('Localized AI Document Explanation generates non-diagnostic disclaimer in all 8 languages', () async {
      final service = LocalizationService.instance;
      const original = AiDocumentExplanation(
        documentId: 'DOC-TEST-1',
        documentType: 'Blood Test Report',
        summary: 'Blood oxygen saturation reading indicates optimal pulmonary gas exchange at 98%.',
        simplifiedTerms: {
          'SpO2': 'Peripheral capillary oxygen saturation level.',
        },
        trend: HealthTrendDirection.improving,
        comparisonNotes: 'Previous record had 94% SpO2. Current 98% reflects marked improvement.',
      );

      for (final lang in AppLanguage.values) {
        await service.setLanguage(lang);
        final localized = service.getLocalizedAiExplanation(original);

        expect(localized.summary.isNotEmpty, true);
        expect(localized.safetyDisclaimer.isNotEmpty, true);
        // Ensure non-diagnostic safety disclaimer is present in every language
        expect(localized.safetyDisclaimer.length, greaterThan(20));
      }

      // Revert to English
      await service.setLanguage(AppLanguage.english);
    });

    test('Sensor values remain strictly numeric and formatted', () {
      const heartRate = 72;
      const spo2 = 97;
      const temp = 35.2;
      const aqi = 68;

      const hrString = '$heartRate BPM';
      const spo2String = '$spo2%';
      final tempString = '${temp.toStringAsFixed(1)}°C';
      const aqiString = 'AQI $aqi';

      expect(hrString, '72 BPM');
      expect(spo2String, '97%');
      expect(tempString, '35.2°C');
      expect(aqiString, 'AQI 68');
    });
  });

  group('Multilingual UI Widget Tests', () {
    testWidgets('UI dynamically switches language from English to Tamil and Hindi', (tester) async {
      final service = LocalizationService.instance;
      await service.setLanguage(AppLanguage.english);

      await tester.pumpWidget(
        AnimatedBuilder(
          animation: service,
          builder: (context, _) {
            return MaterialApp(
              locale: service.currentLocale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Builder(
                builder: (ctx) {
                  final loc = AppLocalizations.of(ctx);
                  return Scaffold(
                    body: Column(
                      children: [
                        Text(loc.dashboard),
                        Text(loc.safetyCheckTitle),
                        Text(loc.iAmOkay),
                        Text(loc.patientHealthJourney),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      );

      // Verify English
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('SAFETY CHECK: ARE YOU OKAY?'), findsOneWidget);
      expect(find.text('I AM OKAY'), findsOneWidget);
      expect(find.text('Patient Health Journey'), findsOneWidget);

      // Switch to Tamil
      await service.setLanguage(AppLanguage.tamil);
      await tester.pumpAndSettle();

      expect(find.text('முகப்பு'), findsOneWidget);
      expect(find.text('பாதுகாப்பு சரிபார்ப்பு: நீங்கள் நலமாக உள்ளீர்களா?'), findsOneWidget);
      expect(find.text('நான் நலமாக உள்ளேன்'), findsOneWidget);
      expect(find.text('நோயாளி சுகாதார பயணம்'), findsOneWidget);

      // Switch to Hindi
      await service.setLanguage(AppLanguage.hindi);
      await tester.pumpAndSettle();

      expect(find.text('डैशबोर्ड'), findsOneWidget);
      expect(find.text('सुरक्षा जांच: क्या आप ठीक हैं?'), findsOneWidget);
      expect(find.text('मैं ठीक हूँ'), findsOneWidget);
      expect(find.text('मरीज़ स्वास्थ्य यात्रा'), findsOneWidget);

      // Revert to English
      await service.setLanguage(AppLanguage.english);
    });
  });
}
