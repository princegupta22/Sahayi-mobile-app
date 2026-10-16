import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/message.dart';

/// Inbox list, kept fresh by a realtime subscription on `messages`
/// (RLS limits events to conversations the user belongs to).
class ConversationsProvider extends ChangeNotifier {
  List<ConversationSummary> _items = [];
  bool _loading = false;
  Object? _error;
  RealtimeChannel? _channel;

  List<ConversationSummary> get items => _items;
  bool get loading => _loading;
  Object? get error => _error;
  int get unreadTotal => _items.fold(0, (s, c) => s + c.unreadCount);

  Future<void> start() async {
    await load();
    if (_channel != null) return;
    _channel = supabase
        .channel('inbox')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (_) => load(silent: true),
        )
        .subscribe();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      _loading = true;
      _error = null;
      notifyListeners();
    }
    try {
      final rows = await supabase.rpc('my_conversations') as List;
      _items = rows
          .map((r) => ConversationSummary.fromMap(r as Map<String, dynamic>))
          .toList();
      _error = null;
    } catch (e) {
      if (!silent) _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    final ch = _channel;
    _channel = null;
    if (ch != null) await supabase.removeChannel(ch);
    _items = [];
    notifyListeners();
  }

  @override
  void dispose() {
    final ch = _channel;
    if (ch != null) supabase.removeChannel(ch);
    super.dispose();
  }
}
