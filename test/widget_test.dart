import 'package:flutter_test/flutter_test.dart';

import 'package:sahayi/main.dart';

void main() {
  testWidgets('Splash screen shows the Sahayi name', (WidgetTester tester) async {
    await tester.pumpWidget(const SahayiApp());
    await tester.pump();

    expect(find.text('Sahayi'), findsOneWidget);
    expect(find.text('Reliable service, now at your home too.'), findsOneWidget);
  });
}
