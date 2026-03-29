class AppConstants {
  static const String appName = '걸어볼까';
  static const String appSubtitle = 'The Living Map';

  // Hive box names
  static const String walksBox = 'walks';
  static const String profileBox = 'profile';
  static const String settingsBox = 'settings';

  // Default goals
  static const int defaultStepGoal = 10000;
  static const double defaultDistanceGoalKm = 5.0;
  static const int defaultTimeGoalMinutes = 60;

  // Calculation constants
  static const double stepLengthMeters = 0.7;
  static const double caloriesPerStep = 0.04;

  // Level thresholds (total km)
  static const List<double> levelThresholds = [
    0, 10, 30, 60, 100, 200, 350, 500, 750, 1000,
  ];
  static const List<String> levelNames = [
    '초보 탐험가',
    '동네 산책러',
    '도시 탐험가',
    '자연 탐험가',
    '트레일 워커',
    '숲속 여행자',
    '산악 탐험가',
    '대지의 여행자',
    '전설의 탐험가',
    '마스터 워커',
  ];

  static int getLevelFromDistance(double totalKm) {
    for (int i = levelThresholds.length - 1; i >= 0; i--) {
      if (totalKm >= levelThresholds[i]) return i + 1;
    }
    return 1;
  }

  static String getLevelName(int level) {
    if (level < 1 || level > levelNames.length) return levelNames[0];
    return levelNames[level - 1];
  }
}
