import 'package:intl/intl.dart';

class FormatUtils {
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours시간 $minutes분';
    }
    final secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes분 $secs초';
    }
    return '$secs초';
  }

  static String formatDurationTimer(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  static String formatDurationShort(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  static String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toInt()} m';
  }

  static String formatDistanceKm(double km) {
    return '${km.toStringAsFixed(1)} km';
  }

  static String formatSteps(int steps) {
    return NumberFormat('#,###').format(steps);
  }

  static String formatCalories(double cal) {
    return '${cal.toInt()} kcal';
  }

  static String formatPace(double metersPerSecond) {
    if (metersPerSecond <= 0) return "0'00\"";
    final paceSecondsPerKm = 1000 / metersPerSecond;
    final minutes = paceSecondsPerKm ~/ 60;
    final seconds = (paceSecondsPerKm % 60).toInt();
    return "$minutes'${seconds.toString().padLeft(2, '0')}\"";
  }
}
