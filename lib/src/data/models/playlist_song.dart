import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist_song.freezed.dart';
part 'playlist_song.g.dart';

@freezed
class PlaylistSong with _$PlaylistSong {
  const factory PlaylistSong({
    @JsonKey(name: 'pk_id') int? pkId,
    @JsonKey(name: 'playlist_id') required String playlistId,
    @JsonKey(name: 'song_title') required String songTitle,
    required String artist,
    @JsonKey(name: 'play_url') String? playUrl,
  }) = _PlaylistSong;

  factory PlaylistSong.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSongFromJson(json);
}
