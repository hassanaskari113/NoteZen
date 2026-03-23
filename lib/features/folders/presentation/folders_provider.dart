import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/features/folders/domain/folders.dart';
import 'package:notezen/features/folders/data/folder_repository.dart';

class FoldersNotifier extends Notifier<List<Folder>> {
  final FolderRepository _repository = FolderRepository();

  @override
  List<Folder> build() {
    loadFolders();
    return [];
  }

  // ─── Load All Folders ────────────────────────────
  Future<void> loadFolders() async {
    final folders = await _repository.getAllFolders();
    state = folders;
  }

  // ─── Add Folder ──────────────────────────────────
  Future<void> addFolder(Folder folder) async {
    await _repository.insertFolder(folder);
    await loadFolders();
  }

  // ─── Update Folder ───────────────────────────────
  Future<void> updateFolder(Folder folder) async {
    await _repository.updateFolder(folder);
    await loadFolders();
  }

  // ─── Delete Folder ───────────────────────────────
  Future<void> deleteFolder(int id) async {
    await _repository.deleteFolder(id);
    await loadFolders();
  }

  // ─── Get Folder By Id ────────────────────────────
  Folder? getFolderById(int id) {
    try {
      return state.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Check Name Exists ───────────────────────────
  bool nameExists(String name, {int? excludeId}) {
    return state.any((f) => f.name.toLowerCase() == name.toLowerCase() && f.id != excludeId);
  }
}

final foldersProvider = NotifierProvider<FoldersNotifier, List<Folder>>(() => FoldersNotifier());
