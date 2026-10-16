import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../dashboard/dashboard_screen.dart';
import 'payment_screen.dart';

/// Entry point for every signed-in user (cold start and login). Asks the
/// server whether the user has paid: paid → Dashboard, otherwise → Payment.
/// Fails closed, so a network error shows Retry, never the Dashboard.
class PaymentGate extends StatefulWidget {
  const PaymentGate({super.key});

  @override
  State<PaymentGate> createState() => _PaymentGateState();
}

class _PaymentGateState extends State<PaymentGate> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => _failed = false);
    try {
      final paid = await context.read<AuthProvider>().refreshPaid();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => paid ? const DashboardScreen() : const PaymentScreen(),
      ));
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _failed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.of(context, 'err_network')),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _check,
                    child: Text(S.of(context, 'retry')),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.leaf),
                  const SizedBox(height: 16),
                  Text(S.of(context, 'checking_account')),
                ],
              ),
      ),
    );
  }
}
