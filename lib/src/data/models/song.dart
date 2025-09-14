import 'package:freezed_annotation/freezed_annotation.dart';

part 'song.freezed.dart';
part 'song.g.dart';

@freezed
class Song with _$Song {
  const factory Song({
    required String id,
    @JsonKey(name: 'name') required String title,
    @JsonKey(fromJson: _artistFromJson) required String artist,
    @JsonKey(name: 'url_id') required String href,
    @JsonKey(name: 'play_url') String? playUrl,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
}

String _artistFromJson(dynamic artist) {
  if (artist is List) {
    return artist.join(', ');
  } else if (artist is String) {
    return artist;
  }
  return '';
}
