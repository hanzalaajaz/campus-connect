import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect/main.dart';
import 'package:campus_connect/utils/app_constants.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CampusConnectApp());

    // Verify that the splash screen shows the App Name
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.universityName), findsOneWidget);

    // Let the navigation timers settle
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
