import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Values come from the `.env` file in the project root:
///   SUPABASE_URL=https://xxxx.supabase.co
///   SUPABASE_ANON_KEY=eyJ...
/// (Dashboard → Project Settings → API). Copy `.env.example` to `.env`.
/// Call [SupabaseConfig.load] once before using the other getters.
class SupabaseConfig {
  SupabaseConfig._();

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Missing .env → isConfigured stays false and the setup screen shows.
    }
  }

  static String get url => _read('SUPABASE_URL');
  static String get anonKey => _read('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      url.startsWith('https://') &&
      !url.contains('YOUR-PROJECT-REF') &&
      anonKey.isNotEmpty &&
      !anonKey.contains('YOUR-ANON-KEY');

  static String _read(String key) =>
      dotenv.isInitialized ? (dotenv.maybeGet(key)?.trim() ?? '') : '';
}

SupabaseClient get supabase => Supabase.instance.client;
