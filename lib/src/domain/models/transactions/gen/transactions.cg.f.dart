// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../transactions.cg.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionInfoData {

 String get txId; String get linkToBlockchain;
/// Create a copy of TransactionInfoData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionInfoDataCopyWith<TransactionInfoData> get copyWith => _$TransactionInfoDataCopyWithImpl<TransactionInfoData>(this as TransactionInfoData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionInfoData&&(identical(other.txId, txId) || other.txId == txId)&&(identical(other.linkToBlockchain, linkToBlockchain) || other.linkToBlockchain == linkToBlockchain));
}


@override
int get hashCode => Object.hash(runtimeType,txId,linkToBlockchain);

@override
String toString() {
  return 'TransactionInfoData(txId: $txId, linkToBlockchain: $linkToBlockchain)';
}


}

/// @nodoc
abstract mixin class $TransactionInfoDataCopyWith<$Res>  {
  factory $TransactionInfoDataCopyWith(TransactionInfoData value, $Res Function(TransactionInfoData) _then) = _$TransactionInfoDataCopyWithImpl;
@useResult
$Res call({
 String txId, String linkToBlockchain
});




}
/// @nodoc
class _$TransactionInfoDataCopyWithImpl<$Res>
    implements $TransactionInfoDataCopyWith<$Res> {
  _$TransactionInfoDataCopyWithImpl(this._self, this._then);

  final TransactionInfoData _self;
  final $Res Function(TransactionInfoData) _then;

/// Create a copy of TransactionInfoData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? txId = null,Object? linkToBlockchain = null,}) {
  return _then(_self.copyWith(
txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,linkToBlockchain: null == linkToBlockchain ? _self.linkToBlockchain : linkToBlockchain // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionInfoData].
extension TransactionInfoDataPatterns on TransactionInfoData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionInfoData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionInfoData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionInfoData value)  $default,){
final _that = this;
switch (_that) {
case _TransactionInfoData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionInfoData value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionInfoData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String txId,  String linkToBlockchain)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionInfoData() when $default != null:
return $default(_that.txId,_that.linkToBlockchain);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String txId,  String linkToBlockchain)  $default,) {final _that = this;
switch (_that) {
case _TransactionInfoData():
return $default(_that.txId,_that.linkToBlockchain);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String txId,  String linkToBlockchain)?  $default,) {final _that = this;
switch (_that) {
case _TransactionInfoData() when $default != null:
return $default(_that.txId,_that.linkToBlockchain);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionInfoData implements TransactionInfoData {
  const _TransactionInfoData({required this.txId, required this.linkToBlockchain});
  

@override final  String txId;
@override final  String linkToBlockchain;

/// Create a copy of TransactionInfoData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionInfoDataCopyWith<_TransactionInfoData> get copyWith => __$TransactionInfoDataCopyWithImpl<_TransactionInfoData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionInfoData&&(identical(other.txId, txId) || other.txId == txId)&&(identical(other.linkToBlockchain, linkToBlockchain) || other.linkToBlockchain == linkToBlockchain));
}


@override
int get hashCode => Object.hash(runtimeType,txId,linkToBlockchain);

@override
String toString() {
  return 'TransactionInfoData(txId: $txId, linkToBlockchain: $linkToBlockchain)';
}


}

/// @nodoc
abstract mixin class _$TransactionInfoDataCopyWith<$Res> implements $TransactionInfoDataCopyWith<$Res> {
  factory _$TransactionInfoDataCopyWith(_TransactionInfoData value, $Res Function(_TransactionInfoData) _then) = __$TransactionInfoDataCopyWithImpl;
@override @useResult
$Res call({
 String txId, String linkToBlockchain
});




}
/// @nodoc
class __$TransactionInfoDataCopyWithImpl<$Res>
    implements _$TransactionInfoDataCopyWith<$Res> {
  __$TransactionInfoDataCopyWithImpl(this._self, this._then);

  final _TransactionInfoData _self;
  final $Res Function(_TransactionInfoData) _then;

/// Create a copy of TransactionInfoData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txId = null,Object? linkToBlockchain = null,}) {
  return _then(_TransactionInfoData(
txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,linkToBlockchain: null == linkToBlockchain ? _self.linkToBlockchain : linkToBlockchain // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
