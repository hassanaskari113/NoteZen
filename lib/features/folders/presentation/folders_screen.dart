import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/core/constants/app_constants.dart';
import 'package:notezen/core/themes/app_theme.dart';
import 'package:notezen/features/folders/domain/folders.dart';
import 'package:notezen/features/folders/presentation/folders_provider.dart';
import 'package:notezen/features/folders/presentation/folder_content_screen.dart';
import 'package:notezen/features/folders/presentation/folders_detail_screen.dart';
import 'package:notezen/shared/providers/search_provider.dart';
import 'package:notezen/shared/widgets/empty_state.dart';
import 'package:notezen/shared/widgets/settings_screen.dart';

class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(foldersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Folders'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen())),
          ),
        ],
      ),
      body: folders.isEmpty
          ? EmptyState(
              icon: Icons.folder_outlined,
              title: 'No Folders Yet',
              subtitle: 'Tap + to organize your\nnotes and tasks',
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceSM),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppConstants.spaceSM),
                  child: FolderTile(folder: folders[index]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FolderDetailScreen())),
        tooltip: 'New Folder',
        child: Icon(Icons.create_new_folder_outlined),
      ),
    );
  }
}

// ─── Folder Tile ─────────────────────────────────────
class FolderTile extends ConsumerWidget {
  const FolderTile({super.key, required this.folder});
  final Folder folder;

  // ─── Delete Confirmation Dialog ──────────────────
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 24),
            SizedBox(width: AppConstants.spaceSM),
            Text('Delete Folder'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${folder.name}"?', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: AppConstants.spaceSM),
            Text(
              'Notes and tasks inside will not be deleted — they will just be removed from this folder.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
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

    if (confirmed == true) {
      ref.read(foldersProvider.notifier).deleteFolder(folder.id!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final folderColor = folder.folderColor;
    final notes = ref.watch(folderNotesProvider(folder.id!));
    final tasks = ref.watch(folderTasksProvider(folder.id!));

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FolderContentsScreen(folder: folder))),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // ── Color Bar ──────────────────────
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: folderColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusCard),
                    bottomLeft: Radius.circular(AppConstants.radiusCard),
                  ),
                ),
              ),

              // ── Folder Icon ────────────────────
              Padding(
                padding: EdgeInsets.all(AppConstants.spaceMD),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: folderColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.folder_rounded, color: folderColor, size: 26),
                ),
              ),

              // ─── Folder Info ────────────────────
              Flexible(
                // ✅ CHANGED (was Expanded)
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppConstants.spaceMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        folder.name,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),

                      // ✅ FIX: prevent overflow here
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _countChip(
                              context: context,
                              icon: Icons.note_outlined,
                              count: notes.length,
                              label: 'notes',
                              isDark: isDark,
                            ),
                            SizedBox(width: AppConstants.spaceSM),
                            _countChip(
                              context: context,
                              icon: Icons.task_outlined,
                              count: tasks.length,
                              label: 'tasks',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Actions ────────────────────────
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 16),
                      color: Colors.grey,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FolderDetailScreen(folder: folder)),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 16),
                      color: AppTheme.error.withValues(alpha: 0.7),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                    SizedBox(width: AppConstants.spaceSM),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                    SizedBox(width: AppConstants.spaceSM),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Count Chip ──────────────────────────────────
  Widget _countChip({
    required BuildContext context,
    required IconData icon,
    required int count,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceXS + 2, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: Colors.grey),
          SizedBox(width: 1),
          Text(
            '$count $label',
            style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
