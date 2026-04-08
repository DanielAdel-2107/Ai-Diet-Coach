import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SugarDeviceModel {
  final String id;
  final String name;
  final int rssi;
  final BluetoothDevice device;

  SugarDeviceModel({
    required this.id,
    required this.name,
    required this.rssi,
    required this.device,
  });

  factory SugarDeviceModel.fromScanResult(ScanResult result) {
    return SugarDeviceModel(
      id: result.device.remoteId.str,
      name: result.device.platformName.isEmpty ? "Unnamed Device" : result.device.platformName,
      rssi: result.rssi,
      device: result.device,
    );
  }
}
