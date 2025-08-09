// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaylistSongImpl _$$PlaylistSongImplFromJson(Map<String, dynamic> json) =>
    _$PlaylistSongImpl(
      playlistId: json['playlistId'] as String,
      song: Song.fromJson(json['song'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PlaylistSongImplToJson(_$PlaylistSongImpl instance) =>
    <String, dynamic>{
      'playlistId': instance.playlistId,
      'song': instance.song,
    };
