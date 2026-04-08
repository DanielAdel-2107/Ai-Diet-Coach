import 'package:ai_diet_coach/features/patient/sugar_device/view_models/sugar_device_cubit/sugar_device_cubit.dart';
import 'package:ai_diet_coach/features/patient/sugar_device/views/widgets/sugar_device_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ai_diet_coach/core/network/bluetooth/bluetooth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SugarDeviceScreen extends StatelessWidget {
  const SugarDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SugarDeviceCubit(
        GetIt.I<BaseBluetoothService>(),
        GetIt.I<SupabaseClient>(),
      )..startScan(),
      child: const Scaffold(
        body: SugarDeviceBody(),
      ),
    );
  }
}
