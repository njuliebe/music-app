import 'package:dio/dio.dart';
import 'package:music_app/src/features/lyrics/domain/lyric.dart';

// lyricRepositoryProvider is now defined in data/providers.dart

class LyricRepository {
  LyricRepository(this._dio);

  final Dio _dio;

  Future<List<Lyric>> searchLyrics(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final response = await _dio.get(
      'https://lrclib.net/api/search',
      queryParameters: {'q': query},
      options: Options(
        headers: {
          'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8,zh-TW;q=0.7',
          'Connection': 'keep-alive',
          'Referer': 'https://lrclib.net/search/$encodedQuery',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-origin',
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
          'accept': 'application/json',
          'lrclib-client':
              'LRCLIB Web Client (https://github.com/tranxuanthang/lrclib)',
          'sec-ch-ua':
              '"Not)A;Brand";v="8", "Chromium";v="138", "Google Chrome";v="188"',
          'sec-ch-ua-mobile': '?0',
          'sec-ch-ua-platform': '"macOS"',
          'x-user-agent':
              'LRCLIB Web Client (https://github.com/tranxuanthang/lrclib)',
        },
      ),
    );

    final data = response.data as List<dynamic>;
    return data.map((e) => Lyric.fromJson(e as Map<String, dynamic>)).toList();
  }
}
