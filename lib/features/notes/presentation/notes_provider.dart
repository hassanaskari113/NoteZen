import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notezen/features/notes/domain/notes.dart';
import 'package:notezen/features/notes/data/note_repository.dart';

class NotesNotifier extends Notifier<List<Note>> {
  final NoteRepository _repository = NoteRepository();

  @override
  List<Note> build() {
    loadNotes();
    return [];
  }

  // ─── Load All Notes ──────────────────────────────
  Future<void> loadNotes() async {
    final notes = await _repository.getAllNotes();
    state = notes;
  }

  // ─── Add Note ────────────────────────────────────
  Future<void> addNote(Note note) async {
    await _repository.insertNote(note);
    await loadNotes();
  }

  // ─── Update Note ─────────────────────────────────
  Future<void> updateNote(Note note) async {
    await _repository.updateNote(note);
    await loadNotes();
  }

  // ─── Delete Note ─────────────────────────────────
  Future<void> deleteNote(int id) async {
    await _repository.deleteNote(id);
    await loadNotes();
  }

  // ─── Toggle Pin ──────────────────────────────────
  Future<void> togglePin(Note note) async {
    await _repository.togglePin(note);
    await loadNotes();
  }

  // ─── Toggle Pin By Id ────────────────────────────
  Future<void> togglePinById(int id) async {
    final note = await _repository.getNoteById(id);
    if (note != null) {
      await _repository.togglePin(note);
      await loadNotes();
    }
  }

  // ─── Search Notes ────────────────────────────────
  Future<List<Note>> searchNotes(String query) async {
    return await _repository.searchNotes(query);
  }

  // ─── Get Pinned Notes ────────────────────────────
  List<Note> get pinnedNotes => state.where((n) => n.isPinned).toList();

  // ─── Get Unpinned Notes ──────────────────────────
  List<Note> get unpinnedNotes => state.where((n) => !n.isPinned).toList();

  // ─── Get Notes By Folder ─────────────────────────
  List<Note> getNotesByFolder(int folderId) => state.where((n) => n.folderId == folderId).toList();

  // ─── Get Note By Id From State ───────────────────
  Note? getNoteById(int id) {
    try {
      return state.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }
}

final notesProvider = NotifierProvider<NotesNotifier, List<Note>>(() => NotesNotifier());
