// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaylistSongImpl _$$PlaylistSongImplFromJson(Map<String, dynamic> json) =>
    _$PlaylistSongImpl(
      pkId: (json['pk_id'] as num?)?.toInt(),
      playlistId: json['playlist_id'] as String,
      songTitle: json['song_title'] as String,
      artist: json['artist'] as String,
      playUrl: json['play_url'] as String?,
    );

Map<String, dynamic> _$$PlaylistSongImplToJson(_$PlaylistSongImpl instance) =>
    <String, dynamic>{
      'pk_id': instance.pkId,
      'playlist_id': instance.playlistId,
      'song_title': instance.songTitle,
      'artist': instance.artist,
      'play_url': instance.playUrl,
    };
