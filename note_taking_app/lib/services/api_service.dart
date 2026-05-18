import 'package:dio/dio.dart';

import '../models/note_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<List<Note>> fetchNotes() async {
    try {
      final response = await _dio.get('/posts');

      final List data = response.data;

      return data.map((json) => Note.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<Note> createNote(Note note) async {
    try {
      final response = await _dio.post('/posts', data: note.toJson());

      return Note.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<Note> updateNote(Note note) async {
    try {
      final response = await _dio.put('/posts/${note.id}', data: note.toJson());

      return Note.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await _dio.delete('/posts/$id');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';

      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';

      case DioExceptionType.badResponse:
        return 'Server error occurred';

      case DioExceptionType.connectionError:
        return 'No internet connection';

      default:
        return 'Unexpected network error';
    }
  }
}
