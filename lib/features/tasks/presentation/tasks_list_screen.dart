import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/core/constants/app_constants.dart';
import 'package:notezen/core/themes/app_theme.dart';
import 'package:notezen/core/utils/date_formatter.dart';
import 'package:notezen/features/tasks/domain/tasks.dart';
import 'package:notezen/features/tasks/presentation/tasks_detail_screen.dart';
import 'package:notezen/features/tasks/presentation/tasks_provider.dart';
import 'package:notezen/shared/providers/search_provider.dart';
import 'package:notezen/shared/widgets/empty_state.dart';
import 'package:notezen/shared/widgets/settings_screen.dart';

class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreen();
}

class _TasksListScreen extends ConsumerState<TasksListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Toggle Search ───────────────────────────────
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(searchQueryProvider.notifier).clearQuery();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(filteredTasksProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : AppTheme.textHint),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (query) => ref.read(searchQueryProvider.notifier).updateQuery(query),
              )
            : Text('Tasks'),
        actions: [
          IconButton(icon: Icon(_isSearching ? Icons.close : Icons.search_rounded), onPressed: _toggleSearch),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen())),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: AppConstants.animNormal,
        child: tasks.isEmpty
            ? EmptyState(
                key: ValueKey('empty'),
                icon: Icons.task_outlined,
                title: _isSearching ? 'No Results Found' : 'No Tasks Yet',
                subtitle: _isSearching ? 'Try a different search term' : 'Tap + to add your first task',
              )
            : ListView.builder(
                key: ValueKey('list'),
                padding: EdgeInsets.symmetric(vertical: AppConstants.spaceSM),
                itemCount: tasks.length,
                itemBuilder: (context, index) => TaskTile(task: tasks[index]),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TasksDetailScreen())),
        tooltip: 'New Task',
        child: Icon(Icons.add_task),
      ),
    );
  }
}

// ─── Task Tile ───────────────────────────────────────
class TaskTile extends ConsumerWidget {
  const TaskTile({required this.task, super.key});
  final Task task;

  // ─── Delete Confirmation ─────────────────────────
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: AppTheme.error, size: 22),
            SizedBox(width: AppConstants.spaceSM),
            Text('Delete Task'),
          ],
        ),
        content: Text('Delete "${task.title}"?\nThis cannot be undone.', style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && task.id != null) {
      ref.read(tasksProvider.notifier).deleteTask(task.id!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = task.isCompleted
        ? Colors.grey
        : isDark
        ? Colors.white
        : AppTheme.textPrimary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceXS),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TasksDetailScreen(task: task))),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: task.isOverdue
                ? Border.all(color: AppTheme.error.withValues(alpha: 0.4), width: 1.5)
                : Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.15),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // ── Priority Color Bar ────────────
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: task.isCompleted ? Colors.grey.withValues(alpha: 0.3) : task.priorityColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.radiusCard),
                      bottomLeft: Radius.circular(AppConstants.radiusCard),
                    ),
                  ),
                ),

                // ── Checkbox ─────────────────────
                Checkbox(
                  value: task.isCompleted,
                  activeColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (_) => ref.read(tasksProvider.notifier).toggleComplete(task),
                ),

                // ── Content ──────────────────────
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppConstants.spaceMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: titleColor,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 4),

                        // Deadline Row
                        Row(
                          children: [
                            Icon(
                              task.isOverdue ? Icons.warning_rounded : Icons.access_time_rounded,
                              size: 12,
                              color: task.isCompleted ? Colors.grey : task.deadlineColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              task.isCompleted
                                  ? DateFormatter.format(task.deadline)
                                  : DateFormatter.formatDeadline(task.deadline),
                              style: TextStyle(
                                fontSize: 12,
                                color: task.isCompleted ? Colors.grey : task.deadlineColor,
                                fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Priority Chip ─────────────────
                if (!task.isCompleted)
                  Container(
                    margin: EdgeInsets.only(right: AppConstants.spaceXS),
                    padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceSM, vertical: 3),
                    decoration: BoxDecoration(
                      color: task.priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                      border: Border.all(color: task.priorityColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      task.priorityLabel,
                      style: TextStyle(fontSize: 10, color: task.priorityColor, fontWeight: FontWeight.w600),
                    ),
                  ),

                // ── Delete Button ─────────────────
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18),
                  color: AppTheme.error.withValues(alpha: 0.6),
                  padding: EdgeInsets.only(right: AppConstants.spaceMD),
                  constraints: BoxConstraints(),
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
