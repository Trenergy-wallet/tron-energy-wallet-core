// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../account_utxo.cg.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUtxo {

 String get txid; int get vout; BigInt get value; int get height; int get confirmations;
/// Create a copy of AppUtxo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUtxoCopyWith<AppUtxo> get copyWith => _$AppUtxoCopyWithImpl<AppUtxo>(this as AppUtxo, _$identity);

  /// Serializes this AppUtxo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUtxo&&(identical(other.txid, txid) || other.txid == txid)&&(identical(other.vout, vout) || other.vout == vout)&&(identical(other.value, value) || other.value == value)&&(identical(other.height, height) || other.height == height)&&(identical(other.confirmations, confirmations) || other.confirmations == confirmations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txid,vout,value,height,confirmations);

@override
String toString() {
  return 'AppUtxo(txid: $txid, vout: $vout, value: $value, height: $height, confirmations: $confirmations)';
}


}

/// @nodoc
abstract mixin class $AppUtxoCopyWith<$Res>  {
  factory $AppUtxoCopyWith(AppUtxo value, $Res Function(AppUtxo) _then) = _$AppUtxoCopyWithImpl;
@useResult
$Res call({
 String txid, int vout, BigInt value, int height, int confirmations
});




}
/// @nodoc
class _$AppUtxoCopyWithImpl<$Res>
    implements $AppUtxoCopyWith<$Res> {
  _$AppUtxoCopyWithImpl(this._self, this._then);

  final AppUtxo _self;
  final $Res Function(AppUtxo) _then;

/// Create a copy of AppUtxo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? txid = null,Object? vout = null,Object? value = null,Object? height = null,Object? confirmations = null,}) {
  return _then(_self.copyWith(
txid: null == txid ? _self.txid : txid // ignore: cast_nullable_to_non_nullable
as String,vout: null == vout ? _self.vout : vout // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as BigInt,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,confirmations: null == confirmations ? _self.confirmations : confirmations // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUtxo].
extension AppUtxoPatterns on AppUtxo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUtxo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUtxo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUtxo value)  $default,){
final _that = this;
switch (_that) {
case _AppUtxo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUtxo value)?  $default,){
final _that = this;
switch (_that) {
case _AppUtxo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String txid,  int vout,  BigInt value,  int height,  int confirmations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUtxo() when $default != null:
return $default(_that.txid,_that.vout,_that.value,_that.height,_that.confirmations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String txid,  int vout,  BigInt value,  int height,  int confirmations)  $default,) {final _that = this;
switch (_that) {
case _AppUtxo():
return $default(_that.txid,_that.vout,_that.value,_that.height,_that.confirmations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String txid,  int vout,  BigInt value,  int height,  int confirmations)?  $default,) {final _that = this;
switch (_that) {
case _AppUtxo() when $default != null:
return $default(_that.txid,_that.vout,_that.value,_that.height,_that.confirmations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUtxo extends AppUtxo {
  const _AppUtxo({required this.txid, required this.vout, required this.value, required this.height, required this.confirmations}): super._();
  factory _AppUtxo.fromJson(Map<String, dynamic> json) => _$AppUtxoFromJson(json);

@override final  String txid;
@override final  int vout;
@override final  BigInt value;
@override final  int height;
@override final  int confirmations;

/// Create a copy of AppUtxo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUtxoCopyWith<_AppUtxo> get copyWith => __$AppUtxoCopyWithImpl<_AppUtxo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUtxoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUtxo&&(identical(other.txid, txid) || other.txid == txid)&&(identical(other.vout, vout) || other.vout == vout)&&(identical(other.value, value) || other.value == value)&&(identical(other.height, height) || other.height == height)&&(identical(other.confirmations, confirmations) || other.confirmations == confirmations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txid,vout,value,height,confirmations);

@override
String toString() {
  return 'AppUtxo(txid: $txid, vout: $vout, value: $value, height: $height, confirmations: $confirmations)';
}


}

/// @nodoc
abstract mixin class _$AppUtxoCopyWith<$Res> implements $AppUtxoCopyWith<$Res> {
  factory _$AppUtxoCopyWith(_AppUtxo value, $Res Function(_AppUtxo) _then) = __$AppUtxoCopyWithImpl;
@override @useResult
$Res call({
 String txid, int vout, BigInt value, int height, int confirmations
});




}
/// @nodoc
class __$AppUtxoCopyWithImpl<$Res>
    implements _$AppUtxoCopyWith<$Res> {
  __$AppUtxoCopyWithImpl(this._self, this._then);

  final _AppUtxo _self;
  final $Res Function(_AppUtxo) _then;

/// Create a copy of AppUtxo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txid = null,Object? vout = null,Object? value = null,Object? height = null,Object? confirmations = null,}) {
  return _then(_AppUtxo(
txid: null == txid ? _self.txid : txid // ignore: cast_nullable_to_non_nullable
as String,vout: null == vout ? _self.vout : vout // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as BigInt,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,confirmations: null == confirmations ? _self.confirmations : confirmations // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
