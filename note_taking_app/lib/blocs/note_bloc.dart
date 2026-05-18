import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/note_model.dart';
import '../../services/api_service.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final ApiService apiService;

  List<Note> _notes = [];

  NoteBloc({required this.apiService}) : super(NoteInitial()) {
    on<FetchNotes>(_onFetchNotes);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onFetchNotes(FetchNotes event, Emitter<NoteState> emit) async {
    emit(NoteLoading());

    try {
      final notes = [
        const Note(
          id: 1,
          title: 'Flutter Study Plan',
          content: 'Finish Bloc architecture and Dio networking.',
        ),
        const Note(
          id: 2,
          title: 'Trading Reminder',
          content: 'Check XAUUSD trend before London session.',
        ),
        const Note(
          id: 3,
          title: 'Content Ideas',
          content: 'Record study technique videos.',
        ),
      ];
      _notes = notes.take(3).toList();

      if (_notes.isEmpty) {
        emit(NoteEmpty());
      } else {
        emit(NoteLoaded(_notes));
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
      final updated = await apiService.updateNote(event.note);

      final index = _notes.indexWhere((note) => note.id == updated.id);

      if (index != -1) {
        _notes[index] = updated;
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
