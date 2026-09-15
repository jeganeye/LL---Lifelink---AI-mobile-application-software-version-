import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../models/notification_model.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/language_selector_sheet.dart';

/// Screen 9: NotificationsPage
/// Multi-category alert center for:
/// - Health warnings
/// - Emergency alerts
/// - Medication reminders
/// - Wearable connection alerts
/// - Device battery status
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = NotificationItem.getDemoNotifications();
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((item) => NotificationItem(
                id: item.id,
                title: item.title,
                message: item.message,
                timestamp: item.timestamp,
                type: item.type,
                isRead: true,
              ))
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(loc.notificationsCenter),
        actions: [
          IconButton(
            tooltip: loc.selectLanguage,
            icon: const Icon(Icons.translate_rounded),
            onPressed: () => LanguageSelectorSheet.show(context),
          ),
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark All Read',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(
              message: 'NOTIFICATION CENTER • DEMO HEALTH & SYSTEM ALERTS',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Category breakdown pills
                  _buildCategoryPills(),

                  const SizedBox(height: 12),

                  ..._notifications.map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: item.isRead
                              ? null
                              : Border.all(color: item.color.withOpacity(0.5), width: 1.2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: item.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: item.color.withOpacity(0.3)),
                                ),
                                child: Icon(item.icon, color: item.color, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: AppTextStyles.title.copyWith(
                                              fontSize: 14,
                                              fontWeight: item.isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (!item.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.message,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textMutedLight,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      Formatters.timeAgo(item.timestamp),
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.accent,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPill('All (5)', AppColors.accent, isSelected: true),
          _buildPill('Health (1)', AppColors.heartRate),
          _buildPill('Emergency (1)', AppColors.statusEmergency),
          _buildPill('Meds (1)', AppColors.primaryLight),
          _buildPill('Hardware (2)', AppColors.statusNormal),
        ],
      ),
    );
  }

  Widget _buildPill(String label, Color color, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : AppColors.cardBorderDark,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? color : AppColors.textMutedLight,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
