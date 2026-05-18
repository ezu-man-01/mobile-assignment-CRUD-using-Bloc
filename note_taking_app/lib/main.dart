import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'blocs/note_bloc.dart';
import 'screens/list_screen.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const NoteMasterApp());
}

class NoteMasterApp extends StatelessWidget {
  const NoteMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ApiService(),
      child: BlocProvider(
        create: (context) =>
            NoteBloc(apiService: context.read<ApiService>())..add(FetchNotes()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Note Master Pro',
          themeMode: ThemeMode.system,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.deepPurple,
            textTheme: GoogleFonts.poppinsTextTheme(),
            scaffoldBackgroundColor: const Color(0xFFF7F7FB),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.deepPurple,
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          ),
          home: const NoteListScreen(),
        ),
      ),
    );
  }
}
