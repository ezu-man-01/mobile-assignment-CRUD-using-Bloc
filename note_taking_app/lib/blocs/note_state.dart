part of 'note_bloc.dart';

abstract class NoteState {}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteLoaded extends NoteState {
  final List<Note> notes;

  NoteLoaded(this.notes);
}

class NoteEmpty extends NoteState {}

class NoteOperationFailure extends NoteState {
  final String message;

  NoteOperationFailure(this.message);
}
