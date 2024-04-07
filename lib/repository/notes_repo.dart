import 'package:banao_notes_app_task3/services/note_db.dart';
import '../model/note_model.dart';

class NotesRepository {
  final NotesDatabase _dbHelper = NotesDatabase();

  Future<List<Note>> getAllNotes() async => await _dbHelper.readAllNotes();
  Future<void> closeDB() async => await _dbHelper.closeDB();
  Future<Note?> getNoteById(int id) async => await _dbHelper.readOneNotes(id);
  Future<Note?> createNote(Note note) async => await _dbHelper.insertData(note);
  Future<bool> deleteNoteById(int id) async => await _dbHelper.deleteNotes(id);
  Future<bool> updateNoteById(Note note) async => await _dbHelper.updateNotes(note);
}
