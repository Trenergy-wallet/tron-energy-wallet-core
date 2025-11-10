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
mixin _$AppUtxoDtoV2 {

 String get txid; int get vout; String get value; int get confirmations; int? get height;
/// Create a copy of AppUtxoDtoV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUtxoDtoV2CopyWith<AppUtxoDtoV2> get copyWith => _$AppUtxoDtoV2CopyWithImpl<AppUtxoDtoV2>(this as AppUtxoDtoV2, _$identity);

  /// Serializes this AppUtxoDtoV2 to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUtxoDtoV2&&(identical(other.txid, txid) || other.txid == txid)&&(identical(other.vout, vout) || other.vout == vout)&&(identical(other.value, value) || other.value == value)&&(identical(other.confirmations, confirmations) || other.confirmations == confirmations)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txid,vout,value,confirmations,height);

@override
String toString() {
  return 'AppUtxoDtoV2(txid: $txid, vout: $vout, value: $value, confirmations: $confirmations, height: $height)';
}


}

/// @nodoc
abstract mixin class $AppUtxoDtoV2CopyWith<$Res>  {
  factory $AppUtxoDtoV2CopyWith(AppUtxoDtoV2 value, $Res Function(AppUtxoDtoV2) _then) = _$AppUtxoDtoV2CopyWithImpl;
@useResult
$Res call({
 String txid, int vout, String value, int confirmations, int? height
});




}
/// @nodoc
class _$AppUtxoDtoV2CopyWithImpl<$Res>
    implements $AppUtxoDtoV2CopyWith<$Res> {
  _$AppUtxoDtoV2CopyWithImpl(this._self, this._then);

  final AppUtxoDtoV2 _self;
  final $Res Function(AppUtxoDtoV2) _then;

/// Create a copy of AppUtxoDtoV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? txid = null,Object? vout = null,Object? value = null,Object? confirmations = null,Object? height = freezed,}) {
  return _then(_self.copyWith(
txid: null == txid ? _self.txid : txid // ignore: cast_nullable_to_non_nullable
as String,vout: null == vout ? _self.vout : vout // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,confirmations: null == confirmations ? _self.confirmations : confirmations // ignore: cast_nullable_to_non_nullable
as int,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUtxoDtoV2].
extension AppUtxoDtoV2Patterns on AppUtxoDtoV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUtxoDtoV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUtxoDtoV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUtxoDtoV2 value)  $default,){
final _that = this;
switch (_that) {
case _AppUtxoDtoV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUtxoDtoV2 value)?  $default,){
final _that = this;
switch (_that) {
case _AppUtxoDtoV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String txid,  int vout,  String value,  int confirmations,  int? height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUtxoDtoV2() when $default != null:
return $default(_that.txid,_that.vout,_that.value,_that.confirmations,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String txid,  int vout,  String value,  int confirmations,  int? height)  $default,) {final _that = this;
switch (_that) {
case _AppUtxoDtoV2():
return $default(_that.txid,_that.vout,_that.value,_that.confirmations,_that.height);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String txid,  int vout,  String value,  int confirmations,  int? height)?  $default,) {final _that = this;
switch (_that) {
case _AppUtxoDtoV2() when $default != null:
return $default(_that.txid,_that.vout,_that.value,_that.confirmations,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUtxoDtoV2 extends AppUtxoDtoV2 {
  const _AppUtxoDtoV2({required this.txid, required this.vout, required this.value, required this.confirmations, this.height}): super._();
  factory _AppUtxoDtoV2.fromJson(Map<String, dynamic> json) => _$AppUtxoDtoV2FromJson(json);

@override final  String txid;
@override final  int vout;
@override final  String value;
@override final  int confirmations;
@override final  int? height;

/// Create a copy of AppUtxoDtoV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUtxoDtoV2CopyWith<_AppUtxoDtoV2> get copyWith => __$AppUtxoDtoV2CopyWithImpl<_AppUtxoDtoV2>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUtxoDtoV2ToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUtxoDtoV2&&(identical(other.txid, txid) || other.txid == txid)&&(identical(other.vout, vout) || other.vout == vout)&&(identical(other.value, value) || other.value == value)&&(identical(other.confirmations, confirmations) || other.confirmations == confirmations)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txid,vout,value,confirmations,height);

@override
String toString() {
  return 'AppUtxoDtoV2(txid: $txid, vout: $vout, value: $value, confirmations: $confirmations, height: $height)';
}


}

/// @nodoc
abstract mixin class _$AppUtxoDtoV2CopyWith<$Res> implements $AppUtxoDtoV2CopyWith<$Res> {
  factory _$AppUtxoDtoV2CopyWith(_AppUtxoDtoV2 value, $Res Function(_AppUtxoDtoV2) _then) = __$AppUtxoDtoV2CopyWithImpl;
@override @useResult
$Res call({
 String txid, int vout, String value, int confirmations, int? height
});




}
/// @nodoc
class __$AppUtxoDtoV2CopyWithImpl<$Res>
    implements _$AppUtxoDtoV2CopyWith<$Res> {
  __$AppUtxoDtoV2CopyWithImpl(this._self, this._then);

  final _AppUtxoDtoV2 _self;
  final $Res Function(_AppUtxoDtoV2) _then;

/// Create a copy of AppUtxoDtoV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txid = null,Object? vout = null,Object? value = null,Object? confirmations = null,Object? height = freezed,}) {
  return _then(_AppUtxoDtoV2(
txid: null == txid ? _self.txid : txid // ignore: cast_nullable_to_non_nullable
as String,vout: null == vout ? _self.vout : vout // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,confirmations: null == confirmations ? _self.confirmations : confirmations // ignore: cast_nullable_to_non_nullable
as int,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$AppUtxoDtoV1 {

 String get txid; int get vout; int get satoshis; int get confirmations; int? get height;
/// Create a copy of AppUtxoDtoV1
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUtxoDtoV1CopyWith<AppUtxoDtoV1> get copyWith => _$AppUtxoDtoV1CopyWithImpl<AppUtxoDtoV1>(this as AppUtxoDtoV1, _$identity);

  /// Serializes this AppUtxoDtoV1 to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUtxoDtoV1&&(identical(other.txid, txid) || other.txid == txid)&&(identical(other.vout, vout) || other.vout == vout)&&(identical(other.satoshis, satoshis) || other.satoshis == satoshis)&&(identical(other.confirmations, confirmations) || other.confirmations == confirmations)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txid,vout,satoshis,confirmations,height);

@override
String toString() {
  return 'AppUtxoDtoV1(txid: $txid, vout: $vout, satoshis: $satoshis, confirmations: $confirmations, height: $height)';
}


}

/// @nodoc
abstract mixin class $AppUtxoDtoV1CopyWith<$Res>  {
  factory $AppUtxoDtoV1CopyWith(AppUtxoDtoV1 value, $Res Function(AppUtxoDtoV1) _then) = _$AppUtxoDtoV1CopyWithImpl;
@useResult
$Res call({
 String txid, int vout, int satoshis, int confirmations, int? height
});




}
/// @nodoc
class _$AppUtxoDtoV1CopyWithImpl<$Res>
    implements $AppUtxoDtoV1CopyWith<$Res> {
  _$AppUtxoDtoV1CopyWithImpl(this._self, this._then);

  final AppUtxoDtoV1 _self;
  final $Res Function(AppUtxoDtoV1) _then;

/// Create a copy of AppUtxoDtoV1
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? txid = null,Object? vout = null,Object? satoshis = null,Object? confirmations = null,Object? height = freezed,}) {
  return _then(_self.copyWith(
txid: null == txid ? _self.txid : txid // ignore: cast_nullable_to_non_nullable
as String,vout: null == vout ? _self.vout : vout // ignore: cast_nullable_to_non_nullable
as int,satoshis: null == satoshis ? _self.satoshis : satoshis // ignore: cast_nullable_to_non_nullable
as int,confirmations: null == confirmations ? _self.confirmations : confirmations // ignore: cast_nullable_to_non_nullable
as int,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUtxoDtoV1].
extension AppUtxoDtoV1Patterns on AppUtxoDtoV1 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUtxoDtoV1 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUtxoDtoV1() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUtxoDtoV1 value)  $default,){
final _that = this;
switch (_that) {
case _AppUtxoDtoV1():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUtxoDtoV1 value)?  $default,){
final _that = this;
switch (_that) {
case _AppUtxoDtoV1() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String txid,  int vout,  int satoshis,  int confirmations,  int? height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUtxoDtoV1() when $default != null:
return $default(_that.txid,_that.vout,_that.satoshis,_that.confirmations,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String txid,  int vout,  int satoshis,  int confirmations,  int? height)  $default,) {final _that = this;
switch (_that) {
case _AppUtxoDtoV1():
return $default(_that.txid,_that.vout,_that.satoshis,_that.confirmations,_that.height);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String txid,  int vout,  int satoshis,  int confirmations,  int? height)?  $default,) {final _that = this;
switch (_that) {
case _AppUtxoDtoV1() when $default != null:
return $default(_that.txid,_that.vout,_that.satoshis,_that.confirmations,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUtxoDtoV1 extends AppUtxoDtoV1 {
  const _AppUtxoDtoV1({required this.txid, required this.vout, required this.satoshis, required this.confirmations, this.height}): super._();
  factory _AppUtxoDtoV1.fromJson(Map<String, dynamic> json) => _$AppUtxoDtoV1FromJson(json);

@override final  String txid;
@override final  int vout;
@override final  int satoshis;
@override final  int confirmations;
@override final  int? height;

/// Create a copy of AppUtxoDtoV1
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUtxoDtoV1CopyWith<_AppUtxoDtoV1> get copyWith => __$AppUtxoDtoV1CopyWithImpl<_AppUtxoDtoV1>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUtxoDtoV1ToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUtxoDtoV1&&(identical(other.txid, txid) || other.txid == txid)&&(identical(other.vout, vout) || other.vout == vout)&&(identical(other.satoshis, satoshis) || other.satoshis == satoshis)&&(identical(other.confirmations, confirmations) || other.confirmations == confirmations)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txid,vout,satoshis,confirmations,height);

@override
String toString() {
  return 'AppUtxoDtoV1(txid: $txid, vout: $vout, satoshis: $satoshis, confirmations: $confirmations, height: $height)';
}


}

/// @nodoc
abstract mixin class _$AppUtxoDtoV1CopyWith<$Res> implements $AppUtxoDtoV1CopyWith<$Res> {
  factory _$AppUtxoDtoV1CopyWith(_AppUtxoDtoV1 value, $Res Function(_AppUtxoDtoV1) _then) = __$AppUtxoDtoV1CopyWithImpl;
@override @useResult
$Res call({
 String txid, int vout, int satoshis, int confirmations, int? height
});




}
/// @nodoc
class __$AppUtxoDtoV1CopyWithImpl<$Res>
    implements _$AppUtxoDtoV1CopyWith<$Res> {
  __$AppUtxoDtoV1CopyWithImpl(this._self, this._then);

  final _AppUtxoDtoV1 _self;
  final $Res Function(_AppUtxoDtoV1) _then;

/// Create a copy of AppUtxoDtoV1
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txid = null,Object? vout = null,Object? satoshis = null,Object? confirmations = null,Object? height = freezed,}) {
  return _then(_AppUtxoDtoV1(
txid: null == txid ? _self.txid : txid // ignore: cast_nullable_to_non_nullable
as String,vout: null == vout ? _self.vout : vout // ignore: cast_nullable_to_non_nullable
as int,satoshis: null == satoshis ? _self.satoshis : satoshis // ignore: cast_nullable_to_non_nullable
as int,confirmations: null == confirmations ? _self.confirmations : confirmations // ignore: cast_nullable_to_non_nullable
as int,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
