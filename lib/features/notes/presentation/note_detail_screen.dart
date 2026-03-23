import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/core/constants/app_constants.dart';
import 'package:notezen/core/themes/app_theme.dart';
import 'package:notezen/features/notes/domain/notes.dart';
import 'package:notezen/features/notes/presentation/notes_provider.dart';
import 'package:notezen/features/folders/presentation/folders_provider.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  const NoteDetailScreen({super.key, this.note});
  final Note? note;

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  int? _folderId;
  int _color = 0xFFFFFFFF;
  bool _isPinned = false;
  bool _isNew = true;

  // ─── Note Color Palette ──────────────────────────
  final List<Map<String, dynamic>> _colorPalette = [
    {'color': 0xFFFFFFFF, 'label': 'Default'},
    {'color': 0xFFFFF9C4, 'label': 'Yellow'},
    {'color': 0xFFE8F5E9, 'label': 'Green'},
    {'color': 0xFFE3F2FD, 'label': 'Blue'},
    {'color': 0xFFFCE4EC, 'label': 'Pink'},
    {'color': 0xFFF3E5F5, 'label': 'Purple'},
    {'color': 0xFFE0F7FA, 'label': 'Cyan'},
    {'color': 0xFFFFF3E0, 'label': 'Orange'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _isNew = false;
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _folderId = widget.note!.folderId;
      _color = widget.note!.color;
      _isPinned = widget.note!.isPinned;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ─── Save Note ───────────────────────────────────
  void _saveNote() {
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

    if (_isNew) {
      ref
          .read(notesProvider.notifier)
          .addNote(
            Note(
              title: _titleController.text.trim(),
              content: _contentController.text,
              color: _color,
              isPinned: _isPinned,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              folderId: _folderId,
            ),
          );
    } else {
      ref
          .read(notesProvider.notifier)
          .updateNote(
            widget.note!.copyWith(
              title: _titleController.text.trim(),
              content: _contentController.text,
              color: _color,
              isPinned: _isPinned,
              updatedAt: DateTime.now(),
              folderId: _folderId,
              clearFolder: _folderId == null,
            ),
          );
    }
    Navigator.pop(context);
  }

  // ─── Delete Note ─────────────────────────────────
  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: AppTheme.error, size: 24),
            SizedBox(width: AppConstants.spaceSM),
            Text('Delete Note'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
          style: TextStyle(fontSize: 14),
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

    if (confirmed == true && widget.note?.id != null) {
      ref.read(notesProvider.notifier).deleteNote(widget.note!.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  // ─── Color Picker Sheet ──────────────────────────
  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.all(AppConstants.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: AppConstants.spaceLG),

              Text(
                'NOTE COLOR',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2),
              ),
              SizedBox(height: AppConstants.spaceMD),

              // Color Grid
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: AppConstants.spaceSM,
                  mainAxisSpacing: AppConstants.spaceSM,
                  childAspectRatio: 1.5,
                ),
                itemCount: _colorPalette.length,
                itemBuilder: (ctx, index) {
                  final item = _colorPalette[index];
                  final colorValue = item['color'] as int;
                  final label = item['label'] as String;
                  final isSelected = _color == colorValue;

                  return GestureDetector(
                    onTap: () {
                      setSheetState(() => _color = colorValue);
                      setState(() => _color = colorValue);
                    },
                    child: AnimatedContainer(
                      duration: AppConstants.animFast,
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : Colors.grey.withValues(alpha: 0.3),
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSelected) Icon(Icons.check_rounded, size: 18, color: AppTheme.primary),
                          Text(
                            label,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: AppConstants.spaceLG),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final noteBackground = isDark ? AppTheme.darkCard : Color(_color);

    return Scaffold(
      backgroundColor: noteBackground,
      appBar: AppBar(
        backgroundColor: noteBackground,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Text(_isNew ? 'New Note' : 'Edit Note'),
        actions: [
          // Pin Toggle
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? AppTheme.primary : null,
            ),
            tooltip: _isPinned ? 'Unpin' : 'Pin',
            onPressed: () => setState(() => _isPinned = !_isPinned),
          ),

          // Color Picker
          IconButton(icon: Icon(Icons.palette_outlined), tooltip: 'Note Color', onPressed: _showColorPicker),

          // Delete (only for existing notes)
          if (!_isNew)
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppTheme.error),
              tooltip: 'Delete Note',
              onPressed: _deleteNote,
            ),

          // Save
          Padding(
            padding: EdgeInsets.only(right: AppConstants.spaceSM),
            child: FilledButton.icon(
              onPressed: _saveNote,
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
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceSM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Pin Banner ───────────────────────
            if (_isPinned)
              Container(
                margin: EdgeInsets.only(bottom: AppConstants.spaceMD),
                padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceMD, vertical: AppConstants.spaceXS),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.push_pin, size: 13, color: AppTheme.primary),
                    SizedBox(width: 4),
                    Text(
                      'Pinned Note',
                      style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

            // ── Title Field ──────────────────────
            TextField(
              controller: _titleController,
              autofocus: _isNew,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Title...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : AppTheme.textHint,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            Divider(height: 1),
            SizedBox(height: AppConstants.spaceSM),

            // ── Content Field ────────────────────
            TextField(
              controller: _contentController,
              style: TextStyle(fontSize: 16, height: 1.6, color: isDark ? Colors.white70 : AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Start writing...',
                hintStyle: TextStyle(color: isDark ? Colors.white30 : AppTheme.textHint),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),

            SizedBox(height: AppConstants.spaceXL),

            // ── Folder Picker ────────────────────
            Consumer(
              builder: (context, ref, _) {
                final folders = ref.watch(foldersProvider);
                if (folders.isEmpty) return SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FOLDER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: AppConstants.spaceSM),
                    DropdownButtonFormField<int?>(
                      value: _folderId,
                      dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.folder_outlined, color: AppTheme.primary),
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
}
