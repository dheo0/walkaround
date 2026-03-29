import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy년 M월 d일').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('M/d').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('a h:mm', 'ko').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('M월 d일 a h:mm', 'ko').format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    if (diff < 7) return '$diff일 전';
    if (diff < 30) return '${diff ~/ 7}주 전';
    return formatDate(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));
    return date.isAfter(start) && date.isBefore(end);
  }

  static String getWeekDayName(int weekday) {
    const names = ['월', '화', '수', '목', '금', '토', '일'];
    return names[(weekday - 1) % 7];
  }

  static DateTime getStartOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }
}
