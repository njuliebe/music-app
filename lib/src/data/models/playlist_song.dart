import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:music_app/src/data/models/song.dart';

part 'playlist_song.freezed.dart';
part 'playlist_song.g.dart';

@freezed
class PlaylistSong with _$PlaylistSong {
  const factory PlaylistSong({required String playlistId, required Song song}) =
      _PlaylistSong;

  factory PlaylistSong.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSongFromJson(json);
}
