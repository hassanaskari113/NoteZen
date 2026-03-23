import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/core/constants/app_constants.dart';
import 'package:notezen/core/themes/app_theme.dart';
import 'package:notezen/features/folders/domain/folders.dart';
import 'package:notezen/features/folders/presentation/folders_provider.dart';

class FolderDetailScreen extends ConsumerStatefulWidget {
  const FolderDetailScreen({super.key, this.folder});
  final Folder? folder;

  @override
  ConsumerState<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _color = 0xFF42A5F5;

  final List<int> _colorOptions = [
    0xFF6C63FF, // purple (brand)
    0xFF42A5F5, // blue
    0xFF66BB6A, // green
    0xFFEF5350, // red
    0xFFFFA726, // orange
    0xFFAB47BC, // purple
    0xFF26C6DA, // cyan
    0xFFEC407A, // pink
    0xFF78909C, // grey-blue
    0xFFFFFFFF, // white
  ];

  @override
  void initState() {
    super.initState();
    if (widget.folder != null) {
      _nameController.text = widget.folder!.name;
      _color = widget.folder!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ─── Save Folder ─────────────────────────────────
  void _saveFolder() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 18),
              SizedBox(width: AppConstants.spaceSM),
              Text('Please enter a folder name'),
            ],
          ),
        ),
      );
      return;
    }

    final exists = ref
        .read(foldersProvider.notifier)
        .nameExists(_nameController.text.trim(), excludeId: widget.folder?.id);

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 18),
              SizedBox(width: AppConstants.spaceSM),
              Text('A folder with this name already exists'),
            ],
          ),
        ),
      );
      return;
    }

    if (widget.folder == null) {
      ref
          .read(foldersProvider.notifier)
          .addFolder(Folder(name: _nameController.text.trim(), color: _color, createdAt: DateTime.now()));
    } else {
      ref
          .read(foldersProvider.notifier)
          .updateFolder(widget.folder!.copyWith(name: _nameController.text.trim(), color: _color));
    }
    Navigator.pop(context);
  }

  // ─── Section Label Widget ────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = Theme.of(context).colorScheme.onSurface;
    final isNew = widget.folder == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'New Folder' : 'Edit Folder'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: AppConstants.spaceSM),
            child: FilledButton.icon(
              onPressed: _saveFolder,
              icon: Icon(Icons.save_rounded, size: 18),
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
            // ── Folder Name ──────────────────────
            _sectionLabel('FOLDER NAME'),
            SizedBox(height: AppConstants.spaceSM),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              autofocus: isNew,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Enter folder name...',
                prefixIcon: Icon(Icons.folder_rounded, color: Color(_color)),
                suffixIcon: _nameController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _nameController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),

            SizedBox(height: AppConstants.spaceXL),

            // ── Color Picker ─────────────────────
            _sectionLabel('PICK A COLOR'),
            SizedBox(height: AppConstants.spaceLG),
            Wrap(
              spacing: AppConstants.spaceMD,
              runSpacing: AppConstants.spaceMD,
              children: _colorOptions.map((colorOption) {
                final isSelected = _color == colorOption;
                final isWhite = colorOption == 0xFFFFFFFF;
                return GestureDetector(
                  onTap: () => setState(() => _color = colorOption),
                  child: AnimatedContainer(
                    duration: AppConstants.animNormal,
                    curve: Curves.easeOutCubic,
                    width: isSelected ? 52 : 44,
                    height: isSelected ? 52 : 44,
                    decoration: BoxDecoration(
                      color: Color(colorOption),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: borderColor, width: 2.5)
                          : Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.3),
                              width: 1,
                            ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(colorOption).withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: isSelected
                        ? Icon(Icons.check_rounded, color: isWhite ? Colors.black : Colors.white, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: AppConstants.spaceXL),

            // ── Live Preview ─────────────────────
            _sectionLabel('PREVIEW'),
            SizedBox(height: AppConstants.spaceMD),
            AnimatedContainer(
              duration: AppConstants.animNormal,
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(AppConstants.spaceLG),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                border: Border.all(color: Color(_color).withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Color(_color).withValues(alpha: 0.1), blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  // Folder Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Color(_color),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Color(_color).withValues(alpha: 0.4), blurRadius: 8, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Icon(Icons.folder_rounded, color: Colors.white, size: 28),
                  ),

                  SizedBox(width: AppConstants.spaceLG),

                  // Folder Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: AppConstants.animFast,
                          child: Text(
                            _nameController.text.isEmpty ? 'Folder Name' : _nameController.text,
                            key: ValueKey(_nameController.text),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: _nameController.text.isEmpty ? Colors.grey : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('0 notes · 0 tasks', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                ],
              ),
            ),

            SizedBox(height: AppConstants.spaceXL),
          ],
        ),
      ),
    );
  }
}
