import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_language.dart';
import 'translations/bn.dart';
import 'translations/en.dart';
import 'translations/hi.dart';
import 'translations/kn.dart';
import 'translations/ml.dart';
import 'translations/mr.dart';
import 'translations/ta.dart';
import 'translations/te.dart';

/// Centralized localization class for LL Lifelink AI supporting 8 Indian languages.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ta'),
    Locale('hi'),
    Locale('te'),
    Locale('kn'),
    Locale('ml'),
    Locale('bn'),
    Locale('mr'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  /// Master translation maps keyed by language code.
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': enTranslations,
    'ta': taTranslations,
    'hi': hiTranslations,
    'te': teTranslations,
    'kn': knTranslations,
    'ml': mlTranslations,
    'bn': bnTranslations,
    'mr': mrTranslations,
  };

  /// Translates a key for the current locale with optional parameter substitution.
  String translate(String key, {Map<String, String>? params}) {
    final langCode = locale.languageCode.toLowerCase();
    final dict = _localizedValues[langCode] ?? enTranslations;
    var value = dict[key] ?? enTranslations[key] ?? key;

    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, paramVal) {
        value = value.replaceAll('{$paramKey}', paramVal);
      });
    }
    return value;
  }

  // ===========================================================================
  // CONVENIENCE TYPED GETTERS
  // ===========================================================================

  // Branding & Disclaimers
  String get appName => translate('appName');
  String get appTagline => translate('appTagline');
  String get sihHackathon => translate('sihHackathon');
  String get demoModeBadge => translate('demoModeBadge');
  String get medicalDisclaimer => translate('medicalDisclaimer');
  String get emergencyDisclaimer => translate('emergencyDisclaimer');

  // Navigation
  String get dashboard => translate('dashboard');
  String get livePpg => translate('livePpg');
  String get sosAlert => translate('sosAlert');
  String get meds => translate('meds');
  String get profile => translate('profile');
  String get patientHealthJourney => translate('patientHealthJourney');
  String get liveTelemetryStream => translate('liveTelemetryStream');
  String get emergencyAssistance => translate('emergencyAssistance');
  String get healthHistory => translate('healthHistory');
  String get medicationSchedule => translate('medicationSchedule');
  String get notificationsCenter => translate('notificationsCenter');
  String get wearableDevice => translate('wearableDevice');
  String get caregiverSupport => translate('caregiverSupport');
  String get patientProfile => translate('patientProfile');
  String get signOut => translate('signOut');
  String get language => translate('language');
  String get selectLanguage => translate('selectLanguage');

  // Dashboard
  String get helloPatient => translate('helloPatient');
  String get wearablePaired => translate('wearablePaired');
  String get aiRiskNormal => translate('aiRiskNormal');
  String get aiRiskWarning => translate('aiRiskWarning');
  String get aiRiskEmergency => translate('aiRiskEmergency');
  String get aiRiskNormalDesc => translate('aiRiskNormalDesc');
  String get emergencySosMode => translate('emergencySosMode');
  String get simulatedGpsBroadcast => translate('simulatedGpsBroadcast');
  String get openSos => translate('openSos');
  String get environmentalConditions => translate('environmentalConditions');
  String get environmentalTelemetry => translate('environmentalTelemetry');
  String get ambientTemp => translate('ambientTemp');
  String get humidity => translate('humidity');
  String get relHumidity => translate('relHumidity');
  String get airQuality => translate('airQuality');
  String get airQualityModerate => translate('airQualityModerate');
  String get updatedAt => translate('updatedAt');
  String get patientHealthJourneyBanner => translate('patientHealthJourneyBanner');
  String get recordedVisitsCount => translate('recordedVisitsCount');
  String get openContinuousRecords => translate('openContinuousRecords');
  String get realTimeHealthVitals => translate('realTimeHealthVitals');
  String get liveStream => translate('liveStream');
  String get heartRate => translate('heartRate');
  String get spo2Oxygen => translate('spo2Oxygen');
  String get bodyTemp => translate('bodyTemp');
  String get activityLevel => translate('activityLevel');

  // Status
  String get statusNormal => translate('statusNormal');
  String get statusWarning => translate('statusWarning');
  String get statusEmergency => translate('statusEmergency');
  String get statusStable => translate('statusStable');
  String get statusImproving => translate('statusImproving');
  String get statusNeedsAttention => translate('statusNeedsAttention');
  String get statusInsufficientData => translate('statusInsufficientData');

  // Health Journey
  String get healthSummaryTitle => translate('healthSummaryTitle');
  String get aggregatedVisitsVitals => translate('aggregatedVisitsVitals');
  String get healthTrendImprovingDesc => translate('healthTrendImprovingDesc');
  String get healthTrendStableDesc => translate('healthTrendStableDesc');
  String get healthTrendAttentionDesc => translate('healthTrendAttentionDesc');
  String get healthTrendInsufficientDesc => translate('healthTrendInsufficientDesc');
  String get aiAssistedExplanationOnly => translate('aiAssistedExplanationOnly');
  String get manageMedicalRecords => translate('manageMedicalRecords');
  String get newCheckup => translate('newCheckup');
  String get uploadScan => translate('uploadScan');
  String get addPrescription => translate('addPrescription');
  String get addMedicine => translate('addMedicine');
  String get continuousHealthTrend => translate('continuousHealthTrend');
  String get historicalTrajectory => translate('historicalTrajectory');
  String get daily => translate('daily');
  String get weekly => translate('weekly');
  String get monthly => translate('monthly');
  String get checkupComparison => translate('checkupComparison');
  String get priorVsLatest => translate('priorVsLatest');
  String get restingHeartRate => translate('restingHeartRate');
  String get bloodOxygen => translate('bloodOxygen');
  String get bodyTemperature => translate('bodyTemperature');
  String get prescribedRegimen => translate('prescribedRegimen');
  String get chronologicalTimeline => translate('chronologicalTimeline');
  String get checkupsCount => translate('checkupsCount');
  String get reasonForCheckup => translate('reasonForCheckup');
  String get physicianNotes => translate('physicianNotes');
  String get aiExplanation => translate('aiExplanation');
  String get attachedDemoFile => translate('attachedDemoFile');

  // AI Medical Document Explanation
  String get aiDocumentExplanationTitle => translate('aiDocumentExplanationTitle');
  String get plainLanguageSummary => translate('plainLanguageSummary');
  String get simplifiedMedicalTerms => translate('simplifiedMedicalTerms');
  String get comparisonWithPriorRecords => translate('comparisonWithPriorRecords');
  String get safetyDisclaimerText => translate('safetyDisclaimerText');
  String get spo2ReportExplanation => translate('spo2ReportExplanation');

  // Emergency Assistance & Safety
  String get safetyCheckTitle => translate('safetyCheckTitle');
  String safetyCheckCountdown(int seconds) =>
      translate('safetyCheckCountdown', params: {'seconds': seconds.toString()});
  String get safetyCheckDesc => translate('safetyCheckDesc');
  String get iAmOkay => translate('iAmOkay');
  String get needHelpNow => translate('needHelpNow');
  String get fallDetectedInstruction => translate('fallDetectedInstruction');
  String get sihDemoScenarioTitle => translate('sihDemoScenarioTitle');
  String get fallSimulationTitle => translate('fallSimulationTitle');
  String get fallSimulationDesc => translate('fallSimulationDesc');
  String get runFallScenario => translate('runFallScenario');
  String get tapToTriggerSos => translate('tapToTriggerSos');
  String get alertLoggedDemo => translate('alertLoggedDemo');
  String dispatchingAlertIn(int seconds) =>
      translate('dispatchingAlertIn', params: {'seconds': seconds.toString()});
  String get tapSosToCancel => translate('tapSosToCancel');
  String get sendsAutomatedTelemetry => translate('sendsAutomatedTelemetry');
  String get simulatedSosRecorded => translate('simulatedSosRecorded');
  String get evidenceUsedInAssessment => translate('evidenceUsedInAssessment');
  String get evidenceChecklistDesc => translate('evidenceChecklistDesc');
  String get evidenceImpact => translate('evidenceImpact');
  String get evidenceOrientation => translate('evidenceOrientation');
  String get evidenceInactivity => translate('evidenceInactivity');
  String get evidenceNoSafetyResponse => translate('evidenceNoSafetyResponse');
  String get evidenceHeatStress => translate('evidenceHeatStress');
  String get evidenceGpsLocked => translate('evidenceGpsLocked');
  String get evidencePulseLost => translate('evidencePulseLost');
  String get sensorDetached => translate('sensorDetached');
  String get activeConfirmed => translate('activeConfirmed');
  String get evidenceTriageBanner => translate('evidenceTriageBanner');
  String get environmentalContextAtEvent => translate('environmentalContextAtEvent');
  String get environmentalContextDesc => translate('environmentalContextDesc');
  String get caregiverAlertPrepared => translate('caregiverAlertPrepared');
  String get caregiverAlertDetails => translate('caregiverAlertDetails');
  String get autonomousSafetyTriggers => translate('autonomousSafetyTriggers');
  String get fallDetectionImu => translate('fallDetectionImu');
  String get heatStressDehydration => translate('heatStressDehydration');
  String get designatedAlertRecipient => translate('designatedAlertRecipient');
  String get primaryCaregiverName => translate('primaryCaregiverName');

  // Medication
  String get activePrescriptions => translate('activePrescriptions');
  String get dosage => translate('dosage');
  String get frequency => translate('frequency');
  String get reminderTime => translate('reminderTime');
  String get startDate => translate('startDate');
  String get endDate => translate('endDate');
  String get markTaken => translate('markTaken');
  String get markMissed => translate('markMissed');

  // Profile & Settings
  String get personalInformation => translate('personalInformation');
  String get settings => translate('settings');
  String get caregiver => translate('caregiver');
  String get notifications => translate('notifications');
  String get privacy => translate('privacy');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLanguage.values.any((lang) => lang.code == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
