import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/sugar_device/view_models/sugar_device_cubit/sugar_device_cubit.dart';
import 'package:ai_diet_coach/features/patient/sugar_device/view_models/sugar_device_cubit/sugar_device_state.dart';
import 'package:animate_do/animate_do.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SugarDeviceBody extends StatefulWidget {
  const SugarDeviceBody({super.key});

  @override
  State<SugarDeviceBody> createState() => _SugarDeviceBodyState();
}

class _SugarDeviceBodyState extends State<SugarDeviceBody> {
  bool _isSimulation = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: Text("Connect Device", style: AppTextStyles.title24BlackBold),
          actions: [
            Switch(
              value: _isSimulation,
              onChanged: (val) {
                setState(() => _isSimulation = val);
                context.read<SugarDeviceCubit>().toggleSimulation(val);
                context.read<SugarDeviceCubit>().startScan();
              },
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
        Expanded(
          child: BlocConsumer<SugarDeviceCubit, SugarDeviceState>(
            listener: (context, state) {
              if (state is SugarDeviceSyncSuccess) {
                CustomQuickAlert.success(
                  title: "Success",
                  message: "Synced ${state.readings.length} readings!",
                );
                Navigator.pop(context, true); // Success signal
              } else if (state is SugarDeviceError) {
                CustomQuickAlert.error(
                  title: "Connection Error",
                  message: state.message,
                );
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  _buildContent(context, state),
                  if (state is SugarDeviceConnecting || state is SugarDeviceSyncing)
                    _buildOverlay(state),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, SugarDeviceState state) {
    if (state is SugarDeviceScanning && state.devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.fourRotatingDots(color: AppColors.primary, size: 80),
            SizedBox(height: SizeConfig.height * 0.03),
            Text("Scanning for devices...", style: AppTextStyles.title16GreyW500),
          ],
        ),
      );
    }

    if (state is SugarDeviceScanning) {
      return ListView.builder(
        padding: EdgeInsets.all(SizeConfig.width * 0.05),
        itemCount: state.devices.length,
        itemBuilder: (context, index) {
          final device = state.devices[index];
          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: _buildDeviceCard(context, device),
          );
        },
      );
    }
    
    if (state is SugarDeviceConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 80),
            SizedBox(height: SizeConfig.height * 0.02),
            Text("Connected to ${state.deviceName}", style: AppTextStyles.title20BlackBold),
            SizedBox(height: SizeConfig.height * 0.04),
            ElevatedButton(
              onPressed: () => context.read<SugarDeviceCubit>().syncData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Sync Data Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDeviceCard(BuildContext context, dynamic device) {
     return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.height * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(SizeConfig.width * 0.04),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.bluetooth_audio_rounded, color: AppColors.primary),
        ),
        title: Text(device.name, style: AppTextStyles.title16BlackBold),
        subtitle: Text("ID: ${device.id} • RSSI: ${device.rssi}", style: AppTextStyles.title12Grey),
        trailing: ElevatedButton(
          onPressed: () => context.read<SugarDeviceCubit>().connect(device),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Connect", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildOverlay(SugarDeviceState state) {
    String msg = state is SugarDeviceSyncing ? "Syncing readings..." : "Connecting to device...";
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.threeArchedCircle(color: Colors.white, size: 60),
            SizedBox(height: SizeConfig.height * 0.03),
            Text(msg, style: AppTextStyles.title16White400),
          ],
        ),
      ),
    );
  }
}
