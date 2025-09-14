import 'dart:convert';
import 'package:dio/dio.dart';

/// A service to interact with a third-party music API (gdstudio.xyz).
///
/// This service provides methods to search for songs and retrieve song details.
class GdApiService {
  final Dio _dio;

  GdApiService(this._dio) {
    _dio.options.baseUrl = 'https://music-api.gdstudio.xyz';
    _dio.options.connectTimeout = const Duration(seconds: 50);
    _dio.options.receiveTimeout = const Duration(seconds: 50);

    // The new API endpoint seems to not require special headers, 
    // but keeping a user-agent is generally a good practice.
    _dio.options.headers['user-agent'] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36';
  }


  /// Searches for songs by a given keyword.
  Future<List<dynamic>> searchSongs(String keyword) async {
    try {
      final response = await _dio.get(
        '/api.php',
        queryParameters: {
          'types': 'search',
          'count': 10,
          'source': 'kuwo',
          'pages': 1,
          'name': keyword,
        },
      );

      if (response.data == null) {
        return [];
      }

      // The new API returns JSON directly.
      // Dio automatically decodes it.
      final data = response.data;

      if (data is List) {
        return data;
      } else if (data is Map<String, dynamic> && data.containsKey('data')) {
        return data['data'] as List<dynamic>;
      }

      return [];
    } catch (e) {
      print('Error searching songs in GdApiService: $e');
      return [];
    }
  }

  /// Retrieves the details (including the URL) for a specific song by its ID.
  Future<Map<String, dynamic>> getSongDetail(String songId) async {
    try {
      final response = await _dio.get(
        '/api.php',
        queryParameters: {
          'types': 'url',
          'id': songId,
          'source': 'kuwo',
          'br': 320, // Requesting 320kbps bitrate
        },
      );

      if (response.data == null) {
        return {};
      }

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;
      }

      return {};
    } catch (e) {
      print('Error getting song detail in GdApiService: $e');
      return {};
    }
  }
}
