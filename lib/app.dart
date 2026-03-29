import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkaround/core/theme/app_theme.dart';
import 'package:walkaround/providers/trail_provider.dart';
import 'package:walkaround/providers/walk_tracking_provider.dart';
import 'package:walkaround/providers/walk_history_provider.dart';
import 'package:walkaround/providers/profile_provider.dart';
import 'package:walkaround/screens/main_screen.dart';

class WalkAroundApp extends StatelessWidget {
  const WalkAroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => TrailProvider()),
        ChangeNotifierProvider(create: (_) => WalkHistoryProvider()),
        ChangeNotifierProvider(create: (_) => WalkTrackingProvider()),
      ],
      child: MaterialApp(
        title: '걸어볼까',
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
