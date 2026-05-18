part of 'note_bloc.dart';

abstract class NoteEvent {}

class FetchNotes extends NoteEvent {}

class CreateNote extends NoteEvent {
  final Note note;

  CreateNote(this.note);
}

class UpdateNote extends NoteEvent {
  final Note note;

  UpdateNote(this.note);
}

class DeleteNote extends NoteEvent {
  final int id;

  DeleteNote(this.id);
}
