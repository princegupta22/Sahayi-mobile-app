import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/app_errors.dart';
import '../../services/payment_service.dart';
import '../../theme/app_colors.dart';
import '../../l10n/strings.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/primary_button.dart';
import '../dashboard/dashboard_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = false;

  Future<void> _pay() async {
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      final outcome =
          await PaymentService.pay(name: auth.name, email: auth.email);
      if (!mounted || outcome == PaymentOutcome.cancelled) return;
      // Trust the server, not the checkout callback.
      if (!await auth.refreshPaid()) throw StateError('payment_failed');
      if (!mounted) return;
      await _showSuccess();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.read(context, errorKeyFor(e)))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showSuccess() => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          Future.delayed(const Duration(milliseconds: 1100), () {
            if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          });
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: AppColors.leaf,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    S.read(context, 'payment_success'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeader(
            title: S.of(context, 'one_last_step'),
            subtitle: S.of(context, 'fee_subtitle'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.leaf.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context, 'registration_fee'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '₹19',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forest,
                      ),
                    ),
                    Text(
                      S.of(context, 'one_time'),
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 22),
                    const Divider(),
                    const SizedBox(height: 18),
                    _Perk(text: S.of(context, 'perk_badge')),
                    const SizedBox(height: 12),
                    _Perk(text: S.of(context, 'perk_access')),
                    const SizedBox(height: 12),
                    _Perk(text: S.of(context, 'perk_browse')),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                label: S.of(context, 'pay_now'),
                loading: _loading,
                onPressed: _pay,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  final String text;
  const _Perk({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.leaf, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
