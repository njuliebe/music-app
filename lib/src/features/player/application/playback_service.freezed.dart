// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PlayerState {
  bool get isPlaying => throw _privateConstructorUsedError;
  PlaylistSong? get currentSong => throw _privateConstructorUsedError;
  Duration get position => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;
  bool get isLoadingLyrics => throw _privateConstructorUsedError;
  List<LyricLine> get lyrics => throw _privateConstructorUsedError;
  int get currentLyricIndex => throw _privateConstructorUsedError;
  int get playlistSize => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PlayerStateCopyWith<PlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerStateCopyWith<$Res> {
  factory $PlayerStateCopyWith(
          PlayerState value, $Res Function(PlayerState) then) =
      _$PlayerStateCopyWithImpl<$Res, PlayerState>;
  @useResult
  $Res call(
      {bool isPlaying,
      PlaylistSong? currentSong,
      Duration position,
      Duration duration,
      bool isLoadingLyrics,
      List<LyricLine> lyrics,
      int currentLyricIndex,
      int playlistSize});

  $PlaylistSongCopyWith<$Res>? get currentSong;
}

/// @nodoc
class _$PlayerStateCopyWithImpl<$Res, $Val extends PlayerState>
    implements $PlayerStateCopyWith<$Res> {
  _$PlayerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlaying = null,
    Object? currentSong = freezed,
    Object? position = null,
    Object? duration = null,
    Object? isLoadingLyrics = null,
    Object? lyrics = null,
    Object? currentLyricIndex = null,
    Object? playlistSize = null,
  }) {
    return _then(_value.copyWith(
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      currentSong: freezed == currentSong
          ? _value.currentSong
          : currentSong // ignore: cast_nullable_to_non_nullable
              as PlaylistSong?,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      isLoadingLyrics: null == isLoadingLyrics
          ? _value.isLoadingLyrics
          : isLoadingLyrics // ignore: cast_nullable_to_non_nullable
              as bool,
      lyrics: null == lyrics
          ? _value.lyrics
          : lyrics // ignore: cast_nullable_to_non_nullable
              as List<LyricLine>,
      currentLyricIndex: null == currentLyricIndex
          ? _value.currentLyricIndex
          : currentLyricIndex // ignore: cast_nullable_to_non_nullable
              as int,
      playlistSize: null == playlistSize
          ? _value.playlistSize
          : playlistSize // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PlaylistSongCopyWith<$Res>? get currentSong {
    if (_value.currentSong == null) {
      return null;
    }

    return $PlaylistSongCopyWith<$Res>(_value.currentSong!, (value) {
      return _then(_value.copyWith(currentSong: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlayerStateImplCopyWith<$Res>
    implements $PlayerStateCopyWith<$Res> {
  factory _$$PlayerStateImplCopyWith(
          _$PlayerStateImpl value, $Res Function(_$PlayerStateImpl) then) =
      __$$PlayerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isPlaying,
      PlaylistSong? currentSong,
      Duration position,
      Duration duration,
      bool isLoadingLyrics,
      List<LyricLine> lyrics,
      int currentLyricIndex,
      int playlistSize});

  @override
  $PlaylistSongCopyWith<$Res>? get currentSong;
}

/// @nodoc
class __$$PlayerStateImplCopyWithImpl<$Res>
    extends _$PlayerStateCopyWithImpl<$Res, _$PlayerStateImpl>
    implements _$$PlayerStateImplCopyWith<$Res> {
  __$$PlayerStateImplCopyWithImpl(
      _$PlayerStateImpl _value, $Res Function(_$PlayerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlaying = null,
    Object? currentSong = freezed,
    Object? position = null,
    Object? duration = null,
    Object? isLoadingLyrics = null,
    Object? lyrics = null,
    Object? currentLyricIndex = null,
    Object? playlistSize = null,
  }) {
    return _then(_$PlayerStateImpl(
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      currentSong: freezed == currentSong
          ? _value.currentSong
          : currentSong // ignore: cast_nullable_to_non_nullable
              as PlaylistSong?,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      isLoadingLyrics: null == isLoadingLyrics
          ? _value.isLoadingLyrics
          : isLoadingLyrics // ignore: cast_nullable_to_non_nullable
              as bool,
      lyrics: null == lyrics
          ? _value._lyrics
          : lyrics // ignore: cast_nullable_to_non_nullable
              as List<LyricLine>,
      currentLyricIndex: null == currentLyricIndex
          ? _value.currentLyricIndex
          : currentLyricIndex // ignore: cast_nullable_to_non_nullable
              as int,
      playlistSize: null == playlistSize
          ? _value.playlistSize
          : playlistSize // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PlayerStateImpl implements _PlayerState {
  const _$PlayerStateImpl(
      {this.isPlaying = false,
      this.currentSong,
      this.position = Duration.zero,
      this.duration = Duration.zero,
      this.isLoadingLyrics = false,
      final List<LyricLine> lyrics = const [],
      this.currentLyricIndex = -1,
      this.playlistSize = 0})
      : _lyrics = lyrics;

  @override
  @JsonKey()
  final bool isPlaying;
  @override
  final PlaylistSong? currentSong;
  @override
  @JsonKey()
  final Duration position;
  @override
  @JsonKey()
  final Duration duration;
  @override
  @JsonKey()
  final bool isLoadingLyrics;
  final List<LyricLine> _lyrics;
  @override
  @JsonKey()
  List<LyricLine> get lyrics {
    if (_lyrics is EqualUnmodifiableListView) return _lyrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lyrics);
  }

  @override
  @JsonKey()
  final int currentLyricIndex;
  @override
  @JsonKey()
  final int playlistSize;

  @override
  String toString() {
    return 'PlayerState(isPlaying: $isPlaying, currentSong: $currentSong, position: $position, duration: $duration, isLoadingLyrics: $isLoadingLyrics, lyrics: $lyrics, currentLyricIndex: $currentLyricIndex, playlistSize: $playlistSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerStateImpl &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.currentSong, currentSong) ||
                other.currentSong == currentSong) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.isLoadingLyrics, isLoadingLyrics) ||
                other.isLoadingLyrics == isLoadingLyrics) &&
            const DeepCollectionEquality().equals(other._lyrics, _lyrics) &&
            (identical(other.currentLyricIndex, currentLyricIndex) ||
                other.currentLyricIndex == currentLyricIndex) &&
            (identical(other.playlistSize, playlistSize) ||
                other.playlistSize == playlistSize));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isPlaying,
      currentSong,
      position,
      duration,
      isLoadingLyrics,
      const DeepCollectionEquality().hash(_lyrics),
      currentLyricIndex,
      playlistSize);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerStateImplCopyWith<_$PlayerStateImpl> get copyWith =>
      __$$PlayerStateImplCopyWithImpl<_$PlayerStateImpl>(this, _$identity);
}

abstract class _PlayerState implements PlayerState {
  const factory _PlayerState(
      {final bool isPlaying,
      final PlaylistSong? currentSong,
      final Duration position,
      final Duration duration,
      final bool isLoadingLyrics,
      final List<LyricLine> lyrics,
      final int currentLyricIndex,
      final int playlistSize}) = _$PlayerStateImpl;

  @override
  bool get isPlaying;
  @override
  PlaylistSong? get currentSong;
  @override
  Duration get position;
  @override
  Duration get duration;
  @override
  bool get isLoadingLyrics;
  @override
  List<LyricLine> get lyrics;
  @override
  int get currentLyricIndex;
  @override
  int get playlistSize;
  @override
  @JsonKey(ignore: true)
  _$$PlayerStateImplCopyWith<_$PlayerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
