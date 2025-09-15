import 'package:music_app/src/data/models/song.dart';
import 'package:music_app/src/data/repositories/music_repository.dart';

class SearchSongs {
  final MusicRepository _musicRepository;

  SearchSongs(this._musicRepository);

  Future<List<Song>> call(String query) async {
    if (query.isEmpty) {
      return [];
    }

    // 搜索歌曲的业务逻辑
    // 可以在这里添加搜索历史记录、过滤等逻辑
    return await _musicRepository.searchSongs(query);
  }
}