import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../models/medical_record_model.dart';
import '../../models/health_reading_model.dart';
import '../../models/risk_status.dart';
import '../../services/localization_service.dart';
import '../../services/medical_record_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/language_selector_sheet.dart';

/// Screen: PatientHealthJourneyPage
/// Continuous medical records companion allowing patients to store hospital visits,
/// upload scans, view AI-assisted document explanations, track multi-interval health trends,
/// and compare previous vs. current checkup vitals.
class PatientHealthJourneyPage extends StatefulWidget {
  const PatientHealthJourneyPage({super.key});

  @override
  State<PatientHealthJourneyPage> createState() => _PatientHealthJourneyPageState();
}

class _PatientHealthJourneyPageState extends State<PatientHealthJourneyPage> {
  final MedicalRecordService _recordService = MedicalRecordService();
  String _selectedTimeframe = 'Daily'; // 'Daily', 'Weekly', 'Monthly'
  int _activeMetricIndex = 0; // 0: Heart Rate, 1: SpO2, 2: Temperature

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(loc.patientHealthJourney),
        actions: [
          IconButton(
            tooltip: loc.selectLanguage,
            icon: const Icon(Icons.translate_rounded),
            onPressed: () => LanguageSelectorSheet.show(context),
          ),
          IconButton(
            tooltip: 'Record History Information',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showSafetyInfoDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(
              message: 'CONTINUOUS MEDICAL RECORDS • LOCAL DEMO ARCHITECTURE',
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _recordService,
                builder: (context, _) {
                  final records = _recordService.records;
                  final trend = _recordService.overallHealthTrend;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    children: [
                      // 1. Visual Health Summary Card
                      _buildHealthSummaryCard(trend),

                      const SizedBox(height: 16),

                      // 2. Quick Action Toolbar (Checkup, Upload Scan, Prescription, Medicine)
                      _buildQuickActionToolbar(),

                      const SizedBox(height: 20),

                      // 3. Continuous Health Trend Section (Daily/Weekly/Monthly)
                      _buildHealthTrendSection(),

                      const SizedBox(height: 20),

                      // 4. Previous Checkup vs Current Checkup Comparison
                      if (records.length >= 2) ...[
                        _buildComparisonSection(records[1], records[0]),
                        const SizedBox(height: 20),
                      ],

                      // 5. Chronological Medical Timeline
                      _buildTimelineSection(records),

                      const SizedBox(height: 28),
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

  // ===========================================================================
  // 1. HEALTH SUMMARY CARD ("Your Health Trend")
  // ===========================================================================
  Widget _buildHealthSummaryCard(HealthTrendDirection trend) {
    final loc = AppLocalizations.of(context);
    String summaryTitle;
    String summaryBody;

    switch (trend) {
      case HealthTrendDirection.stable:
        summaryTitle = loc.translate('healthSummaryTitle', params: {'status': loc.statusStable});
        summaryBody = loc.healthTrendStableDesc;
        break;
      case HealthTrendDirection.improving:
        summaryTitle = loc.translate('healthSummaryTitle', params: {'status': loc.statusImproving});
        summaryBody = loc.healthTrendImprovingDesc;
        break;
      case HealthTrendDirection.needsAttention:
        summaryTitle = loc.translate('healthSummaryTitle', params: {'status': loc.statusNeedsAttention});
        summaryBody = loc.healthTrendAttentionDesc;
        break;
      case HealthTrendDirection.insufficientData:
        summaryTitle = loc.translate('healthSummaryTitle', params: {'status': loc.statusInsufficientData});
        summaryBody = loc.healthTrendInsufficientDesc;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            trend.color.withOpacity(0.18),
            AppColors.surfaceDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: trend.color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: trend.color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: trend.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(trend.icon, color: trend.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summaryTitle,
                      style: AppTextStyles.title.copyWith(
                        color: trend.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loc.aggregatedVisitsVitals,
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: trend.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: trend.color),
                ),
                child: Text(
                  trend.label.toUpperCase(),
                  style: TextStyle(
                    color: trend.color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summaryBody,
            style: AppTextStyles.body.copyWith(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.health_and_safety_outlined, size: 14, color: AppColors.accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    loc.aiAssistedExplanationOnly,
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textMutedLight),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. QUICK ACTION TOOLBAR
  // ===========================================================================
  Widget _buildQuickActionToolbar() {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.manageMedicalRecords,
          style: AppTextStyles.title.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: loc.newCheckup,
                icon: Icons.add_circle_outline_rounded,
                color: AppColors.primary,
                onTap: _showCreateCheckupDialog,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                label: loc.uploadScan,
                icon: Icons.document_scanner_rounded,
                color: const Color(0xFF00E5FF),
                onTap: _showUploadDocumentDialog,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: loc.addPrescription,
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF9D4EDD),
                onTap: _showUploadPrescriptionDialog,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                label: loc.addMedicine,
                icon: Icons.medication_rounded,
                color: AppColors.statusNormal,
                onTap: _showAddMedicineDialog,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. CONTINUOUS HEALTH TREND (Daily / Weekly / Monthly)
  // ===========================================================================
  Widget _buildHealthTrendSection() {
    final points = _recordService.getTrendPoints(_selectedTimeframe);
    final metrics = ['Heart Rate', 'SpO2 Oxygen', 'Temperature'];
    final units = ['BPM', '%', '°C'];
    final colors = [AppColors.heartRate, AppColors.spo2, AppColors.temperature];

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continuous Health Trend',
                      style: AppTextStyles.title.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Historical trajectory across checkups & vitals',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Daily / Weekly / Monthly Switcher
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceDarkElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorderDark),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: ['Daily', 'Weekly', 'Monthly'].map((tf) {
                    final isSelected = _selectedTimeframe == tf;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimeframe = tf;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tf,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : AppColors.textMutedLight,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Metric Tab Selector (HR / SpO2 / Temp)
          Row(
            children: List.generate(metrics.length, (i) {
              final isSelected = _activeMetricIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeMetricIndex = i;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? colors[i].withOpacity(0.18) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? colors[i] : AppColors.cardBorderDark.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          metrics[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? colors[i] : AppColors.textMutedLight,
                          ),
                        ),
                        Text(
                          units[i],
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected ? colors[i].withOpacity(0.8) : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Interactive Trend Chart Canvas
          Container(
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF070D1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorderDark.withOpacity(0.6)),
            ),
            child: _buildSparklineChart(
              points: points,
              metricIndex: _activeMetricIndex,
              color: colors[_activeMetricIndex],
              unit: units[_activeMetricIndex],
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'DEMO & STORED RECORDS • Real hospital readings update graphs dynamically',
              style: TextStyle(fontSize: 10, color: AppColors.textMutedLight, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparklineChart({
    required List<HealthTrendPoint> points,
    required int metricIndex,
    required Color color,
    required String unit,
  }) {
    List<double> values = [];
    for (final p in points) {
      if (metricIndex == 0) values.add(p.heartRate);
      if (metricIndex == 1) values.add(p.spo2);
      if (metricIndex == 2) values.add(p.temperature);
    }

    if (values.isEmpty) {
      return const Center(child: Text('No data recorded', style: TextStyle(color: Colors.white54)));
    }

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _TrendChartPainter(
            values: values,
            labels: points.map((p) => p.label).toList(),
            lineColor: color,
            minVal: minVal,
            maxVal: maxVal,
            range: range,
            unit: unit,
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 4. PREVIOUS VS CURRENT CHECKUP COMPARISON
  // ===========================================================================
  Widget _buildComparisonSection(MedicalRecord previous, MedicalRecord current) {
    final comparisons = _recordService.compareCheckups(
      previous: previous,
      current: current,
    );

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Checkup Comparison',
                      style: AppTextStyles.title.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Prior (${AppDateFormatter.formatDate(previous.checkupDate)}) vs Latest (${AppDateFormatter.formatDate(current.checkupDate)})',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.compare_arrows_rounded, color: AppColors.accent, size: 22),
            ],
          ),
          const SizedBox(height: 12),

          // Comparison rows
          ...comparisons.map((c) => _buildComparisonRow(c)),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(CheckupComparisonItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorderDark.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.metricName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  item.note,
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Prior: ${item.previousValue}',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMutedLight),
                ),
                const SizedBox(height: 2),
                Text(
                  item.currentValue,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.trend.color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: item.trend.color.withOpacity(0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.trend.icon, size: 13, color: item.trend.color),
                const SizedBox(width: 4),
                Text(
                  item.trend.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: item.trend.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. CHRONOLOGICAL MEDICAL TIMELINE
  // ===========================================================================
  Widget _buildTimelineSection(List<MedicalRecord> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chronological Medical Timeline',
              style: AppTextStyles.title.copyWith(fontSize: 16),
            ),
            Text(
              '${records.length} Checkups',
              style: AppTextStyles.caption.copyWith(color: AppColors.accent),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...List.generate(records.length, (index) {
          final record = records[index];
          final isLast = index == records.length - 1;
          return _buildTimelineItem(record, isLast);
        }),
      ],
    );
  }

  Widget _buildTimelineItem(MedicalRecord record, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator line + circle
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDark,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: const Icon(Icons.local_hospital_rounded, size: 12, color: Colors.white),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.cardBorderDark,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Main Record Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Record Type Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppDateFormatter.formatDate(record.checkupDate),
                        style: AppTextStyles.title.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDarkElevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.cardBorderDark),
                        ),
                        child: Text(
                          '${record.recordType} Visit',
                          style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Hospital & Doctor
                  Text(
                    record.hospitalName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    record.doctorName,
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 6),

                  // Reason & Notes
                  Text(
                    'Reason: ${record.reason}',
                    style: AppTextStyles.body.copyWith(fontSize: 12),
                  ),
                  if (record.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Notes: ${record.notes}',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],

                  // Attached Scans/Reports & AI Explanation Button
                  if (record.documents.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Divider(color: AppColors.cardBorderDark, height: 1),
                    const SizedBox(height: 8),
                    ...record.documents.map((doc) {
                      return Row(
                        children: [
                          const Icon(Icons.description_outlined, size: 16, color: Color(0xFF00E5FF)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${doc.documentType}: ${doc.title}',
                              style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (doc.aiExplanation != null)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.auto_awesome, size: 12, color: AppColors.accent),
                              label: const Text('AI Explanation', style: TextStyle(fontSize: 11, color: AppColors.accent)),
                              onPressed: () => _showAiExplanationModal(context, doc.aiExplanation!),
                            ),
                        ],
                      );
                    }),
                  ],

                  // Prescribed Medicines list
                  if (record.medicines.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: record.medicines.map((m) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDarkElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '💊 ${m.name} (${m.dosage})',
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textLight),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MODALS & DIALOGS
  // ===========================================================================

  /// A. Checkup Record creation modal
  void _showCreateCheckupDialog() {
    final hospitalCtrl = TextEditingController(text: 'Apollo Speciality Hospital, Chennai');
    final doctorCtrl = TextEditingController(text: 'Dr. S. Sundararajan (MD)');
    final reasonCtrl = TextEditingController(text: 'Cardiopulmonary Vitals & Blood Review');
    final notesCtrl = TextEditingController(text: 'Follow-up consultation. Ambulatory vitals steady.');
    String recordType = 'Monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Record New Checkup Visit', style: AppTextStyles.headline.copyWith(color: Colors.white)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: hospitalCtrl,
                      decoration: const InputDecoration(labelText: 'Hospital / Clinic Name', prefixIcon: Icon(Icons.local_hospital_rounded)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: doctorCtrl,
                      decoration: const InputDecoration(labelText: 'Attending Doctor', prefixIcon: Icon(Icons.person_rounded)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: reasonCtrl,
                      decoration: const InputDecoration(labelText: 'Reason for Checkup', prefixIcon: Icon(Icons.help_outline_rounded)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Physician Clinical Notes', prefixIcon: Icon(Icons.notes_rounded)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: recordType,
                      decoration: const InputDecoration(labelText: 'Checkup Interval Type', prefixIcon: Icon(Icons.event_repeat_rounded)),
                      dropdownColor: AppColors.surfaceDark,
                      items: ['Daily', 'Weekly', 'Monthly', 'Other'].map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => recordType = val);
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'Save Checkup to Health Journey',
                      onPressed: () {
                        if (hospitalCtrl.text.isNotEmpty && doctorCtrl.text.isNotEmpty) {
                          final newRecord = MedicalRecord(
                            id: 'CHK-${DateTime.now().millisecondsSinceEpoch % 10000}',
                            checkupDate: DateTime.now(),
                            hospitalName: hospitalCtrl.text.trim(),
                            doctorName: doctorCtrl.text.trim(),
                            reason: reasonCtrl.text.trim(),
                            notes: notesCtrl.text.trim(),
                            recordType: recordType,
                            vitalsSnapshot: HealthReading(
                              heartRate: 74.0,
                              spo2: 98.0,
                              temperature: 36.6,
                              activity: 'Resting',
                              airQuality: 'Good',
                              aqiValue: 45,
                              riskStatus: RiskStatus.normal,
                              timestamp: DateTime.now(),
                            ),
                          );
                          _recordService.addCheckupRecord(newRecord);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('New checkup record added to timeline!'),
                              backgroundColor: AppColors.statusNormal,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// B. Medical Report / Scan Upload modal
  void _showUploadDocumentDialog() {
    final titleCtrl = TextEditingController(text: 'Echocardiogram 2D Echo Report');
    final hospitalCtrl = TextEditingController(text: 'MIOT International, Chennai');
    final doctorCtrl = TextEditingController(text: 'Dr. K. Ramanathan');
    final notesCtrl = TextEditingController(text: 'Normal ventricular ejection fraction (62%).');
    String reportType = 'Scan report';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Upload Medical Scan / Report', style: AppTextStyles.headline.copyWith(color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                      'Supported: X-ray, ECG, Blood test, Scan, CT, MRI, Ultrasound, PDF/Images',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: reportType,
                      decoration: const InputDecoration(labelText: 'Report Category', prefixIcon: Icon(Icons.category_rounded)),
                      dropdownColor: AppColors.surfaceDark,
                      items: [
                        'X-ray',
                        'ECG',
                        'Blood test report',
                        'Scan report',
                        'CT report',
                        'MRI report',
                        'Ultrasound report',
                        'Other medical documents',
                      ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => reportType = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Report Title / Description', prefixIcon: Icon(Icons.title_rounded)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: hospitalCtrl,
                      decoration: const InputDecoration(labelText: 'Issuing Hospital / Diagnostic Lab', prefixIcon: Icon(Icons.business_rounded)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: doctorCtrl,
                      decoration: const InputDecoration(labelText: 'Consultant / Radiologist', prefixIcon: Icon(Icons.person_outline_rounded)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(labelText: 'User Clinical Notes', prefixIcon: Icon(Icons.notes_rounded)),
                    ),
                    const SizedBox(height: 16),
                    // Simulated File Picker Badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarkElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.attach_file_rounded, color: AppColors.accent),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'miot_echo_scan_vitals_report.pdf (Attached Demo File)',
                              style: TextStyle(fontSize: 11.5, color: Colors.white70),
                            ),
                          ),
                          Icon(Icons.check_circle_rounded, color: AppColors.statusNormal, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'Upload & Generate AI Explanation',
                      onPressed: () {
                        if (titleCtrl.text.isNotEmpty) {
                          final explanation = _recordService.generateExplanationForUpload(
                            documentType: reportType,
                            userNotes: notesCtrl.text.trim(),
                            hospital: hospitalCtrl.text.trim(),
                            doctor: doctorCtrl.text.trim(),
                          );

                          final doc = MedicalDocument(
                            id: 'DOC-${DateTime.now().millisecondsSinceEpoch % 10000}',
                            title: titleCtrl.text.trim(),
                            documentType: reportType,
                            fileUrl: 'demo_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
                            uploadDate: DateTime.now(),
                            checkupDate: DateTime.now(),
                            hospital: hospitalCtrl.text.trim(),
                            doctor: doctorCtrl.text.trim(),
                            userNotes: notesCtrl.text.trim(),
                            aiExplanation: explanation,
                          );

                          _recordService.addDocument(doc);
                          Navigator.pop(ctx);
                          _showAiExplanationModal(context, explanation);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// C. Prescription Upload modal
  void _showUploadPrescriptionDialog() {
    final doctorCtrl = TextEditingController(text: 'Dr. Arvind Swaminathan (MD, DM)');
    final hospitalCtrl = TextEditingController(text: 'Apollo Hospitals, Greams Road, Chennai');
    final notesCtrl = TextEditingController(text: 'Updated hypertension follow-up regimen.');
    final medNameCtrl = TextEditingController(text: 'Telmisartan');
    final dosageCtrl = TextEditingController(text: '40 mg (1 Tablet)');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Upload Doctor Prescription', style: AppTextStyles.headline.copyWith(color: Colors.white)),
                const SizedBox(height: 14),
                TextField(
                  controller: hospitalCtrl,
                  decoration: const InputDecoration(labelText: 'Hospital / Clinic', prefixIcon: Icon(Icons.local_hospital_rounded)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: doctorCtrl,
                  decoration: const InputDecoration(labelText: 'Prescribing Physician', prefixIcon: Icon(Icons.person_rounded)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Prescription Notes', prefixIcon: Icon(Icons.notes_rounded)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: medNameCtrl,
                  decoration: const InputDecoration(labelText: 'Prescribed Medicine Name', prefixIcon: Icon(Icons.medication_rounded)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dosageCtrl,
                  decoration: const InputDecoration(labelText: 'Dosage & Intake Instructions', prefixIcon: Icon(Icons.schedule_rounded)),
                ),
                const SizedBox(height: 18),
                CustomButton(
                  label: 'Save Prescription & Sync Medication',
                  onPressed: () {
                    final newMed = MedicineRecord(
                      id: 'MED-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      name: medNameCtrl.text.trim(),
                      dosage: dosageCtrl.text.trim(),
                      frequency: 'Once daily after breakfast',
                      startDate: DateTime.now(),
                      doctorReference: doctorCtrl.text.trim(),
                      reminderTime: '08:00 AM',
                    );

                    final pres = PrescriptionRecord(
                      id: 'RX-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      doctorName: doctorCtrl.text.trim(),
                      hospitalName: hospitalCtrl.text.trim(),
                      prescriptionDate: DateTime.now(),
                      notes: notesCtrl.text.trim(),
                      medicines: [newMed],
                    );

                    _recordService.addPrescription(pres);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Prescription saved and added to Medication Schedule!'),
                        backgroundColor: AppColors.statusNormal,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// D. Medicine / Tablet Record modal
  void _showAddMedicineDialog() {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController(text: '1 Tablet');
    final freqCtrl = TextEditingController(text: 'Once daily after meals');
    final timeCtrl = TextEditingController(text: '09:00 AM');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add Medicine / Tablet Record', style: AppTextStyles.headline.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text('Enter manually or link with doctor prescription.', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Medicine Name', hintText: 'e.g. Lisinopril', prefixIcon: Icon(Icons.medication_rounded)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dosageCtrl,
                  decoration: const InputDecoration(labelText: 'Dosage', prefixIcon: Icon(Icons.fitness_center_rounded)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: freqCtrl,
                  decoration: const InputDecoration(labelText: 'Frequency', prefixIcon: Icon(Icons.repeat_rounded)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: timeCtrl,
                  decoration: const InputDecoration(labelText: 'Reminder Time', prefixIcon: Icon(Icons.alarm_rounded)),
                ),
                const SizedBox(height: 18),
                CustomButton(
                  label: 'Save Medicine & Link with Medication Page',
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      final med = MedicineRecord(
                        id: 'MED-${DateTime.now().millisecondsSinceEpoch % 10000}',
                        name: nameCtrl.text.trim(),
                        dosage: dosageCtrl.text.trim(),
                        frequency: freqCtrl.text.trim(),
                        startDate: DateTime.now(),
                        reminderTime: timeCtrl.text.trim(),
                      );
                      _recordService.addMedicine(med);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"${med.name}" saved and synced with MedicationPage!'),
                          backgroundColor: AppColors.statusNormal,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// E. AI-Assisted Document Explanation Modal Sheet
  void _showAiExplanationModal(BuildContext context, AiDocumentExplanation rawExplanation) {
    final explanation = LocalizationService.instance.getLocalizedAiExplanation(rawExplanation);
    final loc = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorderDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.accent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.aiDocumentExplanationTitle, style: AppTextStyles.title.copyWith(fontSize: 15)),
                          Text(explanation.documentType, style: AppTextStyles.caption.copyWith(color: AppColors.accent, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: explanation.trend.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: explanation.trend.color),
                      ),
                      child: Text(
                        explanation.trend.label,
                        style: TextStyle(color: explanation.trend.color, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Summary
                Text(loc.plainLanguageSummary, style: AppTextStyles.title.copyWith(fontSize: 13.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDarkElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorderDark.withOpacity(0.6)),
                  ),
                  child: Text(
                    explanation.summary,
                    style: AppTextStyles.body.copyWith(fontSize: 13, height: 1.4),
                  ),
                ),
                const SizedBox(height: 16),

                // Simplified Medical Terms
                if (explanation.simplifiedTerms.isNotEmpty) ...[
                  Text(loc.simplifiedMedicalTerms, style: AppTextStyles.title.copyWith(fontSize: 13.5)),
                  const SizedBox(height: 6),
                  ...explanation.simplifiedTerms.entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarkElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ${entry.key}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(entry.value, style: const TextStyle(color: AppColors.textLight, fontSize: 11.5)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // Comparison with prior
                Text(loc.comparisonWithPriorRecords, style: AppTextStyles.title.copyWith(fontSize: 13.5)),
                const SizedBox(height: 6),
                Text(explanation.comparisonNotes, style: AppTextStyles.body.copyWith(fontSize: 12.5, height: 1.35)),
                const SizedBox(height: 18),

                // MANDATORY SAFETY DISCLAIMER
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1B10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.statusWarning.withOpacity(0.6)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.statusWarning, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          explanation.safetyDisclaimer,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFFD166),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: 'Close Explanation',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSafetyInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Patient Health Journey Info'),
        content: const Text(
          'This module allows continuous tracking of your medical consultations, reports, scans, and prescriptions. All AI summaries are for informational purposes only and do not replace licensed clinical diagnoses.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for rendering continuous health trends with labels and grid
class _TrendChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color lineColor;
  final double minVal;
  final double maxVal;
  final double range;
  final String unit;

  _TrendChartPainter({
    required this.values,
    required this.labels,
    required this.lineColor,
    required this.minVal,
    required this.maxVal,
    required this.range,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..shader = LinearGradient(
        colors: [lineColor.withOpacity(0.28), lineColor.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paintDot = Paint()..color = lineColor;

    final double stepX = size.width / (values.length - 1);
    const double paddingY = 16.0;
    final double usableHeight = size.height - (paddingY * 2);

    final path = Path();
    final fillPath = Path();

    List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final norm = (values[i] - minVal) / range;
      final y = size.height - paddingY - (norm * usableHeight);
      final x = i * stepX;
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Draw dots and value labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 3.5, paintDot);

      // Label below
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 9.5, color: AppColors.textMutedLight),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(points[i].dx - (textPainter.width / 2), size.height - 12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) => true;
}
