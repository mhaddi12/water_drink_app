import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/network/connectivity_controller.dart';

class InternetConnectionBanner extends StatelessWidget {
  const InternetConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ConnectivityController>()) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final controller = Get.find<ConnectivityController>();
      if (controller.isOnline.value) {
        return const SizedBox.shrink();
      }

      return Material(
        color: const Color(0xFFB3261E),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'No internet connection. Check your connection. Changes stay on this device until you are back online.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final online = await controller.refresh();
                    if (!online) {
                      Get.snackbar(
                        'Hydra',
                        'Still offline. Check your internet connection.',
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
