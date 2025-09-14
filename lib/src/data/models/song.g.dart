// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongImpl _$$SongImplFromJson(Map<String, dynamic> json) => _$SongImpl(
      id: json['id'] as String,
      title: json['name'] as String,
      artist: _artistFromJson(json['artist']),
      href: json['url_id'] as String,
      playUrl: json['play_url'] as String?,
    );

Map<String, dynamic> _$$SongImplToJson(_$SongImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.title,
      'artist': instance.artist,
      'url_id': instance.href,
      'play_url': instance.playUrl,
    };
