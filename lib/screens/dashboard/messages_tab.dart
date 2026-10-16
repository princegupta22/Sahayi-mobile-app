import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_language.dart';
import '../../l10n/strings.dart';
import '../../models/message.dart';
import '../../providers/conversations_provider.dart';
import '../../services/app_errors.dart';
import '../../theme/app_colors.dart';
import '../../utils/time_format.dart';
import '../../widgets/worker_avatar.dart';
import 'chat_screen.dart';

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final convos = context.watch<ConversationsProvider>();

    Widget body;
    if (convos.loading && convos.items.isEmpty) {
      body = const Center(child: CircularProgressIndicator(color: AppColors.leaf));
    } else if (convos.error != null && convos.items.isEmpty) {
      body = _Message(
        icon: Icons.wifi_off_rounded,
        title: S.of(context, errorKeyFor(convos.error!)),
        action: TextButton(
          onPressed: convos.load,
          child: Text(S.of(context, 'retry')),
        ),
      );
    } else if (convos.items.isEmpty) {
      body = _Message(
        icon: Icons.chat_bubble_outline_rounded,
        title: S.of(context, 'no_conversations'),
        subtitle: S.of(context, 'no_conversations_hint'),
      );
    } else {
      body = RefreshIndicator(
        color: AppColors.leaf,
        onRefresh: convos.load,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          itemCount: convos.items.length,
          separatorBuilder: (_, i) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _ConversationTile(item: convos.items[i]),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text(
            S.of(context, 'messages'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  const _Message({required this.icon, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: AppColors.divider),
            const SizedBox(height: 14),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            ],
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationSummary item;
  const _ConversationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: item.id,
            otherUserId: item.otherUserId,
            otherName: item.otherName,
            otherAvatarUrl: item.otherAvatarUrl,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B2420).withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            UserAvatar(
              name: item.otherName,
              photoUrl: item.otherAvatarUrl,
              seed: item.otherUserId.hashCode.abs(),
              size: 52,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.otherName.isEmpty ? '—' : item.otherName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: item.unread ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: item.unread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatInboxTime(
                    item.lastMessageAt,
                    context.watch<LanguageProvider>().language,
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    color: item.unread ? AppColors.forest : AppColors.textSecondary,
                    fontWeight: item.unread ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                if (item.unread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${item.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
