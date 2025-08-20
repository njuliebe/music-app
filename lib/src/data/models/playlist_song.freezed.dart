// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlist_song.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlaylistSong _$PlaylistSongFromJson(Map<String, dynamic> json) {
  return _PlaylistSong.fromJson(json);
}

/// @nodoc
mixin _$PlaylistSong {
  @JsonKey(name: 'pk_id')
  int? get pkId => throw _privateConstructorUsedError;
  @JsonKey(name: 'playlist_id')
  String get playlistId => throw _privateConstructorUsedError;
  @JsonKey(name: 'song_title')
  String get songTitle => throw _privateConstructorUsedError;
  String get artist => throw _privateConstructorUsedError;
  @JsonKey(name: 'play_url')
  String? get playUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlaylistSongCopyWith<PlaylistSong> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaylistSongCopyWith<$Res> {
  factory $PlaylistSongCopyWith(
          PlaylistSong value, $Res Function(PlaylistSong) then) =
      _$PlaylistSongCopyWithImpl<$Res, PlaylistSong>;
  @useResult
  $Res call(
      {@JsonKey(name: 'pk_id') int? pkId,
      @JsonKey(name: 'playlist_id') String playlistId,
      @JsonKey(name: 'song_title') String songTitle,
      String artist,
      @JsonKey(name: 'play_url') String? playUrl});
}

/// @nodoc
class _$PlaylistSongCopyWithImpl<$Res, $Val extends PlaylistSong>
    implements $PlaylistSongCopyWith<$Res> {
  _$PlaylistSongCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pkId = freezed,
    Object? playlistId = null,
    Object? songTitle = null,
    Object? artist = null,
    Object? playUrl = freezed,
  }) {
    return _then(_value.copyWith(
      pkId: freezed == pkId
          ? _value.pkId
          : pkId // ignore: cast_nullable_to_non_nullable
              as int?,
      playlistId: null == playlistId
          ? _value.playlistId
          : playlistId // ignore: cast_nullable_to_non_nullable
              as String,
      songTitle: null == songTitle
          ? _value.songTitle
          : songTitle // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      playUrl: freezed == playUrl
          ? _value.playUrl
          : playUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaylistSongImplCopyWith<$Res>
    implements $PlaylistSongCopyWith<$Res> {
  factory _$$PlaylistSongImplCopyWith(
          _$PlaylistSongImpl value, $Res Function(_$PlaylistSongImpl) then) =
      __$$PlaylistSongImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'pk_id') int? pkId,
      @JsonKey(name: 'playlist_id') String playlistId,
      @JsonKey(name: 'song_title') String songTitle,
      String artist,
      @JsonKey(name: 'play_url') String? playUrl});
}

/// @nodoc
class __$$PlaylistSongImplCopyWithImpl<$Res>
    extends _$PlaylistSongCopyWithImpl<$Res, _$PlaylistSongImpl>
    implements _$$PlaylistSongImplCopyWith<$Res> {
  __$$PlaylistSongImplCopyWithImpl(
      _$PlaylistSongImpl _value, $Res Function(_$PlaylistSongImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pkId = freezed,
    Object? playlistId = null,
    Object? songTitle = null,
    Object? artist = null,
    Object? playUrl = freezed,
  }) {
    return _then(_$PlaylistSongImpl(
      pkId: freezed == pkId
          ? _value.pkId
          : pkId // ignore: cast_nullable_to_non_nullable
              as int?,
      playlistId: null == playlistId
          ? _value.playlistId
          : playlistId // ignore: cast_nullable_to_non_nullable
              as String,
      songTitle: null == songTitle
          ? _value.songTitle
          : songTitle // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      playUrl: freezed == playUrl
          ? _value.playUrl
          : playUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaylistSongImpl implements _PlaylistSong {
  const _$PlaylistSongImpl(
      {@JsonKey(name: 'pk_id') this.pkId,
      @JsonKey(name: 'playlist_id') required this.playlistId,
      @JsonKey(name: 'song_title') required this.songTitle,
      required this.artist,
      @JsonKey(name: 'play_url') this.playUrl});

  factory _$PlaylistSongImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistSongImplFromJson(json);

  @override
  @JsonKey(name: 'pk_id')
  final int? pkId;
  @override
  @JsonKey(name: 'playlist_id')
  final String playlistId;
  @override
  @JsonKey(name: 'song_title')
  final String songTitle;
  @override
  final String artist;
  @override
  @JsonKey(name: 'play_url')
  final String? playUrl;

  @override
  String toString() {
    return 'PlaylistSong(pkId: $pkId, playlistId: $playlistId, songTitle: $songTitle, artist: $artist, playUrl: $playUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistSongImpl &&
            (identical(other.pkId, pkId) || other.pkId == pkId) &&
            (identical(other.playlistId, playlistId) ||
                other.playlistId == playlistId) &&
            (identical(other.songTitle, songTitle) ||
                other.songTitle == songTitle) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.playUrl, playUrl) || other.playUrl == playUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, pkId, playlistId, songTitle, artist, playUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaylistSongImplCopyWith<_$PlaylistSongImpl> get copyWith =>
      __$$PlaylistSongImplCopyWithImpl<_$PlaylistSongImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaylistSongImplToJson(
      this,
    );
  }
}

abstract class _PlaylistSong implements PlaylistSong {
  const factory _PlaylistSong(
      {@JsonKey(name: 'pk_id') final int? pkId,
      @JsonKey(name: 'playlist_id') required final String playlistId,
      @JsonKey(name: 'song_title') required final String songTitle,
      required final String artist,
      @JsonKey(name: 'play_url') final String? playUrl}) = _$PlaylistSongImpl;

  factory _PlaylistSong.fromJson(Map<String, dynamic> json) =
      _$PlaylistSongImpl.fromJson;

  @override
  @JsonKey(name: 'pk_id')
  int? get pkId;
  @override
  @JsonKey(name: 'playlist_id')
  String get playlistId;
  @override
  @JsonKey(name: 'song_title')
  String get songTitle;
  @override
  String get artist;
  @override
  @JsonKey(name: 'play_url')
  String? get playUrl;
  @override
  @JsonKey(ignore: true)
  _$$PlaylistSongImplCopyWith<_$PlaylistSongImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
