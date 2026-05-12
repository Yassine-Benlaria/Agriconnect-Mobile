import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriconnect/app.dart';

void main() {
  testWidgets('AgriConnect smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AgriConnectApp()),
    );
    // App should start without crashing
    await tester.pump();
  });
}
