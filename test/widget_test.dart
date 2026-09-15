import 'package:flutter_test/flutter_test.dart';
import 'package:ll_lifelink_ai/main.dart';

void main() {
  testWidgets('LL Lifelink AI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LifelinkApp());

    // Verify that SplashPage loads with LL Lifelink AI branding.
    expect(find.text('LL Lifelink AI'), findsOneWidget);
    expect(find.text('Smart India Hackathon 2026'), findsOneWidget);
  });
}
