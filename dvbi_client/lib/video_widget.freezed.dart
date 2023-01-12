// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_widget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$MyVideoData {
  ServiceElem get service => throw _privateConstructorUsedError;
  Result<VideoPlayerController?, String> get video =>
      throw _privateConstructorUsedError;
  int get id => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MyVideoDataCopyWith<MyVideoData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyVideoDataCopyWith<$Res> {
  factory $MyVideoDataCopyWith(
          MyVideoData value, $Res Function(MyVideoData) then) =
      _$MyVideoDataCopyWithImpl<$Res, MyVideoData>;
  @useResult
  $Res call(
      {ServiceElem service,
      Result<VideoPlayerController?, String> video,
      int id});
}

/// @nodoc
class _$MyVideoDataCopyWithImpl<$Res, $Val extends MyVideoData>
    implements $MyVideoDataCopyWith<$Res> {
  _$MyVideoDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? service = null,
    Object? video = null,
    Object? id = null,
  }) {
    return _then(_value.copyWith(
      service: null == service
          ? _value.service
          : service // ignore: cast_nullable_to_non_nullable
              as ServiceElem,
      video: null == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as Result<VideoPlayerController?, String>,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MyVideoDataCopyWith<$Res>
    implements $MyVideoDataCopyWith<$Res> {
  factory _$$_MyVideoDataCopyWith(
          _$_MyVideoData value, $Res Function(_$_MyVideoData) then) =
      __$$_MyVideoDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ServiceElem service,
      Result<VideoPlayerController?, String> video,
      int id});
}

/// @nodoc
class __$$_MyVideoDataCopyWithImpl<$Res>
    extends _$MyVideoDataCopyWithImpl<$Res, _$_MyVideoData>
    implements _$$_MyVideoDataCopyWith<$Res> {
  __$$_MyVideoDataCopyWithImpl(
      _$_MyVideoData _value, $Res Function(_$_MyVideoData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? service = null,
    Object? video = null,
    Object? id = null,
  }) {
    return _then(_$_MyVideoData(
      service: null == service
          ? _value.service
          : service // ignore: cast_nullable_to_non_nullable
              as ServiceElem,
      video: null == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as Result<VideoPlayerController?, String>,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_MyVideoData implements _MyVideoData {
  const _$_MyVideoData(
      {required this.service, required this.video, required this.id});

  @override
  final ServiceElem service;
  @override
  final Result<VideoPlayerController?, String> video;
  @override
  final int id;

  @override
  String toString() {
    return 'MyVideoData(service: $service, video: $video, id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MyVideoData &&
            (identical(other.service, service) || other.service == service) &&
            (identical(other.video, video) || other.video == video) &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, service, video, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MyVideoDataCopyWith<_$_MyVideoData> get copyWith =>
      __$$_MyVideoDataCopyWithImpl<_$_MyVideoData>(this, _$identity);
}

abstract class _MyVideoData implements MyVideoData {
  const factory _MyVideoData(
      {required final ServiceElem service,
      required final Result<VideoPlayerController?, String> video,
      required final int id}) = _$_MyVideoData;

  @override
  ServiceElem get service;
  @override
  Result<VideoPlayerController?, String> get video;
  @override
  int get id;
  @override
  @JsonKey(ignore: true)
  _$$_MyVideoDataCopyWith<_$_MyVideoData> get copyWith =>
      throw _privateConstructorUsedError;
}
