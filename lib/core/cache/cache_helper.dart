import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  //! Initialize the cache
  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  //! Save basic types
  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is bool) {
      return await sharedPreferences.setBool(key, value);
    } else if (value is String) {
      return await sharedPreferences.setString(key, value);
    } else if (value is int) {
      return await sharedPreferences.setInt(key, value);
    } else if (value is double) {
      return await sharedPreferences.setDouble(key, value);
    } else {
      throw Exception('Unsupported type');
    }
  }

  dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  String? getDataString({required String key}) {
    return sharedPreferences.getString(key);
  }

  Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  Future<bool> clearData() async {
    return await sharedPreferences.clear();
  }

  Future<bool> containsKey({required String key}) async {
    return sharedPreferences.containsKey(key);
  }

  //! Save saveLastEcgRecordTrips in local storage
  Future<bool> saveLastEcgRecordTrips(String ecgTrips) async {
    final ecgJson = jsonEncode(ecgTrips);
    return await sharedPreferences.setString('ecg_sample_trips', ecgJson);
  }

  // //! Get lastEcgRecordTrips from local storage
  String? getLastEcgRecordTrips() {
    return sharedPreferences.getString('ecg_sample_trips');
  }

// //! Save UserModel in local storage
//   Future<bool> saveUserModel(UserModel customer) async {
//     final customerJson = jsonEncode(customer.toJson());
//     return await sharedPreferences.setString('user', customerJson);
//   }
// //! Get UserModel from local storage
//   UserModel? getUserModel() {
//     final customerJson = sharedPreferences.getString('user');
//     if (customerJson == null) return null;
//     final Map<String, dynamic> decodedJson = jsonDecode(customerJson);
//     return UserModel.fromJson(decodedJson);
//   }
}
