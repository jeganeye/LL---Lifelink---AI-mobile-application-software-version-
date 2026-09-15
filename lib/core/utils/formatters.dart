/// Formatting helpers for timestamps and telemetry readings.
class Formatters {
  Formatters._();

  /// Formats DateTime as HH:mm:ss
  static String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Formats DateTime as readable date (e.g., "06 Sep 2026")
  static String formatDate(DateTime time) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = time.day.toString().padLeft(2, '0');
    final month = months[time.month - 1];
    final year = time.year.toString();
    return '$day $month $year';
  }

  /// Formats DateTime as readable date and time (e.g., "06 Sep 2026 10:30 AM")
  static String formatDateTime(DateTime time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final hour12 = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final hour = hour12.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '${formatDate(time)}, $hour:$minute $period';
  }

  /// Formats relative time (e.g. "Just now", "2m ago")
  static String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 30) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Backward compatible alias for date formatting across clinical modules
class AppDateFormatter {
  AppDateFormatter._();
  static String formatDate(DateTime time) => Formatters.formatDate(time);
  static String formatDateTime(DateTime time) => Formatters.formatDateTime(time);
  static String formatTime(DateTime time) => Formatters.formatTime(time);
}

