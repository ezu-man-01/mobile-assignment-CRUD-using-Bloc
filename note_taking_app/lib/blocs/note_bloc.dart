import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/note_model.dart';
import '../../services/api_service.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final ApiService apiService;

  final List<Note> _notes = [];

  NoteBloc({required this.apiService}) : super(NoteInitial()) {
    on<FetchNotes>(_onFetchNotes);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onFetchNotes(FetchNotes event, Emitter<NoteState> emit) async {
    emit(NoteLoading());

    try {
      final notes = await apiService.fetchNotes();

      _notes
        ..clear()
        ..addAll(notes);

      if (_notes.isEmpty) {
        emit(NoteEmpty());
      } else {
        emit(NoteLoaded(List.from(_notes)));
      }
    } catch (e) {
      emit(NoteOperationFailure(e.toString()));
    }
  }

  Future<void> _onCreateNote(CreateNote event, Emitter<NoteState> emit) async {
    try {
      final newNote = await apiService.createNote(event.note);

      _notes.insert(0, newNote);

      emit(NoteLoaded(List.from(_notes)));
    } catch (e) {
      emit(NoteOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NoteState> emit) async {
    try {
      final updatedNote = await apiService.updateNote(event.note);

      final index = _notes.indexWhere((note) => note.id == updatedNote.id);

      if (index != -1) {
        _notes[index] = updatedNote;
      }

      emit(NoteLoaded(List.from(_notes)));
    } catch (e) {
      emit(NoteOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NoteState> emit) async {
    try {
      await apiService.deleteNote(event.id);

      _notes.removeWhere((note) => note.id == event.id);

      if (_notes.isEmpty) {
        emit(NoteEmpty());
      } else {
        emit(NoteLoaded(List.from(_notes)));
      }
    } catch (e) {
      emit(NoteOperationFailure(e.toString()));
    }
  }
}
