import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/supabase_config.dart';
import '../../l10n/app_language.dart';
import '../../l10n/strings.dart';
import '../../models/message.dart';
import '../../providers/conversations_provider.dart';
import '../../services/app_errors.dart';
import '../../theme/app_colors.dart';
import '../../utils/time_format.dart';
import '../../widgets/worker_avatar.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherName;
  final String? otherAvatarUrl;
  final String? subtitle;
  final String? conversationId;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherName,
    this.otherAvatarUrl,
    this.subtitle,
    this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  String? _conversationId;
  Stream<List<ChatMessage>>? _stream;
  Object? _error;
  bool _sending = false;
  int _lastMarkedUnread = -1;

  String get _me => supabase.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    setState(() => _error = null);
    try {
      final id =
          widget.conversationId ??
          await supabase.rpc(
                'get_or_create_conversation',
                params: {'other_user': widget.otherUserId},
              )
              as String;
      if (!mounted) return;
      setState(() {
        _conversationId = id;
        _stream = supabase
            .from('messages')
            .stream(primaryKey: ['id'])
            .eq('conversation_id', id)
            .order('created_at', ascending: true)
            .map((rows) => rows.map(ChatMessage.fromMap).toList()
              // Oldest first, regardless of how realtime delivers rows.
              ..sort((a, b) {
                final c = a.createdAt.compareTo(b.createdAt);
                return c != 0 ? c : a.id.compareTo(b.id);
              }));
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _markReadIfNeeded(List<ChatMessage> messages) {
    final incoming = messages.where((m) => m.senderId != _me).length;
    if (incoming == _lastMarkedUnread || incoming == 0) return;
    _lastMarkedUnread = incoming;
    supabase
        .rpc('mark_conversation_read', params: {'cid': _conversationId})
        .then((_) {
          if (mounted) context.read<ConversationsProvider>().load(silent: true);
        })
        .catchError((_) {});
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _conversationId == null || _sending) return;
    setState(() => _sending = true);
    _input.clear();
    try {
      await supabase.from('messages').insert({
        'conversation_id': _conversationId,
        'body': text,
      });
    } catch (_) {
      if (!mounted) return;
      _input.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.read(context, 'send_failed'))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            UserAvatar(
              name: widget.otherName,
              photoUrl: widget.otherAvatarUrl,
              seed: widget.otherUserId.hashCode.abs(),
              size: 38,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.otherName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context, errorKeyFor(_error!)),
                style: const TextStyle(color: AppColors.textSecondary)),
            TextButton(onPressed: _open, child: Text(S.of(context, 'retry'))),
          ],
        ),
      );
    }
    if (_stream == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.leaf));
    }
    return StreamBuilder<List<ChatMessage>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Text(S.of(context, 'err_network'),
                style: const TextStyle(color: AppColors.textSecondary)),
          );
        }
        final messages = snap.data;
        if (messages == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.leaf));
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => _markReadIfNeeded(messages));
        if (messages.isEmpty) {
          return Center(
            child: Text(
              S.of(context, 'no_messages_yet'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        // Chronological items with a day chip before each new day.
        final lang = context.watch<LanguageProvider>().language;
        final items = <Widget>[];
        for (var i = 0; i < messages.length; i++) {
          final m = messages[i];
          final prev = i > 0 ? messages[i - 1] : null;
          final next = i < messages.length - 1 ? messages[i + 1] : null;
          if (prev == null || !isSameDay(prev.createdAt, m.createdAt)) {
            items.add(_DayChip(label: formatDayLabel(m.createdAt, lang)));
          }
          final groupedWithNext = next != null &&
              next.senderId == m.senderId &&
              isSameDay(next.createdAt, m.createdAt);
          items.add(_Bubble(
            message: m,
            fromMe: m.senderId == _me,
            tight: groupedWithNext,
          ));
        }
        // reverse: true keeps the list pinned to the newest message at the
        // bottom, so we feed it newest-first.
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          itemCount: items.length,
          itemBuilder: (context, i) => items[items.length - 1 - i],
        );
      },
    );
  }

  Widget _buildInput() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 2000,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: S.of(context, 'type_a_message'),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: const BorderSide(color: AppColors.leaf, width: 1.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.forest,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _send,
                  child: const SizedBox(
                    width: 46,
                    height: 46,
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  const _DayChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final bool fromMe;

  /// True when the next message is from the same sender (smaller gap).
  final bool tight;
  const _Bubble({required this.message, required this.fromMe, this.tight = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: tight ? 3 : 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
        decoration: BoxDecoration(
          color: fromMe ? AppColors.forest : AppColors.surface,
          border: fromMe ? null : Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(fromMe ? 18 : 4),
            bottomRight: Radius.circular(fromMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.body,
              style: TextStyle(
                color: fromMe ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              formatChatTime(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: fromMe ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
