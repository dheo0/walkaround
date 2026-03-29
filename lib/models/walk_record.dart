import 'package:hive/hive.dart';

class WalkRecord {
  final String id;
  final String? trailId;
  final String? trailName;
  final DateTime startTime;
  final DateTime? endTime;
  final int steps;
  final double distanceMeters;
  final int durationSeconds;
  final double caloriesBurned;
  final List<double> routePoints;
  final bool isCompleted;

  WalkRecord({
    required this.id,
    this.trailId,
    this.trailName,
    required this.startTime,
    this.endTime,
    this.steps = 0,
    this.distanceMeters = 0,
    this.durationSeconds = 0,
    this.caloriesBurned = 0,
    this.routePoints = const [],
    this.isCompleted = false,
  });

  double get distanceKm => distanceMeters / 1000;

  double get averageSpeedKmH {
    if (durationSeconds == 0) return 0;
    return (distanceMeters / 1000) / (durationSeconds / 3600);
  }

  WalkRecord copyWith({
    String? id,
    String? trailId,
    String? trailName,
    DateTime? startTime,
    DateTime? endTime,
    int? steps,
    double? distanceMeters,
    int? durationSeconds,
    double? caloriesBurned,
    List<double>? routePoints,
    bool? isCompleted,
  }) {
    return WalkRecord(
      id: id ?? this.id,
      trailId: trailId ?? this.trailId,
      trailName: trailName ?? this.trailName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      steps: steps ?? this.steps,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      routePoints: routePoints ?? this.routePoints,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class WalkRecordAdapter extends TypeAdapter<WalkRecord> {
  @override
  final int typeId = 0;

  @override
  WalkRecord read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return WalkRecord(
      id: fields[0] as String,
      trailId: fields[1] as String?,
      trailName: fields[2] as String?,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime?,
      steps: fields[5] as int,
      distanceMeters: fields[6] as double,
      durationSeconds: fields[7] as int,
      caloriesBurned: fields[8] as double,
      routePoints: (fields[9] as List).cast<double>(),
      isCompleted: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WalkRecord obj) {
    writer.writeByte(11);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.trailId);
    writer.writeByte(2);
    writer.write(obj.trailName);
    writer.writeByte(3);
    writer.write(obj.startTime);
    writer.writeByte(4);
    writer.write(obj.endTime);
    writer.writeByte(5);
    writer.write(obj.steps);
    writer.writeByte(6);
    writer.write(obj.distanceMeters);
    writer.writeByte(7);
    writer.write(obj.durationSeconds);
    writer.writeByte(8);
    writer.write(obj.caloriesBurned);
    writer.writeByte(9);
    writer.write(obj.routePoints);
    writer.writeByte(10);
    writer.write(obj.isCompleted);
  }
}
