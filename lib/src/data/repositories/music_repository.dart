
import 'package:music_app/src/data/models/song.dart';

/// A repository that handles all music-related data operations.
abstract class MusicRepository {
  /// Searches for songs with the given [keyword].
  Future<List<Song>> searchSongs(String keyword);
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
    // This is the data you provided earlier.
    return [
      const Song(
        id: "11561889",
        title: "枫",
        artist: "周杰伦",
        href: "/music/11561889",
        playUrl: "https://lv-sycdn.kuwo.cn/36cbdb0d68c74a14e47ff30b7aeafcea/688596d3/resource/30106/trackmedia/M500003KtYhg4frNXC.mp3?bitrate\$128&from=vip",
      ),
      const Song(
        id: "11561895",
        title: "枫",
        artist: "曾一鸣",
        href: "/music/11561895",
        playUrl: "https://gs-sycdn.kuwo.cn/8f724067d0fe32aac4bc8416f62642e8/68859e3d/resource/n3/29/38/2785466100.mp3?bitrate\$128&from=vip",
      ),
      const Song(
        id: "11561890",
        title: "枫(Live)",
        artist: "周杰伦",
        href: "/music/11561890",
        playUrl: "https://gg-sycdn.kuwo.cn/3a3cb1c5b3731d07a5dd959e1d435354/68859e3f/resource/n1/48/12/2278260523.mp3?bitrate\$128&from=vip",
      ),
      const Song(
        id: "11561892",
        title: "枫(片段)",
        artist: "隔壁老樊",
        href: "/music/11561892",
        playUrl: "https://er-sycdn.kuwo.cn/ff4c99c311a4014fb7aa7add4fe4dc59/68859e41/resource/30106/trackmedia/M500000zKujF0Yh5vV.mp3?bitrate\$128&from=vip",
      ),
    ];
  }
}
