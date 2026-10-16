import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shown only when SUPABASE_URL / SUPABASE_ANON_KEY have not been set.
class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.roof),
              SizedBox(height: 18),
              Text('Connect Supabase',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              SizedBox(height: 12),
              Text(
                '1. Run supabase/schema.sql in the Supabase SQL editor.\n'
                '2. Copy .env.example to .env and fill in\n'
                '    SUPABASE_URL and SUPABASE_ANON_KEY.\n'
                '3. Fully restart the app (not hot reload).',
                style: TextStyle(height: 1.6, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
