import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/core/constants/app_constants.dart';
import 'package:notezen/core/themes/app_theme.dart';
import 'package:notezen/core/utils/date_formatter.dart';
import 'package:notezen/features/tasks/domain/tasks.dart';
import 'package:notezen/features/tasks/presentation/tasks_provider.dart';
import 'package:notezen/features/folders/domain/folders.dart';
import 'package:notezen/features/folders/presentation/folders_provider.dart';

class TasksDetailScreen extends ConsumerStatefulWidget {
  const TasksDetailScreen({super.key, this.task});
  final Task? task;

  @override
  ConsumerState<TasksDetailScreen> createState() => _TaskDetailScreen();
}

class _TaskDetailScreen extends ConsumerState<TasksDetailScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _deadline;
  int _priority = 1;
  int? _folderId;
  bool _isNew = true;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _isNew = false;
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _deadline = widget.task!.deadline;
      _priority = widget.task!.priority ?? 1;
      _folderId = widget.task!.folderId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ─── Pick Deadline ───────────────────────────────
  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now,
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(data: Theme.of(ctx), child: child!),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _deadline != null ? TimeOfDay.fromDateTime(_deadline!) : TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  // ─── Save Task ───────────────────────────────────
  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 18),
              SizedBox(width: AppConstants.spaceSM),
              Text('Please enter a title'),
            ],
          ),
        ),
      );
      return;
    }

    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 18),
              SizedBox(width: AppConstants.spaceSM),
              Text('Please pick a deadline'),
            ],
          ),
        ),
      );
      return;
    }

    if (_isNew) {
      ref
          .read(tasksProvider.notifier)
          .addTask(
            Task(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              priority: _priority,
              isCompleted: false,
              deadline: _deadline!,
              createdAt: DateTime.now(),
              folderId: _folderId,
            ),
          );
    } else {
      ref
          .read(tasksProvider.notifier)
          .updateTask(
            widget.task!.copyWith(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              deadline: _deadline,
              priority: _priority,
              folderId: _folderId,
              clearFolder: _folderId == null,
            ),
          );
    }
    Navigator.pop(context);
  }

  // ─── Delete Task ─────────────────────────────────
  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: AppTheme.error, size: 24),
            SizedBox(width: AppConstants.spaceSM),
            Text('Delete Task'),
          ],
        ),
        content: Text('Delete "${widget.task!.title}"?\nThis cannot be undone.', style: TextStyle(fontSize: 14)),
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

    if (confirmed == true && widget.task?.id != null) {
      ref.read(tasksProvider.notifier).deleteTask(widget.task!.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  // ─── Section Label ───────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2),
    );
  }

  // ─── Priority Chip ───────────────────────────────
  Widget _priorityChip(String label, int value) {
    final isSelected = _priority == value;
    final task = Task(
      title: '',
      isCompleted: false,
      deadline: DateTime.now(),
      createdAt: DateTime.now(),
      priority: value,
    );
    final color = task.priorityColor;

    return GestureDetector(
      onTap: () => setState(() => _priority = value),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceSM),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusChip),
          border: Border.all(color: color, width: isSelected ? 0 : 1),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: Offset(0, 3))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasDeadline = _deadline != null;

    // Deadline urgency color
    Color deadlineButtonColor = AppTheme.primary;
    if (hasDeadline) {
      final tempTask = Task(title: '', isCompleted: false, deadline: _deadline!, createdAt: DateTime.now());
      deadlineButtonColor = tempTask.isOverdue
          ? AppTheme.error
          : tempTask.isUrgent
          ? AppTheme.priorityHigh
          : AppTheme.primary;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New Task' : 'Edit Task'),
        actions: [
          // Delete (existing tasks only)
          if (!_isNew)
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppTheme.error),
              tooltip: 'Delete Task',
              onPressed: _deleteTask,
            ),

          // Save Button
          Padding(
            padding: EdgeInsets.only(right: AppConstants.spaceSM),
            child: FilledButton.icon(
              onPressed: _saveTask,
              icon: Icon(Icons.save_rounded, size: 16),
              label: Text('Save'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusButton)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ─────────────────────────────
            _sectionLabel('TITLE'),
            SizedBox(height: AppConstants.spaceSM),
            TextField(
              controller: _titleController,
              autofocus: _isNew,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                prefixIcon: Icon(Icons.task_alt_outlined, color: AppTheme.primary),
              ),
            ),

            SizedBox(height: AppConstants.spaceXL),

            // ── Description ───────────────────────
            _sectionLabel('DESCRIPTION'),
            SizedBox(height: AppConstants.spaceSM),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Add more details...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes_outlined, color: Colors.grey),
                ),
              ),
            ),

            SizedBox(height: AppConstants.spaceXL),

            // ── Priority ──────────────────────────
            _sectionLabel('PRIORITY'),
            SizedBox(height: AppConstants.spaceMD),
            Row(
              children: [
                _priorityChip('Low', 0),
                SizedBox(width: AppConstants.spaceSM),
                _priorityChip('Medium', 1),
                SizedBox(width: AppConstants.spaceSM),
                _priorityChip('High', 2),
              ],
            ),

            SizedBox(height: AppConstants.spaceXL),

            // ── Deadline ──────────────────────────
            _sectionLabel('DEADLINE'),
            SizedBox(height: AppConstants.spaceSM),
            GestureDetector(
              onTap: _pickDeadline,
              child: AnimatedContainer(
                duration: AppConstants.animNormal,
                padding: EdgeInsets.all(AppConstants.spaceLG),
                decoration: BoxDecoration(
                  color: hasDeadline
                      ? deadlineButtonColor.withValues(alpha: 0.08)
                      : isDark
                      ? AppTheme.darkCard
                      : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  border: Border.all(
                    color: hasDeadline
                        ? deadlineButtonColor.withValues(alpha: 0.4)
                        : Colors.grey.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppConstants.spaceSM),
                      decoration: BoxDecoration(
                        color: deadlineButtonColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                      ),
                      child: Icon(
                        hasDeadline ? Icons.event_available : Icons.calendar_today_outlined,
                        color: deadlineButtonColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppConstants.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasDeadline ? DateFormatter.format(_deadline!) : 'Set a deadline',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: hasDeadline ? deadlineButtonColor : Colors.grey,
                            ),
                          ),
                          if (hasDeadline) ...[
                            SizedBox(height: 2),
                            Text(
                              DateFormatter.formatDeadline(_deadline!),
                              style: TextStyle(fontSize: 12, color: deadlineButtonColor.withValues(alpha: 0.7)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppConstants.spaceXL),

            // ── Folder ────────────────────────────
            Consumer(
              builder: (context, ref, _) {
                final folders = ref.watch(foldersProvider);
                if (folders.isEmpty) return SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('FOLDER'),
                    SizedBox(height: AppConstants.spaceSM),
                    DropdownButtonFormField<int?>(
                      value: _folderId,
                      dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.folder_outlined,
                          color: _folderId != null ? _getFolderColor(folders, _folderId!) : Colors.grey,
                        ),
                        hintText: 'No Folder',
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            'No Folder',
                            style: TextStyle(color: isDark ? Colors.white70 : AppTheme.textPrimary),
                          ),
                        ),
                        ...folders.map(
                          (folder) => DropdownMenuItem(
                            value: folder.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(color: folder.folderColor, shape: BoxShape.circle),
                                ),
                                SizedBox(width: AppConstants.spaceSM),
                                Text(
                                  folder.name,
                                  style: TextStyle(color: isDark ? Colors.white70 : AppTheme.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _folderId = value),
                    ),
                    SizedBox(height: AppConstants.spaceXL),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Get Folder Color ────────────────────────────
  Color _getFolderColor(List<Folder> folders, int id) {
    try {
      return folders.firstWhere((f) => f.id == id).folderColor;
    } catch (_) {
      return Colors.grey;
    }
  }
}
