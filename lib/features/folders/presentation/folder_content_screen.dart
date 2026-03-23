import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/core/constants/app_constants.dart';
import 'package:notezen/core/themes/app_theme.dart';
import 'package:notezen/features/folders/domain/folders.dart';
import 'package:notezen/shared/providers/search_provider.dart';
import 'package:notezen/shared/widgets/empty_state.dart';
import 'package:notezen/features/notes/presentation/notes_list_screen.dart';
import 'package:notezen/features/notes/presentation/note_detail_screen.dart';
import 'package:notezen/features/tasks/presentation/tasks_list_screen.dart';
import 'package:notezen/features/tasks/presentation/tasks_detail_screen.dart';

class FolderContentsScreen extends ConsumerStatefulWidget {
  const FolderContentsScreen({super.key, required this.folder});
  final Folder folder;

  @override
  ConsumerState<FolderContentsScreen> createState() => _FolderContentsScreenState();
}

class _FolderContentsScreenState extends ConsumerState<FolderContentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Notes Tab ───────────────────────────────────
  Widget _buildNotesTab() {
    final notes = ref.watch(folderNotesProvider(widget.folder.id!));

    if (notes.isEmpty) {
      return EmptyState(
        icon: Icons.note_outlined,
        title: 'No Notes Here',
        subtitle: 'Tap + to create a note\nin this folder',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppConstants.spaceLG),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Padding(
          padding: EdgeInsets.only(bottom: AppConstants.spaceSM),
          child: NoteCard(note: note),
        );
      },
    );
  }

  // ─── Tasks Tab ───────────────────────────────────
  Widget _buildTasksTab() {
    final tasks = ref.watch(folderTasksProvider(widget.folder.id!));

    if (tasks.isEmpty) {
      return EmptyState(
        icon: Icons.task_outlined,
        title: 'No Tasks Here',
        subtitle: 'Tap + to create a task\nin this folder',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: AppConstants.spaceSM),
      itemCount: tasks.length,
      itemBuilder: (context, index) => TaskTile(task: tasks[index]),
    );
  }

  // ─── Navigate to New Note ─────────────────────────
  void _addNote() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailScreen(note: null)));
  }

  // ─── Navigate to New Task ─────────────────────────
  void _addTask() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TasksDetailScreen(task: null)));
  }

  @override
  Widget build(BuildContext context) {
    final folderColor = widget.folder.folderColor;
    final isNotesTab = _tabController.index == 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Folder color dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: folderColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: folderColor.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 1)],
              ),
            ),
            SizedBox(width: AppConstants.spaceSM),
            Text(widget.folder.name),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60), // slightly taller for spacing
          child: Column(
            children: [
              SizedBox(height: 8), // move TabBar lower
              Container(
                margin: EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.note_outlined, size: 18),
                      text: 'Notes',
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                    Tab(
                      icon: Icon(Icons.task_outlined, size: 18),
                      text: 'Tasks',
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: TabBarView(controller: _tabController, children: [_buildNotesTab(), _buildTasksTab()]),
      floatingActionButton: FloatingActionButton(
        onPressed: isNotesTab ? _addNote : _addTask,
        tooltip: isNotesTab ? 'Add Note' : 'Add Task',
        child: AnimatedSwitcher(
          duration: AppConstants.animFast,
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: Icon(isNotesTab ? Icons.note_add : Icons.add_task, key: ValueKey(isNotesTab)),
        ),
      ),
    );
  }
}
