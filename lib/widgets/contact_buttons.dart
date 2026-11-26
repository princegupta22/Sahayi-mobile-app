import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/worker.dart';
import '../services/contact_actions.dart';
import '../theme/app_colors.dart';

/// Call / Message buttons for a worker, showing only what the worker allows:
///  • both on  → round call button + wide "Send Message"
///  • calls only   → one wide "Call" button
///  • messages only → one wide "Send Message" button
///  • both off → nothing at all
class ContactButtons extends StatelessWidget {
  final Worker worker;
  final double height;
  final double fontSize;
  const ContactButtons({
    super.key,
    required this.worker,
    this.height = 54,
    this.fontSize = 15,
  });

  /// True when there is at least one button to show.
  static bool isVisible(Worker w) => w.phonePublic || w.allowMessages;

  Widget _wide(BuildContext context, IconData icon, String labelKey,
      VoidCallback onTap) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: fontSize + 4),
        label: Text(
          S.of(context, labelKey),
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCall = worker.phonePublic;
    final canMessage = worker.allowMessages;

    if (!canCall && !canMessage) return const SizedBox.shrink();

    if (canCall && !canMessage) {
      return _wide(context, Icons.call_rounded, 'call_worker',
          () => callWorker(context, worker));
    }
    if (canMessage && !canCall) {
      return _wide(context, Icons.chat_bubble_outline_rounded, 'send_message',
          () => messageWorker(context, worker));
    }

    return Row(
      children: [
        Material(
          color: AppColors.background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => callWorker(context, worker),
            child: SizedBox(
              width: height,
              height: height,
              child: Icon(Icons.call_rounded,
                  size: height * 0.4, color: AppColors.forest),
            ),
          ),
        ),
        SizedBox(width: height > 50 ? 12 : 10),
        Expanded(
          child: _wide(context, Icons.chat_bubble_outline_rounded,
              'send_message', () => messageWorker(context, worker)),
        ),
      ],
    );
  }
}
