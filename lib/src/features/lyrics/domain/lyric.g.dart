// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyric.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LyricImpl _$$LyricImplFromJson(Map<String, dynamic> json) => _$LyricImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      artistName: json['artistName'] as String,
      albumName: json['albumName'] as String,
      duration: (json['duration'] as num).toInt(),
      instrumental: json['instrumental'] as bool,
      plainLyrics: json['plainLyrics'] as String?,
      syncedLyrics: json['syncedLyrics'] as String?,
    );

Map<String, dynamic> _$$LyricImplToJson(_$LyricImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'artistName': instance.artistName,
      'albumName': instance.albumName,
      'duration': instance.duration,
      'instrumental': instance.instrumental,
      'plainLyrics': instance.plainLyrics,
      'syncedLyrics': instance.syncedLyrics,
    };
