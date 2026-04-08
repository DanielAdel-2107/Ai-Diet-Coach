import 'package:ai_diet_coach/core/di/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:ai_diet_coach/core/local_notifications/local_notifications_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:device_preview/device_preview.dart';
import 'package:ai_diet_coach/app/my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> clearOldCacheIfNeeded() async {
  final prefs = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.buildNumber;

  final savedVersion = prefs.getString('last_version');

  if (savedVersion != currentVersion) {
    await DefaultCacheManager().emptyCache();
    await prefs.setString('last_version', currentVersion);
    debugPrint("✅ Old cache cleared due to app update.");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://uimxkrazhlmuqopiowuv.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpbXhrcmF6aGxtdXFvcGlvd3V2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwNTc1MjksImV4cCI6MjA4ODYzMzUyOX0.hyYpPCIFEULEAVG5dSgdgn6A9pxZ7qRhalF0z9A6xnA",
  );
  await setupDI();
  await clearOldCacheIfNeeded();
  await LocalNotificationsServices.init();
  runApp(DevicePreview(enabled: false, builder: (context) => MyApp()));
  CustomQuickAlert.initialize(navigatorKey);
}
