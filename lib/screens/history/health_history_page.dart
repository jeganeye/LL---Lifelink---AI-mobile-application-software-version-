import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../services/health_data_service.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/language_selector_sheet.dart';
import '../../widgets/risk_badge.dart';

/// Screen 7: HealthHistoryPage
/// Displays historical telemetry logs, daily/weekly trend cards, and visual sparklines.
class HealthHistoryPage extends StatefulWidget {
  const HealthHistoryPage({super.key});

  @override
  State<HealthHistoryPage> createState() => _HealthHistoryPageState();
}

class _HealthHistoryPageState extends State<HealthHistoryPage> {
  final HealthDataService _healthService = HealthDataService();
  int _selectedFilterIndex = 0; // 0: All, 1: Heart Rate, 2: SpO2, 3: Risk Events

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(loc.healthHistory),
        actions: [
          IconButton(
            tooltip: loc.selectLanguage,
            icon: const Icon(Icons.translate_rounded),
            onPressed: () => LanguageSelectorSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(
              message: 'HISTORICAL LOGS • SIMULATED 7-DAY VITALS DATA',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Weekly Summary Cards
                  _buildWeeklySummaryGrid(),

                  const SizedBox(height: 16),

                  // Trend Sparkline Visualizers
                  _buildTrendVisualizerCard(
                    title: '7-Day Resting Heart Rate Trend',
                    currentAvg: '74 BPM',
                    unit: 'Avg',
                    color: AppColors.heartRate,
                    points: const [72, 75, 78, 74, 76, 73, 74],
                    labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  ),

                  const SizedBox(height: 12),

                  _buildTrendVisualizerCard(
                    title: '7-Day Blood Oxygen (SpO2) Stability',
                    currentAvg: '98.2%',
                    unit: 'Avg',
                    color: AppColors.spo2,
                    points: const [98, 97, 98, 99, 98, 97, 98],
                    labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  ),

                  const SizedBox(height: 16),

                  // Filter Chips
                  _buildFilterChips(),

                  const SizedBox(height: 12),

                  // Telemetry Log List
                  _buildTelemetryHistoryList(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Health Averages',
          style: AppTextStyles.title.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMiniStat(
                label: 'Avg Heart Rate',
                value: '74',
                unit: 'BPM',
                icon: Icons.favorite_rounded,
                color: AppColors.heartRate,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStat(
                label: 'Avg SpO2',
                value: '98.2',
                unit: '%',
                icon: Icons.water_drop_rounded,
                color: AppColors.spo2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMiniStat(
                label: 'Avg Body Temp',
                value: '36.6',
                unit: '°C',
                icon: Icons.thermostat_rounded,
                color: AppColors.temperature,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStat(
                label: 'Air Quality Days',
                value: '6/7',
                unit: 'Good',
                icon: Icons.eco_rounded,
                color: AppColors.statusNormal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
                RichText(
                  text: TextSpan(
                    text: value,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: ' $unit',
                        style: AppTextStyles.caption.copyWith(
                          color: color,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendVisualizerCard({
    required String title,
    required String currentAvg,
    required String unit,
    required Color color,
    required List<double> points,
    required List<String> labels,
  }) {
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
                  title,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  '$currentAvg ($unit)',
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: CustomPaint(
                painter: _SparklinePainter(points: points, lineColor: color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels
                  .map((l) => Text(l, style: AppTextStyles.caption.copyWith(fontSize: 10)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = ['All Vitals', 'Heart Rate', 'SpO2', 'Risk Events'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceDark,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMutedLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTelemetryHistoryList() {
    final history = _healthService.history;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recorded Telemetry Snapshots',
          style: AppTextStyles.title.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...history.map((reading) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDarkElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.history_toggle_off_rounded,
                        color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${reading.heartRate.toInt()} BPM',
                              style: const TextStyle(
                                  color: AppColors.heartRate,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${reading.spo2.toInt()}% SpO2',
                              style: const TextStyle(
                                  color: AppColors.spo2,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${reading.temperature}°C',
                              style: const TextStyle(
                                  color: AppColors.temperature,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${Formatters.formatDate(reading.timestamp)} at ${Formatters.formatTime(reading.timestamp)} • ${reading.activity}',
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  RiskBadge(status: reading.riskStatus, isCompact: true),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;

  _SparklinePainter({required this.points, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [lineColor.withOpacity(0.3), lineColor.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final dx = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = size.height - ((points[i] - minVal) / range) * (size.height * 0.8) - 6;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw dot
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = lineColor,
      );
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
