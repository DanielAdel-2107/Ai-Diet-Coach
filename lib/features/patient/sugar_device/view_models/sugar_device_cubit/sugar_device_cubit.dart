import 'dart:async';
import 'package:ai_diet_coach/core/network/bluetooth/bluetooth_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:ai_diet_coach/features/patient/sugar_device/models/sugar_device_model.dart';
import 'package:ai_diet_coach/features/patient/sugar_device/view_models/sugar_device_cubit/sugar_device_state.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/models/sugar_level_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SugarDeviceCubit extends Cubit<SugarDeviceState> {
  final BaseBluetoothService _bluetoothService;
  final SupabaseClient _supabase;
  StreamSubscription? _scanSubscription;
  bool _isSimulation = false;

  SugarDeviceCubit(this._bluetoothService, this._supabase) : super(SugarDeviceInitial());

  void toggleSimulation(bool value) {
    _isSimulation = value;
    emit(SugarDeviceInitial());
  }

  Future<void> startScan() async {
    emit(SugarDeviceScanning(devices: []));
    
    if (_isSimulation) {
      await Future.delayed(const Duration(seconds: 1));
      emit(SugarDeviceScanning(devices: [
        SugarDeviceModel(
          id: "SIM-01",
          name: "Glucometer X100 (Simulated)",
          rssi: -45,
          device: _mockDevice("SIM-01", "Glucometer X100"),
        ),
        SugarDeviceModel(
          id: "SIM-02",
          name: "Dexcom G6 (Simulated)",
          rssi: -60,
          device: _mockDevice("SIM-02", "Dexcom G6"),
        ),
      ]));
      return;
    }

    await _bluetoothService.startScan();
    _scanSubscription = _bluetoothService.scanResults.listen((results) {
      final devices = results
          .map((r) => SugarDeviceModel.fromScanResult(r))
          .where((d) => d.name.toLowerCase().contains("glucose") || 
                        d.name.toLowerCase().contains("gluco") ||
                        d.name.toLowerCase().contains("dexcom"))
          .toList();
      emit(SugarDeviceScanning(devices: devices));
    });
  }

  Future<void> connect(SugarDeviceModel device) async {
    emit(SugarDeviceConnecting(device.name));
    try {
      if (!_isSimulation) {
        await _bluetoothService.connect(device.device);
            } else {
        await Future.delayed(const Duration(seconds: 1));
      }
      emit(SugarDeviceConnected(device.name));
    } catch (e) {
      emit(SugarDeviceError("Failed to connect: ${e.toString()}"));
    }
  }

  Future<void> syncData() async {
    emit(SugarDeviceSyncing());
    try {
      final readings = await _bluetoothService.readGlucoseData();
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("User not authenticated");

      for (var reading in readings) {
        final entry = SugarLevelModel(
          id: const Uuid().v4(),
          userId: userId,
          level: reading,
          mealTag: "after_meal", // Default from device
          createdAt: DateTime.now(),
        );
        await _supabase.from('sugar_levels').insert(entry.toJson());
      }

      emit(SugarDeviceSyncSuccess(readings));
    } catch (e) {
      emit(SugarDeviceError("Sync failed: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }

  // Helper for mock device
  dynamic _mockDevice(String id, String name) {
    // This is just a placeholder since we won't actually call methods on it in simulation mode
    return null; 
  }
}
