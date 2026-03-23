import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/core/constants/app_constants.dart';
import 'package:notezen/core/themes/app_theme.dart';
import 'package:notezen/core/utils/date_formatter.dart';
import 'package:notezen/features/notes/domain/notes.dart';
import 'package:notezen/features/notes/presentation/note_detail_screen.dart';
import 'package:notezen/features/notes/presentation/notes_provider.dart';
import 'package:notezen/shared/providers/search_provider.dart';
import 'package:notezen/shared/widgets/empty_state.dart';
import 'package:notezen/shared/widgets/settings_screen.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
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
    final notes = ref.watch(filteredNotesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : AppTheme.textHint),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (query) => ref.read(searchQueryProvider.notifier).updateQuery(query),
              )
            : Text('Notes'),
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
        child: notes.isEmpty
            ? EmptyState(
                key: ValueKey('empty'),
                icon: Icons.note_outlined,
                title: _isSearching ? 'No Results Found' : 'No Notes Yet',
                subtitle: _isSearching ? 'Try a different search term' : 'Tap + to create your first note',
              )
            : ListView.builder(
                key: ValueKey('list'),
                padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceSM),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppConstants.spaceSM),
                    child: NoteCard(note: notes[index]),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailScreen())),
        tooltip: 'New Note',
        child: Icon(Icons.edit_outlined),
      ),
    );
  }
}

// ─── Note Card ───────────────────────────────────────
class NoteCard extends ConsumerWidget {
  const NoteCard({super.key, required this.note});
  final Note note;

  // ─── Delete Confirmation ─────────────────────────
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: AppTheme.error, size: 22),
            SizedBox(width: AppConstants.spaceSM),
            Text('Delete Note'),
          ],
        ),
        content: Text('Delete "${note.title}"? This cannot be undone.', style: TextStyle(fontSize: 14)),
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

    if (confirmed == true && note.id != null) {
      ref.read(notesProvider.notifier).deleteNote(note.id!);
    }
  }

  // ─── Toggle Pin ──────────────────────────────────
  void _togglePin(WidgetRef ref) {
    ref.read(notesProvider.notifier).togglePin(note);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // In dark mode ignore note color — use dark card
    final cardColor = isDark ? AppTheme.darkCard : Color(note.color);

    // Text colors based on background
    final titleColor = isDark ? Colors.white : AppTheme.textPrimary;
    final contentColor = isDark ? Colors.white60 : AppTheme.textSecondary;
    final metaColor = isDark ? Colors.white38 : Colors.grey;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note))),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          border: note.isPinned
              ? Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5)
              : Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.15),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card Body ──────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.spaceLG,
                AppConstants.spaceMD,
                AppConstants.spaceSM,
                AppConstants.spaceMD,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Text Content ───────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          note.title,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: titleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (note.hasContent) ...[
                          SizedBox(height: 4),
                          Text(
                            note.contentPreview,
                            style: TextStyle(fontSize: 13, color: contentColor, height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Action Buttons ─────────
                  Column(
                    children: [
                      // Pin Button
                      GestureDetector(
                        onTap: () => _togglePin(ref),
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.spaceXS),
                          child: Icon(
                            note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            size: 18,
                            color: note.isPinned ? AppTheme.primary : metaColor,
                          ),
                        ),
                      ),

                      // Delete Button
                      GestureDetector(
                        onTap: () => _confirmDelete(context, ref),
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.spaceXS),
                          child: Icon(Icons.delete_outline, size: 18, color: AppTheme.error.withValues(alpha: 0.6)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Divider ────────────────────────
            Divider(height: 1, indent: 16, endIndent: 16),

            // ── Footer ─────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceXS + 2),
              child: Row(
                children: [
                  // Pinned badge
                  if (note.isPinned) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.push_pin, size: 10, color: AppTheme.primary),
                          SizedBox(width: 3),
                          Text(
                            'Pinned',
                            style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppConstants.spaceSM),
                  ],

                  Spacer(),

                  // Date
                  Text(DateFormatter.formatShort(note.updatedAt), style: TextStyle(fontSize: 11, color: metaColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
