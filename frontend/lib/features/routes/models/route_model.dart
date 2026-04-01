class RouteModel {
  final String id;
  final String name;
  final String? description;
  final double? distanceKm;
  final int? durationMin;
  final String? difficulty;
  final bool isPublic;
  final bool isCustom;
  final String source;
  final String? thumbnailUrl;
  final RouteCreator? creator;
  final List<RouteWaypointModel> waypoints;
  final DateTime? createdAt;

  const RouteModel({
    required this.id,
    required this.name,
    this.description,
    this.distanceKm,
    this.durationMin,
    this.difficulty,
    required this.isPublic,
    required this.isCustom,
    required this.source,
    this.thumbnailUrl,
    this.creator,
    required this.waypoints,
    this.createdAt,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        durationMin: json['durationMin'] as int?,
        difficulty: json['difficulty'] as String?,
        isPublic: json['isPublic'] as bool? ?? true,
        isCustom: json['isCustom'] as bool? ?? false,
        source: json['source'] as String? ?? 'user',
        thumbnailUrl: json['thumbnailUrl'] as String?,
        creator: json['creator'] != null
            ? RouteCreator.fromJson(json['creator'] as Map<String, dynamic>)
            : null,
        waypoints: (json['waypoints'] as List<dynamic>? ?? [])
            .map((w) => RouteWaypointModel.fromJson(w as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  String get difficultyLabel {
    return switch (difficulty) {
      'easy' => '쉬움',
      'medium' => '보통',
      'hard' => '어려움',
      _ => '-',
    };
  }

  String get distanceLabel {
    if (distanceKm == null) return '-';
    return '${distanceKm!.toStringAsFixed(1)}km';
  }

  String get durationLabel {
    if (durationMin == null) return '-';
    if (durationMin! >= 60) {
      final h = durationMin! ~/ 60;
      final m = durationMin! % 60;
      return m == 0 ? '${h}시간' : '${h}시간 ${m}분';
    }
    return '${durationMin}분';
  }
}

class RouteCreator {
  final String id;
  final String? name;
  final String? profileImageUrl;

  const RouteCreator({required this.id, this.name, this.profileImageUrl});

  factory RouteCreator.fromJson(Map<String, dynamic> json) => RouteCreator(
        id: json['id'] as String,
        name: json['name'] as String?,
        profileImageUrl: json['profileImageUrl'] as String?,
      );
}

class RouteWaypointModel {
  final double latitude;
  final double longitude;
  final int sequenceOrder;
  final String? pointName;

  const RouteWaypointModel({
    required this.latitude,
    required this.longitude,
    required this.sequenceOrder,
    this.pointName,
  });

  factory RouteWaypointModel.fromJson(Map<String, dynamic> json) =>
      RouteWaypointModel(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        sequenceOrder: json['sequenceOrder'] as int,
        pointName: json['pointName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'pointName': pointName,
      };
}
