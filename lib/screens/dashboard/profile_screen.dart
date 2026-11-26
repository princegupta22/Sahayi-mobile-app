import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_language.dart';
import '../../l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversations_provider.dart';
import '../../providers/worker_directory.dart';
import '../../services/app_errors.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/availability_tag.dart';
import '../../widgets/language_toggle.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/worker_avatar.dart';
import '../auth/login_screen.dart';
import 'find_work_screen.dart';
import 'worker_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myListing = context.watch<WorkerDirectory>().myListing;
    final auth = context.watch<AuthProvider>();
    final displayName = auth.name.isEmpty ? S.of(context, 'sahayi_member') : auth.name;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context, 'my_profile'),
            style: const TextStyle(fontFamily: AppTheme.headingFont, fontSize: AppTheme.headingSize, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 3),
                      Text(auth.email.isEmpty ? S.of(context, 'sahayi_member') : auth.email, style: const TextStyle(color: Colors.white70, fontSize: 12.5, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(S.of(context, 'verified'), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(S.of(context, 'my_listing'), style: const TextStyle(fontFamily: AppTheme.headingFont, fontWeight: FontWeight.w800, fontSize: AppTheme.headingSize)),
          const SizedBox(height: 12),
          if (myListing == null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Icon(Icons.work_off_outlined, color: AppColors.textSecondary, size: 30),
                  const SizedBox(height: 10),
                  Text(
                    S.of(context, 'no_listing_yet'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: S.of(context, 'create_listing'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FindWorkScreen()),
                    ),
                  ),
                ],
              ),
            )
          else
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => WorkerDetailScreen(worker: myListing)),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    WorkerAvatar(worker: myListing, size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(myListing.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                          const SizedBox(height: 3),
                          Text(myListing.serviceLabel(context.watch<LanguageProvider>().language), style: const TextStyle(color: AppColors.leaf, fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: S.of(context, 'edit_listing'),
                      icon: const Icon(Icons.edit_outlined, color: AppColors.forest),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FindWorkScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (myListing != null) ...[
            const SizedBox(height: 12),
            _AvailabilitySwitch(available: myListing.isAvailable),
            const SizedBox(height: 12),
            _ContactOptions(
              phonePublic: myListing.phonePublic,
              allowMessages: myListing.allowMessages,
            ),
          ],
          const SizedBox(height: 28),
          Text(S.of(context, 'settings'), style: const TextStyle(fontFamily: AppTheme.headingFont, fontWeight: FontWeight.w800, fontSize: AppTheme.headingSize)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language, color: AppColors.leaf),
                    title: Text(S.of(context, 'language'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    trailing: const LanguageToggle(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: AppColors.danger),
                    title: Text(
                      S.of(context, 'logout'),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.danger),
                    ),
                    onTap: () async {
                      final nav = Navigator.of(context);
                      final directory = context.read<WorkerDirectory>();
                      final convos = context.read<ConversationsProvider>();
                      await convos.stop();
                      directory.clear();
                      await auth.signOut();
                      nav.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_forever_outlined, color: AppColors.danger),
                    title: Text(
                      S.of(context, 'delete_account'),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.danger),
                    ),
                    onTap: () => _deleteAccount(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Asks for confirmation, deletes the account on the server and returns to
/// the login screen. On failure the user stays signed in and sees why.
Future<void> _deleteAccount(BuildContext context) async {
  final nav = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final auth = context.read<AuthProvider>();
  final directory = context.read<WorkerDirectory>();
  final convos = context.read<ConversationsProvider>();
  // Looked up now: the screen may already be gone once the account is deleted.
  final deletedMsg = S.read(context, 'account_deleted');
  final failedMsg = S.read(context, 'err_delete_account');
  final networkMsg = S.read(context, 'err_network');

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(S.of(ctx, 'delete_account_title')),
      content: Text(S.of(ctx, 'delete_account_body')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(S.of(ctx, 'cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: Text(S.of(ctx, 'delete_account_confirm')),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  // Block the screen while the server works; a half-finished delete is worse
  // than a spinner.
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  );

  try {
    await auth.deleteAccount();
  } catch (e) {
    debugPrint('deleteAccount failed: $e');
    nav.pop(); // spinner
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(errorKeyFor(e) == 'err_network' ? networkMsg : failedMsg),
      ));
    return;
  }

  await convos.stop();
  directory.clear();
  nav.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(deletedMsg)));
}

/// Lets the worker mark themselves Available or Booked for everyone else.
class _AvailabilitySwitch extends StatefulWidget {
  final bool available;
  const _AvailabilitySwitch({required this.available});

  @override
  State<_AvailabilitySwitch> createState() => _AvailabilitySwitchState();
}

class _AvailabilitySwitchState extends State<_AvailabilitySwitch> {
  late bool _value = widget.available;
  bool _saving = false;

  @override
  void didUpdateWidget(_AvailabilitySwitch old) {
    super.didUpdateWidget(old);
    if (!_saving) _value = widget.available;
  }

  /// Flips the switch right away and rolls it back if the save fails.
  Future<void> _set(bool available) async {
    setState(() {
      _value = available;
      _saving = true;
    });
    final messenger = ScaffoldMessenger.of(context);
    String key;
    try {
      await context.read<WorkerDirectory>().setAvailable(available);
      key = available ? 'now_available' : 'now_booked';
    } catch (e) {
      debugPrint('setAvailable failed: $e');
      key = errorKeyFor(e);
      if (mounted) setState(() => _value = !available);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(S.read(context, key))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(S.of(context, 'availability'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    const SizedBox(width: 8),
                    AvailabilityTag(available: _value),
                  ],
                ),
                const SizedBox(height: 4),
                Text(S.of(context, 'availability_hint'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _value,
            activeTrackColor: AppColors.leaf,
            onChanged: _saving ? null : _set,
          ),
        ],
      ),
    );
  }
}


/// "Who can see the number" (Only me / Public) and "Get messages"
/// (Disable / Enable). Customers only see the Call / Message buttons the
/// worker has turned on.
class _ContactOptions extends StatefulWidget {
  final bool phonePublic;
  final bool allowMessages;
  const _ContactOptions({required this.phonePublic, required this.allowMessages});

  @override
  State<_ContactOptions> createState() => _ContactOptionsState();
}

class _ContactOptionsState extends State<_ContactOptions> {
  late bool _phonePublic = widget.phonePublic;
  late bool _allowMessages = widget.allowMessages;
  bool _saving = false;

  @override
  void didUpdateWidget(_ContactOptions old) {
    super.didUpdateWidget(old);
    if (!_saving) {
      _phonePublic = widget.phonePublic;
      _allowMessages = widget.allowMessages;
    }
  }

  /// Applies the change right away and rolls it back if the save fails.
  Future<void> _save({bool? phonePublic, bool? allowMessages}) async {
    final prevPhone = _phonePublic;
    final prevMsgs = _allowMessages;
    setState(() {
      _phonePublic = phonePublic ?? _phonePublic;
      _allowMessages = allowMessages ?? _allowMessages;
      _saving = true;
    });
    final messenger = ScaffoldMessenger.of(context);
    String key;
    try {
      await context
          .read<WorkerDirectory>()
          .setContactPrefs(phonePublic: phonePublic, allowMessages: allowMessages);
      key = phonePublic != null
          ? (phonePublic ? 'phone_now_public' : 'phone_now_private')
          : (allowMessages! ? 'messages_now_on' : 'messages_now_off');
    } catch (e) {
      debugPrint('setContactPrefs failed: $e');
      key = errorKeyFor(e);
      if (mounted) {
        setState(() {
          _phonePublic = prevPhone;
          _allowMessages = prevMsgs;
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(S.read(context, key))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context, 'contact_options'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
          const SizedBox(height: 2),
          Text(S.of(context, 'contact_options_hint'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          _OptionRow(
            icon: Icons.call_outlined,
            label: S.of(context, 'who_can_see_number'),
            offLabel: S.of(context, 'only_me'),
            onLabel: S.of(context, 'public_label'),
            value: _phonePublic,
            enabled: !_saving,
            onChanged: (v) => _save(phonePublic: v),
          ),
          const SizedBox(height: 12),
          _OptionRow(
            icon: Icons.chat_bubble_outline_rounded,
            label: S.of(context, 'get_messages'),
            offLabel: S.of(context, 'disable_label'),
            onLabel: S.of(context, 'enable_label'),
            value: _allowMessages,
            enabled: !_saving,
            onChanged: (v) => _save(allowMessages: v),
          ),
        ],
      ),
    );
  }
}

/// A label with a two-way choice (off / on) on the right.
class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String offLabel;
  final String onLabel;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.offLabel,
    required this.onLabel,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppColors.leaf),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        const SizedBox(width: 8),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(fontFamily: AppTheme.bodyFont, fontSize: 12, fontWeight: FontWeight.w700),
            selectedBackgroundColor: AppColors.leaf,
            selectedForegroundColor: Colors.white,
          ),
          segments: [
            ButtonSegment(value: false, label: Text(offLabel)),
            ButtonSegment(value: true, label: Text(onLabel)),
          ],
          selected: {value},
          onSelectionChanged: enabled ? (s) => onChanged(s.first) : null,
        ),
      ],
    );
  }
}
