// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../send_raw_transaction_response.cg.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SendRawTransactionResponse {

 int get id; String? get result; Map<String, dynamic>? get error;
/// Create a copy of SendRawTransactionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendRawTransactionResponseCopyWith<SendRawTransactionResponse> get copyWith => _$SendRawTransactionResponseCopyWithImpl<SendRawTransactionResponse>(this as SendRawTransactionResponse, _$identity);

  /// Serializes this SendRawTransactionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendRawTransactionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.result, result) || other.result == result)&&const DeepCollectionEquality().equals(other.error, error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,result,const DeepCollectionEquality().hash(error));

@override
String toString() {
  return 'SendRawTransactionResponse(id: $id, result: $result, error: $error)';
}


}

/// @nodoc
abstract mixin class $SendRawTransactionResponseCopyWith<$Res>  {
  factory $SendRawTransactionResponseCopyWith(SendRawTransactionResponse value, $Res Function(SendRawTransactionResponse) _then) = _$SendRawTransactionResponseCopyWithImpl;
@useResult
$Res call({
 int id, String? result, Map<String, dynamic>? error
});




}
/// @nodoc
class _$SendRawTransactionResponseCopyWithImpl<$Res>
    implements $SendRawTransactionResponseCopyWith<$Res> {
  _$SendRawTransactionResponseCopyWithImpl(this._self, this._then);

  final SendRawTransactionResponse _self;
  final $Res Function(SendRawTransactionResponse) _then;

/// Create a copy of SendRawTransactionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? result = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SendRawTransactionResponse].
extension SendRawTransactionResponsePatterns on SendRawTransactionResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendRawTransactionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendRawTransactionResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendRawTransactionResponse value)  $default,){
final _that = this;
switch (_that) {
case _SendRawTransactionResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendRawTransactionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SendRawTransactionResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? result,  Map<String, dynamic>? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendRawTransactionResponse() when $default != null:
return $default(_that.id,_that.result,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? result,  Map<String, dynamic>? error)  $default,) {final _that = this;
switch (_that) {
case _SendRawTransactionResponse():
return $default(_that.id,_that.result,_that.error);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? result,  Map<String, dynamic>? error)?  $default,) {final _that = this;
switch (_that) {
case _SendRawTransactionResponse() when $default != null:
return $default(_that.id,_that.result,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SendRawTransactionResponse implements SendRawTransactionResponse {
  const _SendRawTransactionResponse({required this.id, this.result, final  Map<String, dynamic>? error}): _error = error;
  factory _SendRawTransactionResponse.fromJson(Map<String, dynamic> json) => _$SendRawTransactionResponseFromJson(json);

@override final  int id;
@override final  String? result;
 final  Map<String, dynamic>? _error;
@override Map<String, dynamic>? get error {
  final value = _error;
  if (value == null) return null;
  if (_error is EqualUnmodifiableMapView) return _error;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of SendRawTransactionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendRawTransactionResponseCopyWith<_SendRawTransactionResponse> get copyWith => __$SendRawTransactionResponseCopyWithImpl<_SendRawTransactionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendRawTransactionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendRawTransactionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.result, result) || other.result == result)&&const DeepCollectionEquality().equals(other._error, _error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,result,const DeepCollectionEquality().hash(_error));

@override
String toString() {
  return 'SendRawTransactionResponse(id: $id, result: $result, error: $error)';
}


}

/// @nodoc
abstract mixin class _$SendRawTransactionResponseCopyWith<$Res> implements $SendRawTransactionResponseCopyWith<$Res> {
  factory _$SendRawTransactionResponseCopyWith(_SendRawTransactionResponse value, $Res Function(_SendRawTransactionResponse) _then) = __$SendRawTransactionResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String? result, Map<String, dynamic>? error
});




}
/// @nodoc
class __$SendRawTransactionResponseCopyWithImpl<$Res>
    implements _$SendRawTransactionResponseCopyWith<$Res> {
  __$SendRawTransactionResponseCopyWithImpl(this._self, this._then);

  final _SendRawTransactionResponse _self;
  final $Res Function(_SendRawTransactionResponse) _then;

/// Create a copy of SendRawTransactionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? result = freezed,Object? error = freezed,}) {
  return _then(_SendRawTransactionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self._error : error // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
