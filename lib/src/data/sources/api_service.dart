import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _dio.options.baseUrl = 'http://tangdou.space:58000';
    _dio.options.connectTimeout = const Duration(seconds: 50);
    _dio.options.receiveTimeout = const Duration(seconds: 50);
    _dio.options.headers['Authorization'] = 'Bearer 123567';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<List<dynamic>> searchSongs(String keyword) async {
    try {
      final response = await _dio.post(
        '/music/search',
        data: {'keyword': keyword},
      );
      return response.data as List<dynamic>;
    } catch (e) {
      // Handle error
      print('Error searching songs: $e');
      return [];
    }
  }
}
