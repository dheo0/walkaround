import 'package:flutter/material.dart';
import 'package:walkaround/app.dart';
import 'package:walkaround/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initialize();
  runApp(const WalkAroundApp());
}
