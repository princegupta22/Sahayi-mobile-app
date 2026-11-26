// Renders real Sahayi screens with sample data into PNGs for the Play Store
// listing:  flutter test tool/store_screenshots_test.dart
// Output: playstore/screenshots/raw/NN_name.png (1080x1920)
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sahayi/l10n/app_language.dart';
import 'package:sahayi/l10n/categories.dart';
import 'package:sahayi/models/worker.dart';
import 'package:sahayi/providers/auth_provider.dart';
import 'package:sahayi/providers/conversations_provider.dart';
import 'package:sahayi/providers/worker_directory.dart';
import 'package:sahayi/screens/dashboard/dashboard_screen.dart';
import 'package:sahayi/screens/dashboard/find_worker_screen.dart';
import 'package:sahayi/screens/dashboard/worker_detail_screen.dart';
import 'package:sahayi/theme/app_theme.dart';

class _FakeAuth extends AuthProvider {
  @override
  String get name => 'Anoop Mathew';
  @override
  String get email => 'anoop.mathew@example.com';
}

class _FakeConvos extends ConversationsProvider {
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
}

Worker _w(String id, String name, String cat, String city, int years,
        double rating, String about,
        {bool available = true}) =>
    Worker(
      id: id,
      userId: 'u$id',
      name: name,
      categoryEn: cat,
      categoryMl: WorkCategory.byEnglish(cat)?.ml ?? cat,
      city: city,
      country: 'India',
      experienceYears: years,
      rating: rating,
      about: about,
      isAvailable: available,
    );

final _workers = [
  _w('1', 'Rajesh Kumar', 'Electrician', 'Kochi', 8, 4.8,
      'Wiring, fan and light fitting, inverter and MCB repairs. Same-day service across Ernakulam.'),
  _w('2', 'Sunil Varghese', 'Plumber', 'Thrissur', 12, 4.6,
      'Leak repairs, bathroom fittings and pipeline work.'),
  _w('3', 'Biju Thomas', 'Carpenter', 'Kochi', 15, 4.9,
      'Custom furniture, doors, wardrobes and kitchen cabinets.'),
  _w('4', 'Anitha Menon', 'Cleaner', 'Kozhikode', 5, 4.7,
      'Deep cleaning for homes and flats.', available: false),
  _w('5', 'Nikhil Das', 'Painter', 'Kottayam', 6, 4.5,
      'Interior and exterior painting with neat finishing.'),
  _w('6', 'Shibu Joseph', 'AC Technician', 'Kochi', 9, 4.8,
      'AC installation, gas filling and servicing.'),
];

class _FakeDirectory extends WorkerDirectory {
  final Worker mine = _w('9', 'Anoop Mathew', 'Electrician', 'Kochi', 7, 4.8,
      'Licensed electrician for homes and shops.');

  @override
  List<Worker> get workers => _workers;
  @override
  Worker? get myListing => mine;
  @override
  Future<void> load() async {}
  @override
  Map<String, int> get countsByCategory => {
        'Electrician': 24, 'Plumber': 18, 'Carpenter': 16, 'Painter': 14,
        'AC Technician': 9, 'Cleaner': 21, 'Pest Control': 8, 'Tutor': 11,
      };
}

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    loader.addFont(Future.value(ByteData.sublistView(File(p).readAsBytesSync())));
  }
  await loader.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
        File(Platform.resolvedExecutable).parent.parent.parent.parent.path;
    final fonts = '$flutterRoot/bin/cache/artifacts/material_fonts';
    await _loadFont('MaterialIcons', ['$fonts/MaterialIcons-Regular.otf']);
    await _loadFont('Roboto', [
      '$fonts/Roboto-Regular.ttf',
      '$fonts/Roboto-Medium.ttf',
      '$fonts/Roboto-Bold.ttf',
      '$fonts/Roboto-Black.ttf',
    ]);
    // Only so the "മലയാളം" label in the language switch renders.
    await _loadFont('MalayalamFB', [
      '/System/Library/Fonts/Supplemental/Malayalam Sangam MN.ttc',
    ]);
    await _loadFont('Tinos', [
      'assets/fonts/Tinos-Regular.ttf',
      'assets/fonts/Tinos-Bold.ttf',
    ]);
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'sample-key',
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _MemoryAsyncStorage(),
      ),
    );
  });

  Future<void> shoot(WidgetTester tester, String name, Widget home,
      {Future<void> Function()? before}) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => _FakeAuth()),
        ChangeNotifierProvider<WorkerDirectory>(create: (_) => _FakeDirectory()),
        ChangeNotifierProvider<ConversationsProvider>(create: (_) => _FakeConvos()),
      ],
      child: RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light.copyWith(
            textTheme: AppTheme.light.textTheme
                .apply(fontFamilyFallback: const ['MalayalamFB']),
          ),
          builder: AppTheme.clampTextScale,
          home: home,
        ),
      ),
    ));
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/logo.png'),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pump(const Duration(milliseconds: 300));
    if (before != null) await before();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('playstore/screenshots/raw/$name.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  testWidgets('01 home', (t) async {
    await shoot(t, '01_home', const DashboardScreen());
  });

  testWidgets('02 workers', (t) async {
    await shoot(t, '02_workers',
        FindWorkerScreen(group: CategoryGroup.byId('home')));
  });

  testWidgets('03 worker detail', (t) async {
    await shoot(t, '03_detail', WorkerDetailScreen(worker: _workers.first));
  });

  testWidgets('04 profile', (t) async {
    await shoot(t, '04_profile', const DashboardScreen(), before: () async {
      await t.tap(find.text('Profile'));
      await t.pump(const Duration(milliseconds: 400));
    });
  });
}

class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final _m = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => _m[key];
  @override
  Future<void> setItem({required String key, required String value}) async =>
      _m[key] = value;
  @override
  Future<void> removeItem({required String key}) async => _m.remove(key);
}
