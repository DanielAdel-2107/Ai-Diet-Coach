import 'package:ai_diet_coach/features/patient/sugar_device/models/sugar_device_model.dart';

abstract class SugarDeviceState {}

class SugarDeviceInitial extends SugarDeviceState {}

class SugarDeviceScanning extends SugarDeviceState {
  final List<SugarDeviceModel> devices;
  SugarDeviceScanning({required this.devices});
}

class SugarDeviceConnecting extends SugarDeviceState {
  final String deviceName;
  SugarDeviceConnecting(this.deviceName);
}

class SugarDeviceConnected extends SugarDeviceState {
  final String deviceName;
  SugarDeviceConnected(this.deviceName);
}

class SugarDeviceSyncing extends SugarDeviceState {}

class SugarDeviceSyncSuccess extends SugarDeviceState {
  final List<double> readings;
  SugarDeviceSyncSuccess(this.readings);
}

class SugarDeviceError extends SugarDeviceState {
  final String message;
  SugarDeviceError(this.message);
}
