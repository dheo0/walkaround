import 'package:walkaround/models/walk_record.dart';

class DailySummary {
  final DateTime date;
  final int totalSteps;
  final double totalDistanceKm;
  final int totalDurationMinutes;
  final double totalCalories;
  final int walkCount;

  const DailySummary({
    required this.date,
    this.totalSteps = 0,
    this.totalDistanceKm = 0,
    this.totalDurationMinutes = 0,
    this.totalCalories = 0,
    this.walkCount = 0,
  });

  factory DailySummary.fromWalks(DateTime date, List<WalkRecord> walks) {
    if (walks.isEmpty) {
      return DailySummary(date: date);
    }
    return DailySummary(
      date: date,
      totalSteps: walks.fold(0, (sum, w) => sum + w.steps),
      totalDistanceKm:
          walks.fold(0.0, (sum, w) => sum + w.distanceMeters) / 1000,
      totalDurationMinutes:
          walks.fold(0, (sum, w) => sum + w.durationSeconds) ~/ 60,
      totalCalories: walks.fold(0.0, (sum, w) => sum + w.caloriesBurned),
      walkCount: walks.length,
    );
  }
}
