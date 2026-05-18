import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/note_bloc.dart';
import '../models/note_model.dart';
import '../widgets/error_view.dart';
import '../widgets/note_card.dart';
import 'detail_screen.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({super.key});

  Future<void> _openEditor(BuildContext context, {Note? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
    );

    if (result != null && context.mounted) {
      if (note == null) {
        context.read<NoteBloc>().add(CreateNote(result));
      } else {
        context.read<NoteBloc>().add(UpdateNote(result));
      }
    }
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Delete Note'),
            ],
          ),
          content: const Text(
            'Are you sure you want to permanently delete this note?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note Master Pro'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
      body: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NoteLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NoteOperationFailure) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<NoteBloc>().add(FetchNotes());
              },
            );
          }

          if (state is NoteEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No notes available',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap the button below to create your first note.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is NoteLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<NoteBloc>().add(FetchNotes());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: NoteCard(
                      note: note,
                      onTap: () {
                        _openEditor(context, note: note);
                      },
                      onDelete: () async {
                        final confirmed = await _showDeleteDialog(context);

                        if (confirmed == true && context.mounted) {
                          context.read<NoteBloc>().add(DeleteNote(note.id!));
                        }
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
