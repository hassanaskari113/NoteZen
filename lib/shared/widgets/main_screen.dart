import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/core/themes/app_theme.dart';
import 'package:notezen/features/notes/presentation/notes_list_screen.dart';
import 'package:notezen/features/tasks/presentation/tasks_list_screen.dart';
import 'package:notezen/features/folders/presentation/folders_screen.dart';
import 'package:notezen/features/tasks/presentation/tasks_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  // Keep screens alive when switching tabs
  final List<Widget> _screens = const [NotesListScreen(), TasksListScreen(), FoldersScreen()];

  @override
  Widget build(BuildContext context) {
    // Watch overdue tasks for badge
    final overdueTasks = ref.watch(tasksProvider.select((tasks) => tasks.where((t) => t.isOverdue).length));

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        animationDuration: const Duration(milliseconds: 300),
        destinations: [
          // ── Notes Tab ──────────────────────────
          NavigationDestination(icon: Icon(Icons.note_outlined), selectedIcon: Icon(Icons.note), label: 'Notes'),

          // ── Tasks Tab (with overdue badge) ─────
          NavigationDestination(
            icon: Badge.count(
              count: overdueTasks,
              isLabelVisible: overdueTasks > 0,
              backgroundColor: AppTheme.error,
              child: Icon(Icons.task_outlined),
            ),
            selectedIcon: Badge.count(
              count: overdueTasks,
              isLabelVisible: overdueTasks > 0,
              backgroundColor: AppTheme.error,
              child: Icon(Icons.task),
            ),
            label: 'Tasks',
          ),

          // ── Folders Tab ────────────────────────
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Folders',
          ),
        ],
      ),
    );
  }
}
