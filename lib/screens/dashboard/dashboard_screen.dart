import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/strings.dart';
import '../../providers/conversations_provider.dart';
import '../../providers/worker_directory.dart';
import '../../theme/app_colors.dart';
import 'home_tab.dart';
import 'work_tab.dart';
import 'messages_tab.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WorkerDirectory>().load();
      context.read<ConversationsProvider>().start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const HomeTab(),
      WorkTab(onFindWorker: () => setState(() => _index = 0)),
      const MessagesTab(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: tabs)),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: S.of(context, 'home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.work_outline_rounded),
              selectedIcon: const Icon(Icons.work_rounded),
              label: S.of(context, 'work_tab'),
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: context.watch<ConversationsProvider>().unreadTotal > 0,
                label: Text('${context.watch<ConversationsProvider>().unreadTotal}'),
                child: const Icon(Icons.chat_bubble_outline_rounded),
              ),
              selectedIcon: const Icon(Icons.chat_bubble_rounded),
              label: S.of(context, 'messages'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: S.of(context, 'profile'),
            ),
          ],
        ),
      ),
    );
  }
}
