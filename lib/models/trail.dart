enum TrailDifficulty { easy, moderate, hard }

class Trail {
  final String id;
  final String name;
  final String description;
  final String imageAsset;
  final double distanceKm;
  final int estimatedMinutes;
  final TrailDifficulty difficulty;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final List<double> routePoints;
  final double elevationGain;
  final String location;
  final List<TrailReview> reviews;

  const Trail({
    required this.id,
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.difficulty,
    this.tags = const [],
    this.rating = 4.5,
    this.reviewCount = 0,
    this.routePoints = const [],
    this.elevationGain = 0,
    this.location = '',
    this.reviews = const [],
  });

  String get difficultyText {
    switch (difficulty) {
      case TrailDifficulty.easy:
        return '쉬움';
      case TrailDifficulty.moderate:
        return '보통';
      case TrailDifficulty.hard:
        return '어려움';
    }
  }

  String get difficultyEnglish {
    switch (difficulty) {
      case TrailDifficulty.easy:
        return 'Easy';
      case TrailDifficulty.moderate:
        return 'Moderate';
      case TrailDifficulty.hard:
        return 'Hard';
    }
  }

  String get estimatedTimeText {
    if (estimatedMinutes >= 60) {
      final h = estimatedMinutes ~/ 60;
      final m = estimatedMinutes % 60;
      return m > 0 ? '${h}시간 ${m}분' : '${h}시간';
    }
    return '${estimatedMinutes}분';
  }
}

class TrailReview {
  final String userName;
  final String content;
  final double rating;
  final DateTime date;

  const TrailReview({
    required this.userName,
    required this.content,
    required this.rating,
    required this.date,
  });
}
