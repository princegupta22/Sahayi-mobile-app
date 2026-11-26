import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sahayi/l10n/app_language.dart';
import 'package:sahayi/models/worker.dart';
import 'package:sahayi/widgets/contact_buttons.dart';

Worker _w({required bool phone, required bool msgs}) => Worker(
      id: '1',
      userId: 'u1',
      name: 'Test Worker',
      categoryEn: 'Electrician',
      categoryMl: 'ഇലക്ട്രീഷ്യൻ',
      city: 'Kochi',
      country: 'India',
      experienceYears: 3,
      phonePublic: phone,
      allowMessages: msgs,
    );

Future<void> _pump(WidgetTester t, Worker w) => t.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: MaterialApp(
          home: Scaffold(body: Center(child: ContactButtons(worker: w))),
        ),
      ),
    );

void main() {
  testWidgets('both on: call icon + Send Message', (t) async {
    await _pump(t, _w(phone: true, msgs: true));
    expect(find.byIcon(Icons.call_rounded), findsOneWidget);
    expect(find.text('Send Message'), findsOneWidget);
  });

  testWidgets('calls off: only Send Message', (t) async {
    await _pump(t, _w(phone: false, msgs: true));
    expect(find.byIcon(Icons.call_rounded), findsNothing);
    expect(find.text('Call'), findsNothing);
    expect(find.text('Send Message'), findsOneWidget);
  });

  testWidgets('messages off: only Call', (t) async {
    await _pump(t, _w(phone: true, msgs: false));
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Send Message'), findsNothing);
  });

  testWidgets('both off: nothing shown', (t) async {
    await _pump(t, _w(phone: false, msgs: false));
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byIcon(Icons.call_rounded), findsNothing);
    expect(ContactButtons.isVisible(_w(phone: false, msgs: false)), isFalse);
  });
}
