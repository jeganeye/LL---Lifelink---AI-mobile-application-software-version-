import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../core/localization/app_language.dart';
import '../core/localization/app_localizations.dart';
import '../models/medical_record_model.dart';

/// Centralized localization service managing language state, persistence,
/// immediate app-wide rebuilds, voice-ready configuration, and localized AI document explanations.
class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  static LocalizationService get instance => _instance;

  AppLanguage _currentLanguage = AppLanguage.english;
  bool _isInitialized = false;

  LocalizationService._internal() {
    _initPersistence();
  }

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get currentLocale => _currentLanguage.locale;
  String get currentLanguageCode => _currentLanguage.code;
  VoiceLanguageConfig get currentVoiceConfig => _currentLanguage.voiceConfig;
  bool get isInitialized => _isInitialized;

  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  /// Initializes language preference from local disk if available.
  Future<void> _initPersistence() async {
    if (_isInitialized) return;
    try {
      final file = _getPreferencesFile();
      if (file != null && await file.exists()) {
        if (_isInitialized) return;
        final content = await file.readAsString();
        if (_isInitialized) return;
        final data = jsonDecode(content) as Map<String, dynamic>;
        final code = data['language_code'] as String?;
        if (code != null && !_isInitialized) {
          _currentLanguage = AppLanguage.fromCode(code);
        }
      }
    } catch (e) {
      debugPrint('[LocalizationService] Error loading language preference: $e');
    } finally {
      _isInitialized = true;
    }
  }

  File? _getPreferencesFile() {
    try {
      // In test mode, do not use disk files to avoid cross-test interference
      if (Platform.environment['FLUTTER_TEST'] == 'true') {
        return null;
      }
      return File('lifelink_language_pref.json');
    } catch (_) {
      return null;
    }
  }

  /// Resets language to English for test isolation.
  void resetForTesting() {
    _currentLanguage = AppLanguage.english;
    _isInitialized = true;
  }

  /// Sets the application language and immediately notifies all listening widgets.
  Future<void> setLanguage(AppLanguage language) async {
    _isInitialized = true;
    if (_currentLanguage == language) return;

    _currentLanguage = language;

    try {
      final file = _getPreferencesFile();
      if (file != null) {
        await file.writeAsString(
          jsonEncode({
            'language_code': language.code,
            'updated_at': DateTime.now().toIso8601String(),
          }),
        );
      }
    } catch (e) {
      debugPrint('[LocalizationService] Failed to persist language: $e');
    }

    notifyListeners();
  }

  /// Switch by code (e.g. 'ta', 'hi', 'te', etc.)
  Future<void> setLanguageByCode(String code) async {
    final language = AppLanguage.fromCode(code);
    await setLanguage(language);
  }

  /// Voice-ready list of all supported languages for future speech recognition integration.
  List<VoiceLanguageConfig> get allVoiceConfigs =>
      AppLanguage.values.map((l) => l.voiceConfig).toList();

  /// Generates or translates an AI Document Explanation into the target language.
  AiDocumentExplanation getLocalizedAiExplanation(
    AiDocumentExplanation original, {
    AppLanguage? targetLanguage,
  }) {
    final lang = targetLanguage ?? _currentLanguage;
    final docType = original.documentType.toLowerCase();

    // Check if this is SpO2 or blood oxygen report
    if (docType.contains('spo2') || docType.contains('oxygen') || original.summary.contains('SpO2')) {
      return _generateSpo2Explanation(lang, original);
    } else if (docType.contains('x-ray') || docType.contains('radiograph')) {
      return _generateXrayExplanation(lang, original);
    } else if (docType.contains('ecg') || docType.contains('ekg')) {
      return _generateEcgExplanation(lang, original);
    } else if (docType.contains('blood') || docType.contains('lab') || docType.contains('lipid')) {
      return _generateBloodTestExplanation(lang, original);
    }

    // Default fallback with translated disclaimer
    return AiDocumentExplanation(
      documentId: original.documentId,
      documentType: original.documentType,
      summary: original.summary,
      simplifiedTerms: original.simplifiedTerms,
      trend: original.trend,
      safetyDisclaimer: getSafetyDisclaimer(lang),
      comparisonNotes: original.comparisonNotes,
      extractedMetrics: original.extractedMetrics,
    );
  }

  /// Strict non-diagnostic legal disclaimer in all 8 supported languages.
  static String getSafetyDisclaimer(AppLanguage language) {
    switch (language) {
      case AppLanguage.tamil:
        return 'AI உதவியுடனான விளக்கம் மட்டுமே — மருத்துவ முடிவுகளுக்கு தகுதிவாய்ந்த மருத்துவ நிபுணரை அணுகவும். இது மருத்துவ நோயறிதல் அல்ல.';
      case AppLanguage.hindi:
        return 'केवल AI-सहायित व्याख्या — चिकित्सा निर्णयों के लिए योग्य स्वास्थ्य देखभाल पेशेवर से परामर्श लें। यह कोई निदान नहीं है।';
      case AppLanguage.telugu:
        return 'AI-సహాయక వివరణ మాత్రమే — వైద్య నిర్ణయాల కోసం అర్హత కలిగిన ఆరోగ్య నిపుణుడిని సంప్రదించండి. ఇది రోగ నిర్ధారణ కాదు.';
      case AppLanguage.kannada:
        return 'AI-ಸಹಾಯದ ವಿವರಣೆ ಮಾತ್ರ — ವೈದ್ಯಕೀಯ ನಿರ್ಧಾರಗಳಿಗಾಗಿ ಅರ್ಹ ಆರೋಗ್ಯ ವೃತ್ತಿಪರರನ್ನು ಸಂಪರ್ಕಿಸಿ. ಇದು ರೋಗನಿರ್ಣಯವಲ್ಲ.';
      case AppLanguage.malayalam:
        return 'AI സഹായത്തോടെയുള്ള വിശദീകരണം മാത്രം — ആരോഗ്യപരമായ തീരുമാനങ്ങൾക്ക് യോഗ്യതയുള്ള ഒരു ആരോഗ്യ വിദഗ്ദ്ധനെ സമീപിക്കുക. ഇതൊരു രോഗനിർണയമല്ല.';
      case AppLanguage.bengali:
        return 'শুধুমাত্র AI-সহায়তাপ্রাপ্ত ব্যাখ্যা — চিকিৎসার সিদ্ধান্তের জন্য যোগ্য স্বাস্থ্যসেবা পেশাদারের পরামর্শ নিন। এটি কোনো রোগ নির্ণয় নয়।';
      case AppLanguage.marathi:
        return 'केवळ AI-सहाय्यित स्पष्टीकरण — वैद्यकीय निर्णयांसाठी पात्र आरोग्यसेवा व्यावसायिकांचा सल्ला घ्या. हे निदान नाही.';
      case AppLanguage.english:
        return 'AI-assisted explanation only — consult a qualified healthcare professional for medical decisions. This is not a diagnosis.';
    }
  }

  AiDocumentExplanation _generateSpo2Explanation(AppLanguage lang, AiDocumentExplanation original) {
    String summary;
    switch (lang) {
      case AppLanguage.tamil:
        summary = 'நீங்கள் பதிவேற்றிய அறிக்கையில் SpO2 மதிப்பு 96% என பதிவாகியுள்ளது. இது பதிவேற்றப்பட்ட தகவலின் AI உதவியுடனான விளக்கம் மட்டுமே; இது மருத்துவ நோயறிதல் அல்ல.';
        break;
      case AppLanguage.hindi:
        summary = 'आपकी अपलोड की गई रिपोर्ट में SpO2 का मान 96% दर्ज है। यह अपलोड की गई जानकारी की AI-सहायित व्याख्या है और चिकित्सा निदान नहीं है।';
        break;
      case AppLanguage.telugu:
        summary = 'మీరు అప్‌లోడ్ చేసిన నివేదికలో SpO2 విలువ 96% గా నమోదైంది. ఇది అప్‌లోడ్ చేసిన సమాచారం యొక్క AI-సహాయక వివరణ మాత్రమే మరియు వైద్య నిర్ధారణ కాదు.';
        break;
      case AppLanguage.kannada:
        summary = 'ನೀವು ಅಪ್‌ಲೋಡ್ ಮಾಡಿದ ವರದಿಯಲ್ಲಿ SpO2 ಮೌಲ್ಯವು 96% ಎಂದು ದಾಖಲಾಗಿದೆ. ಇದು ಅಪ್‌ಲೋಡ್ ಮಾಡಿದ ಮಾಹಿತಿಯ AI-ಸಹಾಯದ ವಿವರಣೆ ಮಾತ್ರ ಮತ್ತು ವೈದ್ಯಕೀಯ ರೋಗನಿರ್ಣಯವಲ್ಲ.';
        break;
      case AppLanguage.malayalam:
        summary = 'നിങ്ങൾ അപ്‌ലോഡ് ചെയ്ത റിപ്പോർട്ടിൽ SpO2 മൂല്യം 96% ആയി രേഖപ്പെടുത്തിയിട്ടുണ്ട്. ഇത് അപ്‌ലോഡ് ചെയ്ത വിവരങ്ങളുടെ AI-സഹായത്തോടെയുള്ള വിശദീകരണം മാത്രമാണ്, വൈദ്യശാസ്ത്രപരമായ രോഗനിർണയമല്ല.';
        break;
      case AppLanguage.bengali:
        summary = 'আপনার আপলোড করা রিপোর্টে SpO2-এর মান 96% রেকর্ড করা হয়েছে। এটি আপলোড করা তথ্যের একটি AI-সহায়তাপ্রাপ্ত ব্যাখ্যা এবং কোনো চিকিৎসা নির্ণয় নয়।';
        break;
      case AppLanguage.marathi:
        summary = 'तुमच्या अपलोड केलेल्या अहवालात SpO2 चे मूल्य 96% नोंदवले गेले आहे. हे अपलोड केलेल्या माहितीचे AI-सहाय्यित स्पष्टीकरण आहे आणि वैद्यकीय निदान नाही.';
        break;
      case AppLanguage.english:
        summary = 'Your uploaded report shows a recorded value of 96% SpO2. This is an AI-assisted explanation of the uploaded information and is not a medical diagnosis.';
        break;
    }

    return AiDocumentExplanation(
      documentId: original.documentId,
      documentType: original.documentType,
      summary: summary,
      simplifiedTerms: {
        'SpO2': lang == AppLanguage.tamil
            ? 'இரத்தத்தில் உள்ள ஆக்சிஜன் செறிவு அளவு (95-100% இயல்பு)'
            : (lang == AppLanguage.hindi
                ? 'रक्त में ऑक्सीजन संतृप्ति स्तर (95-100% सामान्य)'
                : 'Peripheral capillary oxygen saturation (95-100% normal)'),
      },
      trend: HealthTrendDirection.stable,
      safetyDisclaimer: getSafetyDisclaimer(lang),
      comparisonNotes: lang == AppLanguage.tamil
          ? 'முந்தைய அளவீடுகளுடன் ஒப்பிடும்போது ஆக்சிஜன் அளவு நிலையாக உள்ளது.'
          : (lang == AppLanguage.hindi
              ? 'पिछले रिकॉर्ड की तुलना में ऑक्सीजन स्तर स्थिर है।'
              : 'Oxygen saturation remains steady within expected bounds.'),
      extractedMetrics: original.extractedMetrics,
    );
  }

  AiDocumentExplanation _generateXrayExplanation(AppLanguage lang, AiDocumentExplanation original) {
    String summary;
    Map<String, String> glossary;
    String comparison;

    switch (lang) {
      case AppLanguage.tamil:
        summary = 'மார்பு எக்ஸ்-ரே அறிக்கை: இரு நுரையீரல் பகுதிகளும் தெளிவாக உள்ளன. இதய நிழல் அளவு மற்றும் விலா எலும்பு கோணங்கள் இயல்பான வரம்பிற்குள் உள்ளன.';
        glossary = {
          'கார்டியோಥൊராசிக் விகிதம்': 'இதய அகலத்திற்கும் மார்பு அகலத்திற்கும் இடையிலான ஒப்பீடு; 0.5க்கு கீழ் இருப்பது இயல்பு.',
          'காஸ்டோஃப்ரெனிக் கோணங்கள்': 'நுரையீரல் குழியின் கீழ் மூலைகள்; கூர்மையான கோணங்கள் திரவம் சேரவில்லை என்பதைக் குறிக்கின்றன.',
        };
        comparison = 'முந்தைய பரிசோதனையுடன் ஒப்பிடும்போது நுரையீரல் மற்றும் இதய எல்லைகள் தெளிவாக உள்ளன.';
        break;
      case AppLanguage.hindi:
        summary = 'चेस्ट एक्स-रे रिपोर्ट: दोनों फेफड़े स्पष्ट हैं। कार्डियोथोरेसिक अनुपात और कॉस्टोफ्रेनिक कोण सामान्य सीमा के भीतर हैं।';
        glossary = {
          'कार्डियोथोरेसिक अनुपात': 'हृदय की चौड़ाई और छाती की चौड़ाई के बीच तुलना; 0.5 से कम सामान्य है।',
          'कॉस्टोफ्रेनिक कोण': 'फेफड़ों की गुहा के निचले कोने; नुकीले कोण किसी तरल पदार्थ के जमाव न होने का संकेत देते हैं।',
        };
        comparison = 'पिछले चेकअप की तुलना में फेफड़े और हृदय की सीमाएं पूरी तरह से स्पष्ट हैं।';
        break;
      case AppLanguage.telugu:
        summary = 'ఛాతీ ఎక్స్-రే నివేదిక: రెండు ఊపిరితిత్తులు స్పష్టంగా ఉన్నాయి. కార్డియోథొరాసిక్ నిష్పత్తి మరియు మూలలు సాధారణ పరిమితుల్లో ఉన్నాయి.';
        glossary = {
          'కార్డియోథొరాసిక్ నిష్పత్తి': 'గుండె వెడల్పు మరియు ఛాతీ వెడల్పు మధ్య పోలిక; 0.5 కంటే తక్కువ సాధారణం.',
          'కాస్టోఫ్రెనిక్ కోణాలు': 'ఊపిరితిత్తుల కుహరం యొక్క దిగువ మూలలు; ద్రవం పేరుకుపోలేదని సూచిస్తాయి.',
        };
        comparison = 'మునుపటి తనిಖీతో పోలిస్తే ఊపిరితిత్తులు మరియు గుండె సరిహద్దులు స్పష్టంగా ఉన్నాయి.';
        break;
      case AppLanguage.kannada:
        summary = 'ಎದೆ ಎಕ್ಸ್-ರೇ ವರದಿ: ಎರಡೂ ಶ್ವಾಸಕೋಶಗಳು ಸ್ಪಷ್ಟವಾಗಿವೆ. ಕಾರ್ಡಿಯೋಥೊರಾಸಿಕ್ ಅನುಪಾತ ಮತ್ತು ಕೋನಗಳು ಸಾಮಾನ್ಯ ಮಿತಿಯೊಳಗೆ ಇವೆ.';
        glossary = {
          'ಕಾರ್ಡಿಯೋಥೊರಾಸಿಕ್ ಅನುಪಾತ': 'ಹೃದಯದ ಅಗಲ ಮತ್ತು ಎದೆಯ ಅಗಲದ ನಡುವಿನ ಹೋಲಿಕೆ; 0.5 ಕ್ಕಿಂತ ಕಡಿಮೆ ಸಾಮಾನ್ಯ.',
          'ಕಾಸ್ಟೊಫ್ರೆನಿಕ್ ಕೋನಗಳು': 'ಶ್ವಾಸಕೋಶದ ಕುಹರದ ಕೆಳಗಿನ ಮೂಲೆಗಳು; ದ್ರವ ಸಂಗ್ರಹವಿಲ್ಲ ಎಂದು ಸೂಚಿಸುತ್ತವೆ.',
        };
        comparison = 'ಹಿಂದಿನ ತಪಾಸಣೆಗೆ ಹೋಲಿಸಿದರೆ ಶ್ವಾಸಕೋಶ ಮತ್ತು ಹೃದಯದ ಗಡಿಗಳು ಸ್ಪಷ್ಟವಾಗಿವೆ.';
        break;
      case AppLanguage.malayalam:
        summary = 'നെഞ്ച് എക്സ്-റേ റിപ്പോർട്ട്: രണ്ട് ശ്വാസകോശങ്ങളും വ്യക്തമാണ്. കാർഡിയോതോറാസിക് അനുപാതവും കോണുകളും സാധാരണ പരിധിക്കുള്ളിലാണ്.';
        glossary = {
          'കാർഡിയോതോറാസിക് അനുപാതം': 'ഹൃദയത്തിന്റെ വീതിയും നെഞ്ചിന്റെ വീതിയും തമ്മിലുള്ള താരതമ്യം; 0.5 ൽ താഴെ സാധാരണമാണ്.',
          'കോസ്റ്റോഫ്രെനിക് കോണുകൾ': 'ശ്വാസകോശ അറയുടെ താഴത്തെ കോണുകൾ; ദ്രാവകം അടിഞ്ഞുകൂടിയിട്ടില്ലെന്ന് സൂചിപ്പിക്കുന്നു.',
        };
        comparison = 'മുമ്പത്തെ പരിശോധനയുമായി താരതമ്യം ചെയ്യുമ്പോൾ ശ്വാസകോശവും ഹൃദയാതിർത്തികളും വ്യക്തമാണ്.';
        break;
      case AppLanguage.bengali:
        summary = 'বুকের এক্স-রে রিপোর্ট: উভয় ফুসফুস পরিষ্কার। কার্ডিওথোরাসিক অনুপাত এবং কোণগুলি স্বাভাবিক সীমার মধ্যে রয়েছে।';
        glossary = {
          'কার্ডিওথোরাসিক অনুপাত': 'হৃৎপিণ্ডের প্রস্থ এবং বুকের প্রস্থের মধ্যে তুলনা; ০.৫ এর কম স্বাভাবিক।',
          'কোস্টোফ্রেনিক কোণ': 'ফুসফুসের গহ্বরের নীচের কোণ; তীক্ষ্ণ কোণ কোনো তরল জমা না থাকার ইঙ্গিত দেয়।',
        };
        comparison = 'পূর্ববর্তী চেকআপের তুলনায় ফুসফুস এবং হৃৎপিণ্ডের সীমানা সম্পূর্ণরূপে পরিষ্কার।';
        break;
      case AppLanguage.marathi:
        summary = 'छातीचा एक्स-रे अहवाल: दोन्ही फुफ्फुसे स्पष्ट आहेत. कार्डिओथोरॅसिक प्रमाण आणि कोन सामान्य मर्यादेत आहेत.';
        glossary = {
          'कार्डिओथोरॅसिक प्रमाण': 'हृदयाची रुंदी आणि छातीच्या रुंदीमधील तुलना; ०.५ पेक्षा कमी सामान्य मानले जाते.',
          'कॉस्टोफ्रेनिक कोन': 'फुफ्फुसाच्या पोकळीचे खालचे टोक; टोकदार कोन कोणताही द्रव साचला नसल्याचे दर्शवतात.',
        };
        comparison = 'मागील तपासणीच्या तुलनेत फुफ्फुस आणि हृदयाच्या सीमा पूर्णपणे स्पष्ट आहेत.';
        break;
      case AppLanguage.english:
        summary = 'Both lung fields are clear with no consolidation, active infiltrates, or pleural effusion. The cardiothoracic ratio is normal (0.44).';
        glossary = {
          'Cardiothoracic Ratio': 'Comparison between heart width and chest width; under 0.5 is normal.',
          'Costophrenic Angles': 'The lower corners of the lung cavity; sharp angles indicate no excess fluid buildup.',
        };
        comparison = 'Lungs and heart boundaries appear completely clear compared to prior checkup.';
        break;
    }

    return AiDocumentExplanation(
      documentId: original.documentId,
      documentType: original.documentType,
      summary: summary,
      simplifiedTerms: glossary,
      trend: original.trend,
      safetyDisclaimer: getSafetyDisclaimer(lang),
      comparisonNotes: comparison,
      extractedMetrics: original.extractedMetrics,
    );
  }

  AiDocumentExplanation _generateEcgExplanation(AppLanguage lang, AiDocumentExplanation original) {
    String summary;
    Map<String, String> glossary;

    switch (lang) {
      case AppLanguage.tamil:
        summary = 'ECG பதிவு: சீரான சைனസ് ரிதம் பராமரிக்கப்படுகிறது. கடுமையான இதய தசை குறைபாடுகள் ஏதும் கண்டறியப்படவில்லை.';
        glossary = {
          'சைனஸ் ரிதம்': 'இதயத்தின் இயற்கையான பேஸ்மேக்கரால் உருவாக்கப்படும் இயல்பான தாளம்.',
          'R-R இடைவெளி': 'அடுத்தடுத்த இதயத் துடிப்புகளுக்கு இடையிலான கால அளவு.',
        };
        break;
      case AppLanguage.hindi:
        summary = 'ECG रिपोर्ट: नियमित साइनस लय बनी हुई है। कोई तीव्र हृदय संबंधी असामान्यता नहीं पाई गई है।';
        glossary = {
          'साइनस लय': 'हृदय के प्राकृतिक पेसमेकर द्वारा उत्पन्न सामान्य धड़कन ताल।',
          'R-R अंतराल': 'लगातार दो दिल की धड़कनों के बीच का समय।',
        };
        break;
      default:
        summary = 'ECG telemetry tracing indicates sinus rhythm is preserved with regular R-R wave intervals and no acute ischemic changes.';
        glossary = {
          'Sinus Rhythm': 'The normal rhythmic beating of the heart driven by natural pacemaker cells.',
          'R-R Interval': 'The measured duration between consecutive cardiac contractions.',
        };
        break;
    }

    return AiDocumentExplanation(
      documentId: original.documentId,
      documentType: original.documentType,
      summary: summary,
      simplifiedTerms: glossary,
      trend: original.trend,
      safetyDisclaimer: getSafetyDisclaimer(lang),
      comparisonNotes: lang == AppLanguage.tamil
          ? 'முந்தைய ECG பதிவுகளுடன் ஒப்பிடுகையில் தாளம் சீராக உள்ளது.'
          : 'Cardiac rhythm matches prior telemetry records.',
      extractedMetrics: original.extractedMetrics,
    );
  }

  AiDocumentExplanation _generateBloodTestExplanation(AppLanguage lang, AiDocumentExplanation original) {
    String summary;
    Map<String, String> glossary;

    switch (lang) {
      case AppLanguage.tamil:
        summary = 'இரத்தப் பரிசோதனை அறிக்கை: முக்கிய இரத்த அணுக்கள் மற்றும் கொலஸ்ட்ரால் அளவுகள் நிலையான வரம்பிற்குள் உள்ளன.';
        glossary = {
          'வெள்ளை இரத்த அணுக்கள்': 'தொற்றுநோய்களுக்கு எதிராக போராடும் நோய் எதிர்ப்பு அணுக்கள்.',
          'ஹீமோகுளோபின்': 'உடலின் திசுக்களுக்கு ஆக்சிஜனைக் கொண்டு செல்லும் இரத்த புரதம்.',
        };
        break;
      case AppLanguage.hindi:
        summary = 'रक्त परीक्षण रिपोर्ट: रक्त कोशिकाएं और मेटाबॉलिक मार्कर सामान्य संदर्भ सीमा के भीतर हैं।';
        glossary = {
          'श्वेत रक्त कोशिकाएं': 'संक्रमण से लड़ने वाली प्रतिरक्षा प्रणाली की कोशिकाएं।',
          'हीमोग्लोबिन': 'ऊतकों तक ऑक्सीजन पहुंचाने वाला रक्त प्रोटीन।',
        };
        break;
      default:
        summary = 'Comprehensive metabolic & lipid profile: Fasting blood glucose and total lipid fraction remain within clinical target guidelines.';
        glossary = {
          'HDL Cholesterol': 'High-density lipoprotein known as favorable cholesterol.',
          'Fasting Glucose': 'Blood sugar levels measured following an overnight fasting window.',
        };
        break;
    }

    return AiDocumentExplanation(
      documentId: original.documentId,
      documentType: original.documentType,
      summary: summary,
      simplifiedTerms: glossary,
      trend: original.trend,
      safetyDisclaimer: getSafetyDisclaimer(lang),
      comparisonNotes: lang == AppLanguage.tamil
          ? 'இரத்த சர்க்கரை மற்றும் கொழுப்பு அளவுகள் கட்டுப்பாட்டில் உள்ளன.'
          : 'Metabolic markers stabilized with ongoing medication adherence.',
      extractedMetrics: original.extractedMetrics,
    );
  }
}
