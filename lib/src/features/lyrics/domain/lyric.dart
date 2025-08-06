
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lyric.freezed.dart';
part 'lyric.g.dart';

@freezed
class Lyric with _$Lyric {
  factory Lyric({
    required int id,
    required String name,
    required String artistName,
    required String albumName,
    required int duration,
    required bool instrumental,
    String? plainLyrics,
    String? syncedLyrics,
  }) = _Lyric;

  factory Lyric.fromJson(Map<String, dynamic> json) => _$LyricFromJson(json);
}
