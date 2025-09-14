import 'package:music_app/src/data/models/song.dart';
import 'package:music_app/src/data/sources/api_service.dart';
import 'package:music_app/src/data/sources/gd_api_service.dart';

/// A repository that handles all music-related data operations.
abstract class MusicRepository {
  /// Searches for songs with the given [keyword].
  Future<List<Song>> searchSongs(String keyword);

  /// Fetches the details of a song, including its play URL.
  Future<Song> getSongDetail(Song href);
}

/// A mock implementation of [MusicRepository] that returns fake data.
///
/// This is useful for developing and testing UI features without
/// making actual network calls.
class MockMusicRepository implements MusicRepository {
  @override
  Future<List<Song>> searchSongs(String keyword) async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return a predefined list of songs, ignoring the keyword for now.
    return [
      const Song(
        id: "11561889",
        title: "枫",
        artist: "周杰伦",
        href: "/music/11561889",
        playUrl:
            "https://lv-sycdn.kuwo.cn/36cbdb0d68c74a14e47ff30b7aeafcea/688596d3/resource/30106/trackmedia/M500003KtYhg4frNXC.mp3?bitrate\$128&from=vip",
      ),
      const Song(
        id: "11561895",
        title: "枫",
        artist: "曾一鸣",
        href: "/music/11561895",
        playUrl:
            "https://gs-sycdn.kuwo.cn/8f724067d0fe32aac4bc8416f62642e8/68859e3d/resource/n3/29/38/2785466100.mp3?bitrate\$128&from=vip",
      ),
    ];
  }

  @override
  Future<Song> getSongDetail(Song href) async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return a predefined song, ignoring the href for now.
    return const Song(
      id: "11561889",
      title: "枫",
      artist: "周杰伦",
      href: "/music/11561889",
      playUrl:
          "https://lv-sycdn.kuwo.cn/36cbdb0d68c74a14e47ff30b7aeafcea/688596d3/resource/30106/trackmedia/M500003KtYhg4frNXC.mp3?bitrate\$128&from=vip",
    );
  }
}

/// An implementation of [MusicRepository] that communicates with a real API.
class ApiMusicRepository implements MusicRepository {
  final GdApiService _apiService;

  ApiMusicRepository(this._apiService);

  @override
  Future<List<Song>> searchSongs(String keyword) async {
    final results = await _apiService.searchSongs(keyword);
    return results
        .map((json) => Song.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Song> getSongDetail(Song song) async {
    final result = await _apiService.getSongDetail(song.id);
    final url = result['url'] as String?;
    song = song.copyWith(playUrl: url);
    return song;
  }
}
