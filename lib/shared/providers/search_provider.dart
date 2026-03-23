import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/features/notes/domain/notes.dart';
import 'package:notezen/features/tasks/domain/tasks.dart';
import 'package:notezen/features/notes/presentation/notes_provider.dart';
import 'package:notezen/features/tasks/presentation/tasks_provider.dart';

// ─── Search Query Notifier ───────────────────────────
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query.trim();
  }

  void clearQuery() {
    state = '';
  }

  bool get hasQuery => state.isNotEmpty;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() => SearchQueryNotifier());

// ─── Filtered Notes ──────────────────────────────────
final filteredNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(notesProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) return notes;

  final q = query.toLowerCase();
  return notes.where((note) => note.title.toLowerCase().contains(q) || note.content.toLowerCase().contains(q)).toList();
});

// ─── Filtered Tasks ──────────────────────────────────
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) return tasks;

  final q = query.toLowerCase();
  return tasks
      .where((task) => task.title.toLowerCase().contains(q) || (task.description?.toLowerCase().contains(q) ?? false))
      .toList();
});

// ─── Folder Notes ────────────────────────────────────
final folderNotesProvider = Provider.family<List<Note>, int>((ref, folderId) {
  final notes = ref.watch(notesProvider);
  return notes.where((note) => note.folderId == folderId).toList();
});

// ─── Folder Tasks ────────────────────────────────────
final folderTasksProvider = Provider.family<List<Task>, int>((ref, folderId) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((task) => task.folderId == folderId).toList();
});

// ─── Overdue Tasks ───────────────────────────────────
final overdueTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((t) => t.isOverdue).toList();
});

// ─── Today's Tasks ───────────────────────────────────
final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((t) => t.isDueToday && !t.isCompleted).toList();
});

// ─── Pinned Notes ────────────────────────────────────
final pinnedNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(notesProvider);
  return notes.where((n) => n.isPinned).toList();
});

// ─── High Priority Tasks ─────────────────────────────
final highPriorityTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((t) => t.priority == 2 && !t.isCompleted).toList();
});
