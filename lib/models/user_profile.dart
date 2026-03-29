import 'package:hive/hive.dart';
import 'package:walkaround/core/constants/app_constants.dart';

class UserProfile {
  final String name;
  final int dailyStepGoal;
  final double dailyDistanceGoalKm;
  final int dailyTimeGoalMinutes;
  final double heightCm;
  final double weightKg;
  final double totalDistanceKm;
  final int totalSteps;
  final int totalWalks;
  final DateTime joinDate;

  UserProfile({
    required this.name,
    this.dailyStepGoal = AppConstants.defaultStepGoal,
    this.dailyDistanceGoalKm = AppConstants.defaultDistanceGoalKm,
    this.dailyTimeGoalMinutes = AppConstants.defaultTimeGoalMinutes,
    this.heightCm = 170,
    this.weightKg = 65,
    this.totalDistanceKm = 0,
    this.totalSteps = 0,
    this.totalWalks = 0,
    DateTime? joinDate,
  }) : joinDate = joinDate ?? DateTime.now();

  factory UserProfile.defaultProfile() {
    return UserProfile(
      name: '탐험가',
      joinDate: DateTime.now(),
    );
  }

  int get level => AppConstants.getLevelFromDistance(totalDistanceKm);
  String get levelName => AppConstants.getLevelName(level);

  UserProfile copyWith({
    String? name,
    int? dailyStepGoal,
    double? dailyDistanceGoalKm,
    int? dailyTimeGoalMinutes,
    double? heightCm,
    double? weightKg,
    double? totalDistanceKm,
    int? totalSteps,
    int? totalWalks,
    DateTime? joinDate,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      dailyDistanceGoalKm: dailyDistanceGoalKm ?? this.dailyDistanceGoalKm,
      dailyTimeGoalMinutes: dailyTimeGoalMinutes ?? this.dailyTimeGoalMinutes,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalSteps: totalSteps ?? this.totalSteps,
      totalWalks: totalWalks ?? this.totalWalks,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return UserProfile(
      name: fields[0] as String,
      dailyStepGoal: fields[1] as int,
      dailyDistanceGoalKm: fields[2] as double,
      dailyTimeGoalMinutes: fields[3] as int,
      heightCm: fields[4] as double,
      weightKg: fields[5] as double,
      totalDistanceKm: fields[6] as double,
      totalSteps: fields[7] as int,
      totalWalks: fields[8] as int,
      joinDate: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer.writeByte(10);
    writer.writeByte(0);
    writer.write(obj.name);
    writer.writeByte(1);
    writer.write(obj.dailyStepGoal);
    writer.writeByte(2);
    writer.write(obj.dailyDistanceGoalKm);
    writer.writeByte(3);
    writer.write(obj.dailyTimeGoalMinutes);
    writer.writeByte(4);
    writer.write(obj.heightCm);
    writer.writeByte(5);
    writer.write(obj.weightKg);
    writer.writeByte(6);
    writer.write(obj.totalDistanceKm);
    writer.writeByte(7);
    writer.write(obj.totalSteps);
    writer.writeByte(8);
    writer.write(obj.totalWalks);
    writer.writeByte(9);
    writer.write(obj.joinDate);
  }
}
