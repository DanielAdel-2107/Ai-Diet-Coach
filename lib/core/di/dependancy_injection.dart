import 'package:ai_diet_coach/core/cache/cache_helper.dart';
import 'package:ai_diet_coach/core/network/api/gemini_service.dart';
import 'package:ai_diet_coach/core/network/bluetooth/bluetooth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  final cacheHelper = CacheHelper();
  await cacheHelper.init();
  getIt.registerSingleton<CacheHelper>(cacheHelper);
  getIt.registerLazySingleton(() => Supabase.instance.client);
  getIt.registerLazySingleton<BaseBluetoothService>(() => FlutterBlueService());

  // Register Gemini Service
  getIt.registerLazySingleton<GeminiService>(
    () => GeminiService(apiKey: "[GCP_API_KEY]"),
  );
}
