// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lyric.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Lyric _$LyricFromJson(Map<String, dynamic> json) {
  return _Lyric.fromJson(json);
}

/// @nodoc
mixin _$Lyric {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get artistName => throw _privateConstructorUsedError;
  String get albumName => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  bool get instrumental => throw _privateConstructorUsedError;
  String? get plainLyrics => throw _privateConstructorUsedError;
  String? get syncedLyrics => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LyricCopyWith<Lyric> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LyricCopyWith<$Res> {
  factory $LyricCopyWith(Lyric value, $Res Function(Lyric) then) =
      _$LyricCopyWithImpl<$Res, Lyric>;
  @useResult
  $Res call(
      {int id,
      String name,
      String artistName,
      String albumName,
      int duration,
      bool instrumental,
      String? plainLyrics,
      String? syncedLyrics});
}

/// @nodoc
class _$LyricCopyWithImpl<$Res, $Val extends Lyric>
    implements $LyricCopyWith<$Res> {
  _$LyricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? artistName = null,
    Object? albumName = null,
    Object? duration = null,
    Object? instrumental = null,
    Object? plainLyrics = freezed,
    Object? syncedLyrics = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      albumName: null == albumName
          ? _value.albumName
          : albumName // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      instrumental: null == instrumental
          ? _value.instrumental
          : instrumental // ignore: cast_nullable_to_non_nullable
              as bool,
      plainLyrics: freezed == plainLyrics
          ? _value.plainLyrics
          : plainLyrics // ignore: cast_nullable_to_non_nullable
              as String?,
      syncedLyrics: freezed == syncedLyrics
          ? _value.syncedLyrics
          : syncedLyrics // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LyricImplCopyWith<$Res> implements $LyricCopyWith<$Res> {
  factory _$$LyricImplCopyWith(
          _$LyricImpl value, $Res Function(_$LyricImpl) then) =
      __$$LyricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String artistName,
      String albumName,
      int duration,
      bool instrumental,
      String? plainLyrics,
      String? syncedLyrics});
}

/// @nodoc
class __$$LyricImplCopyWithImpl<$Res>
    extends _$LyricCopyWithImpl<$Res, _$LyricImpl>
    implements _$$LyricImplCopyWith<$Res> {
  __$$LyricImplCopyWithImpl(
      _$LyricImpl _value, $Res Function(_$LyricImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? artistName = null,
    Object? albumName = null,
    Object? duration = null,
    Object? instrumental = null,
    Object? plainLyrics = freezed,
    Object? syncedLyrics = freezed,
  }) {
    return _then(_$LyricImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      albumName: null == albumName
          ? _value.albumName
          : albumName // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      instrumental: null == instrumental
          ? _value.instrumental
          : instrumental // ignore: cast_nullable_to_non_nullable
              as bool,
      plainLyrics: freezed == plainLyrics
          ? _value.plainLyrics
          : plainLyrics // ignore: cast_nullable_to_non_nullable
              as String?,
      syncedLyrics: freezed == syncedLyrics
          ? _value.syncedLyrics
          : syncedLyrics // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LyricImpl implements _Lyric {
  _$LyricImpl(
      {required this.id,
      required this.name,
      required this.artistName,
      required this.albumName,
      required this.duration,
      required this.instrumental,
      this.plainLyrics,
      this.syncedLyrics});

  factory _$LyricImpl.fromJson(Map<String, dynamic> json) =>
      _$$LyricImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String artistName;
  @override
  final String albumName;
  @override
  final int duration;
  @override
  final bool instrumental;
  @override
  final String? plainLyrics;
  @override
  final String? syncedLyrics;

  @override
  String toString() {
    return 'Lyric(id: $id, name: $name, artistName: $artistName, albumName: $albumName, duration: $duration, instrumental: $instrumental, plainLyrics: $plainLyrics, syncedLyrics: $syncedLyrics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LyricImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.albumName, albumName) ||
                other.albumName == albumName) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.instrumental, instrumental) ||
                other.instrumental == instrumental) &&
            (identical(other.plainLyrics, plainLyrics) ||
                other.plainLyrics == plainLyrics) &&
            (identical(other.syncedLyrics, syncedLyrics) ||
                other.syncedLyrics == syncedLyrics));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, artistName, albumName,
      duration, instrumental, plainLyrics, syncedLyrics);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LyricImplCopyWith<_$LyricImpl> get copyWith =>
      __$$LyricImplCopyWithImpl<_$LyricImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LyricImplToJson(
      this,
    );
  }
}

abstract class _Lyric implements Lyric {
  factory _Lyric(
      {required final int id,
      required final String name,
      required final String artistName,
      required final String albumName,
      required final int duration,
      required final bool instrumental,
      final String? plainLyrics,
      final String? syncedLyrics}) = _$LyricImpl;

  factory _Lyric.fromJson(Map<String, dynamic> json) = _$LyricImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get artistName;
  @override
  String get albumName;
  @override
  int get duration;
  @override
  bool get instrumental;
  @override
  String? get plainLyrics;
  @override
  String? get syncedLyrics;
  @override
  @JsonKey(ignore: true)
  _$$LyricImplCopyWith<_$LyricImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
