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
  String get playlistId => throw _privateConstructorUsedError;
  Song get song => throw _privateConstructorUsedError;

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
  $Res call({String playlistId, Song song});

  $SongCopyWith<$Res> get song;
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
    Object? playlistId = null,
    Object? song = null,
  }) {
    return _then(_value.copyWith(
      playlistId: null == playlistId
          ? _value.playlistId
          : playlistId // ignore: cast_nullable_to_non_nullable
              as String,
      song: null == song
          ? _value.song
          : song // ignore: cast_nullable_to_non_nullable
              as Song,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SongCopyWith<$Res> get song {
    return $SongCopyWith<$Res>(_value.song, (value) {
      return _then(_value.copyWith(song: value) as $Val);
    });
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
  $Res call({String playlistId, Song song});

  @override
  $SongCopyWith<$Res> get song;
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
    Object? playlistId = null,
    Object? song = null,
  }) {
    return _then(_$PlaylistSongImpl(
      playlistId: null == playlistId
          ? _value.playlistId
          : playlistId // ignore: cast_nullable_to_non_nullable
              as String,
      song: null == song
          ? _value.song
          : song // ignore: cast_nullable_to_non_nullable
              as Song,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaylistSongImpl implements _PlaylistSong {
  const _$PlaylistSongImpl({required this.playlistId, required this.song});

  factory _$PlaylistSongImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistSongImplFromJson(json);

  @override
  final String playlistId;
  @override
  final Song song;

  @override
  String toString() {
    return 'PlaylistSong(playlistId: $playlistId, song: $song)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistSongImpl &&
            (identical(other.playlistId, playlistId) ||
                other.playlistId == playlistId) &&
            (identical(other.song, song) || other.song == song));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, playlistId, song);

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
      {required final String playlistId,
      required final Song song}) = _$PlaylistSongImpl;

  factory _PlaylistSong.fromJson(Map<String, dynamic> json) =
      _$PlaylistSongImpl.fromJson;

  @override
  String get playlistId;
  @override
  Song get song;
  @override
  @JsonKey(ignore: true)
  _$$PlaylistSongImplCopyWith<_$PlaylistSongImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
