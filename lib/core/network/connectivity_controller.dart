import 'dart:async';

import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityController extends GetxService {
  final isOnline = true.obs;

  final InternetConnection _connection = InternetConnection();
  StreamSubscription<InternetStatus>? _statusSub;

  @override
  void onInit() {
    super.onInit();
    unawaited(refresh());
    _statusSub = _connection.onStatusChange.listen((status) {
      isOnline.value = status == InternetStatus.connected;
    });
  }

  Future<bool> refresh() async {
    isOnline.value = await _connection.hasInternetAccess;
    return isOnline.value;
  }

  @override
  void onClose() {
    _statusSub?.cancel();
    super.onClose();
  }
}
