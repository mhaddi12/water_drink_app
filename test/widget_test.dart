// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/app.dart';
import 'package:water_drink_app/features/focus/controllers/focus_nav_controller.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/controllers/systems_controller.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.put(HomeController(), permanent: true);
    Get.put(SystemsController(), permanent: true);
    Get.put(FocusNavController(), permanent: true);
  });

  tearDown(Get.reset);

  testWidgets('renders focus home first design screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WaterDrinkApp());

    expect(find.text('Build your system.'), findsOneWidget);
    expect(find.text('Morning Routine'), findsOneWidget);
    expect(find.text('Study System'), findsOneWidget);
  });
}
