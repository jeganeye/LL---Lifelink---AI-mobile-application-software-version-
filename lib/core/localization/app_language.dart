import 'package:flutter/material.dart';

/// Enum representing the 8 supported Indian languages for LL Lifelink AI.
enum AppLanguage {
  english(
    code: 'en',
    englishName: 'English',
    nativeName: 'English',
    voiceLocaleCode: 'en-IN',
  ),
  tamil(
    code: 'ta',
    englishName: 'Tamil',
    nativeName: 'தமிழ்',
    voiceLocaleCode: 'ta-IN',
  ),
  hindi(
    code: 'hi',
    englishName: 'Hindi',
    nativeName: 'हिन्दी',
    voiceLocaleCode: 'hi-IN',
  ),
  telugu(
    code: 'te',
    englishName: 'Telugu',
    nativeName: 'తెలుగు',
    voiceLocaleCode: 'te-IN',
  ),
  kannada(
    code: 'kn',
    englishName: 'Kannada',
    nativeName: 'ಕನ್ನಡ',
    voiceLocaleCode: 'kn-IN',
  ),
  malayalam(
    code: 'ml',
    englishName: 'Malayalam',
    nativeName: 'മലയാളം',
    voiceLocaleCode: 'ml-IN',
  ),
  bengali(
    code: 'bn',
    englishName: 'Bengali',
    nativeName: 'বাংলা',
    voiceLocaleCode: 'bn-IN',
  ),
  marathi(
    code: 'mr',
    englishName: 'Marathi',
    nativeName: 'मराठी',
    voiceLocaleCode: 'mr-IN',
  );

  final String code;
  final String englishName;
  final String nativeName;
  final String voiceLocaleCode;

  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.voiceLocaleCode,
  });

  Locale get locale => Locale(code);

  /// Resolves an [AppLanguage] from a language code (e.g. 'ta', 'hi', 'en').
  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => AppLanguage.english,
    );
  }

  /// Voice-ready configuration metadata for future speech recognition & TTS integration.
  VoiceLanguageConfig get voiceConfig => VoiceLanguageConfig(
        languageCode: code,
        voiceLocaleCode: voiceLocaleCode,
        displayName: '$nativeName ($englishName)',
        isVoiceSupported: true,
      );
}

/// Voice configuration container for future multilingual voice integration.
class VoiceLanguageConfig {
  final String languageCode;
  final String voiceLocaleCode;
  final String displayName;
  final bool isVoiceSupported;

  const VoiceLanguageConfig({
    required this.languageCode,
    required this.voiceLocaleCode,
    required this.displayName,
    this.isVoiceSupported = true,
  });
}
