import 'package:dio/dio.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/data/models/song.dart';

class PlaylistImportService {
  final Dio _dio;

  PlaylistImportService(this._dio);

  // Extracts playlist ID from a given URL
  String? _extractPlaylistId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    // 1. Check the main query parameters
    if (uri.queryParameters.containsKey('id')) {
      return uri.queryParameters['id'];
    }

    // 2. Check the fragment
    if (uri.hasFragment) {
      String fragment = uri.fragment;
      int queryStartIndex = fragment.indexOf('?');
      if (queryStartIndex != -1) {
        String queryString = fragment.substring(queryStartIndex + 1);
        final queryParams = Uri.splitQueryString(queryString);
        if (queryParams.containsKey('id')) {
          return queryParams['id'];
        }
      }
    }

    return null;
  }

  // Imports a playlist from the given URL
  Future<ImportedPlaylist?> importPlaylist(String playlistUrl) async {
    final playlistId = _extractPlaylistId(playlistUrl);
    if (playlistId == null) {
      throw Exception('Invalid playlist URL: Could not extract ID.');
    }

    final response = await _dio.post(
      'https://sss.unmeta.cn/songlist?detailed=false&format=song-singer',
      options: Options(
        headers: {
          'accept': 'application/json, text/plain, */*',
          'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,zh-TW;q=0.7',
          'content-type': 'application/x-www-form-urlencoded',
          'origin': 'https://music.unmeta.cn',
          'referer': 'https://music.unmeta.cn/',
          'sec-ch-ua': '"Not)A;Brand";v="8", "Chromium";v="138", "Google Chrome";v="138"',
          'sec-ch-ua-mobile': '?0',
          'sec-ch-ua-platform': '"macOS"',
          'sec-fetch-dest': 'empty',
          'sec-fetch-mode': 'cors',
          'sec-fetch-site': 'same-site',
          'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
        },
      ),
      data: 'url=$playlistUrl',
    );

    if (response.statusCode == 200 && response.data != null) {
      final Map<String, dynamic> jsonResponse = response.data;
      if (jsonResponse['code'] == 1 && jsonResponse['data'] != null) {
        final Map<String, dynamic> data = jsonResponse['data'];
        final String name = data['name'] ?? '未知歌单';
        final List<dynamic> songStrings = data['songs'] ?? [];

        final List<Song> songs = songStrings.map((s) {
          final parts = s.split(' - ');
          final title = parts.length > 1 ? parts.sublist(0, parts.length - 1).join(' - ') : s;
          final artist = parts.length > 1 ? parts.last : '未知艺术家';
          // Generate unique ID for song based on title and artist
          final songId = '$title - $artist'; // Using combined string as ID

          return Song(
            id: songId,
            title: title,
            artist: artist,
            href: '', // Empty for now
            playUrl: '', // Empty for now
          );
        }).toList();

        return ImportedPlaylist(
          id: playlistId,
          name: name,
          songs: songs,
        );
      } else {
        throw Exception('API error: ${jsonResponse['msg']}');
      }
    } else {
      throw Exception('Failed to load playlist: ${response.statusCode}');
    }
  }
}

// Data class to hold imported playlist data
class ImportedPlaylist {
  final String id;
  final String name;
  final List<Song> songs;

  ImportedPlaylist({
    required this.id,
    required this.name,
    required this.songs,
  });
}
