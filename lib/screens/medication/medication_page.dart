import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/medication_model.dart';
import '../../services/medication_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/language_selector_sheet.dart';

/// Screen 8: MedicationPage
/// Prescription adherence tracker with scheduled timings and toggleable status.
class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final MedicationService _medicationService = MedicationService();

  void _toggleMedication(int index) {
    _medicationService.toggleMedication(index);
    final medications = _medicationService.medications;
    if (index >= 0 && index < medications.length) {
      final updated = medications[index];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.isTaken
                ? 'Marked "${updated.name}" as taken!'
                : 'Marked "${updated.name}" as pending.',
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: updated.isTaken ? AppColors.statusNormal : AppColors.primaryDark,
        ),
      );
    }
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final timeController = TextEditingController(text: '02:00 PM');
    final instructionsController = TextEditingController(text: 'Take with water');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Medication',
                style: AppTextStyles.headline.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  hintText: 'e.g. Lisinopril',
                  prefixIcon: Icon(Icons.medication_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g. 10 mg (1 Tablet)',
                  prefixIcon: Icon(Icons.fitness_center_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Scheduled Time',
                  hintText: 'e.g. 09:00 AM',
                  prefixIcon: Icon(Icons.schedule_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  hintText: 'e.g. Take before breakfast',
                  prefixIcon: Icon(Icons.info_outline_rounded),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                label: 'Save Medication Reminder',
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    _medicationService.addMedication(
                      Medication(
                        id: 'MED-${DateTime.now().millisecondsSinceEpoch % 1000}',
                        name: nameController.text.trim(),
                        dosage: dosageController.text.trim().isEmpty
                            ? '1 Dose'
                            : dosageController.text.trim(),
                        scheduledTime: timeController.text.trim(),
                        instructions: instructionsController.text.trim(),
                        isTaken: false,
                        category: 'Daily',
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _medicationService,
      builder: (context, _) {
        final medications = _medicationService.medications;
        final takenCount = medications.where((m) => m.isTaken).length;
        final totalCount = medications.length;
        final progress = totalCount > 0 ? (takenCount / totalCount) : 0.0;

        final loc = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            title: Text(loc.medicationSchedule),
            actions: [
              IconButton(
                tooltip: loc.selectLanguage,
                icon: const Icon(Icons.translate_rounded),
                onPressed: () => LanguageSelectorSheet.show(context),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(loc.addMedicine, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: _showAddMedicationDialog,
          ),
          body: SafeArea(
            child: Column(
              children: [
                const DemoBanner(
                  message: 'PRESCRIPTION COMPANION • LOCAL DEMO SCHEDULE',
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      // Adherence Progress Card
                      _buildProgressCard(takenCount, totalCount, progress),

                      const SizedBox(height: 16),

                      Text(
                        loc.activePrescriptions,
                        style: AppTextStyles.title.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),

                      ...List.generate(medications.length, (index) {
                        final med = medications[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () => _toggleMedication(index),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Checkbox / Taken Status
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: med.isTaken
                                          ? AppColors.statusNormal
                                          : AppColors.surfaceDarkElevated,
                                      border: Border.all(
                                        color: med.isTaken
                                            ? AppColors.statusNormal
                                            : AppColors.cardBorderDark,
                                        width: 2,
                                      ),
                                    ),
                                    child: med.isTaken
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 20,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 14),

                                  // Medicine Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              med.name,
                                              style: AppTextStyles.title.copyWith(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                decoration: med.isTaken
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                color: med.isTaken
                                                    ? AppColors.textMutedLight
                                                    : AppColors.textLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${med.dosage} • ${med.instructions}',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textMutedLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Time Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceDarkElevated,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.cardBorderDark),
                                    ),
                                    child: Text(
                                      med.scheduledTime,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 80), // Padding for FAB
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(int taken, int total, double progress) {
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
                  'Daily Adherence Score',
                  style: AppTextStyles.title.copyWith(fontSize: 15),
                ),
                Text(
                  '$taken of $total Taken (${(progress * 100).toInt()}%)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.statusNormal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: AppColors.surfaceDarkElevated,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.statusNormal),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progress == 1.0
                  ? 'All scheduled prescriptions completed for today!'
                  : 'Tap any medication card to toggle taken status.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMutedLight),
            ),
          ],
        ),
      ),
    );
  }
}
