import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:permission_handler/permission_handler.dart';

abstract class BaseBluetoothService {
  Stream<List<fbp.ScanResult>> get scanResults;
  Stream<fbp.BluetoothConnectionState> get connectionState;
  Future<void> startScan();
  Future<void> stopScan();
  Future<void> connect(fbp.BluetoothDevice device);
  Future<void> disconnect();
  Future<List<double>> readGlucoseData();
}

class FlutterBlueService implements BaseBluetoothService {
  @override
  Stream<List<fbp.ScanResult>> get scanResults =>
      fbp.FlutterBluePlus.scanResults;

  @override
  Stream<fbp.BluetoothConnectionState> get connectionState =>
      _connectedDevice?.connectionState ?? const Stream.empty();

  fbp.BluetoothDevice? _connectedDevice;

  @override
  Future<void> startScan() async {
    bool isBluetoothOn =
        await fbp.FlutterBluePlus.adapterState.first ==
        fbp.BluetoothAdapterState.on;
    if (!isBluetoothOn) {
      // Optionally throw error or try to turn it on
    }

    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.location.request().isGranted) {
      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
  }

  @override
  Future<void> stopScan() async {
    await fbp.FlutterBluePlus.stopScan();
  }

  @override
  Future<void> connect(fbp.BluetoothDevice device) async {
    _connectedDevice = device;
    await device.connect(license: fbp.License.commercial);
  }

  @override
  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
  }

  @override
  Future<List<double>> readGlucoseData() async {
    if (_connectedDevice == null) return [];

    // 1. Await discoverServices()
    List<fbp.BluetoothService> services = await _connectedDevice!
        .discoverServices();

    // Standard Glucose Service UUID: 1808
    final glucoseService = services.firstWhere(
      (s) => s.uuid.toString().toUpperCase().contains("1808"),
      orElse: () => throw Exception("Glucose Service not found"),
    );

    // Standard Glucose Measurement Characteristic UUID: 2A18
    final characteristic = glucoseService.characteristics.firstWhere(
      (c) => c.uuid.toString().toUpperCase().contains("2A18"),
      orElse: () => throw Exception("Glucose Characteristic not found"),
    );

    // In a real device, we would subscribe to notifications or read the value.
    // For now, return a placeholder read.
    await characteristic.read();

    // Parsing logic for IEEE 11073-10417 would go here.
    return [110.0]; // Mock result for real connection
  }
}

class MockBluetoothService implements BaseBluetoothService {
  final _scanController = StreamController<List<fbp.ScanResult>>.broadcast();
  final _connectionController =
      StreamController<fbp.BluetoothConnectionState>.broadcast();

  @override
  Stream<List<fbp.ScanResult>> get scanResults => _scanController.stream;

  @override
  Stream<fbp.BluetoothConnectionState> get connectionState =>
      _connectionController.stream;

  @override
  Future<void> startScan() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate finding NO real device results, as simulation mode
    // in Cubit often hardcodes its own results or expects this to be empty to show hardcoded ones.
    // However, to make it consistent, we could return dummy ScanResults if needed.
    _scanController.add([]);
  }

  @override
  Future<void> stopScan() async => _scanController.add([]);

  @override
  Future<void> connect(fbp.BluetoothDevice device) async {
    _connectionController.add(fbp.BluetoothConnectionState.connecting);
    await Future.delayed(const Duration(seconds: 1));
    _connectionController.add(fbp.BluetoothConnectionState.connected);
  }

  @override
  Future<void> disconnect() async {
    _connectionController.add(fbp.BluetoothConnectionState.disconnected);
  }

  @override
  Future<List<double>> readGlucoseData() async {
    await Future.delayed(const Duration(seconds: 2));
    return [105.0, 115.0, 98.0]; // Return some mock values
  }

  void dispose() {
    _scanController.close();
    _connectionController.close();
  }
}
