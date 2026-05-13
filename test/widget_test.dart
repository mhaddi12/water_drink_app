import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/app.dart';
import 'package:water_drink_app/core/network/connectivity_controller.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/features/focus/controllers/focus_nav_controller.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/controllers/systems_controller.dart';
import 'package:water_drink_app/features/history/controllers/history_controller.dart';
import 'package:water_drink_app/features/hydration/controllers/hydration_controller.dart';
import 'package:water_drink_app/features/reminders/controllers/reminders_controller.dart';
import 'package:water_drink_app/features/settings/controllers/settings_controller.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.put(LocalProfileStore(), permanent: true);
    Get.put(ConnectivityController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(SystemsController(), permanent: true);
    Get.put(HydrationController(), permanent: true);
    Get.put(HistoryController(), permanent: true);
    Get.put(RemindersController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put(FocusNavController(), permanent: true);
  });

  tearDown(Get.reset);

  testWidgets('renders focus home shell', (WidgetTester tester) async {
    await tester.pumpWidget(const WaterDrinkApp());
    await tester.pump();

    expect(find.text('Build your system'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('WATER'), findsOneWidget);
  });
}
