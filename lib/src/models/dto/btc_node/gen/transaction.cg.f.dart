// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../transaction.cg.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionBtcNodeDto {

@JsonKey(name: 'txid') String get txId;// int? version,
 List<VinDto> get vin; List<VoutDto> get vout;@JsonKey(name: 'blockHeight') int get blockHeight; int get confirmations; bool get rbf; String get fees; int get size;@JsonKey(name: 'vsize') int get vSize;
/// Create a copy of TransactionBtcNodeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionBtcNodeDtoCopyWith<TransactionBtcNodeDto> get copyWith => _$TransactionBtcNodeDtoCopyWithImpl<TransactionBtcNodeDto>(this as TransactionBtcNodeDto, _$identity);

  /// Serializes this TransactionBtcNodeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionBtcNodeDto&&(identical(other.txId, txId) || other.txId == txId)&&const DeepCollectionEquality().equals(other.vin, vin)&&const DeepCollectionEquality().equals(other.vout, vout)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight)&&(identical(other.confirmations, confirmations) || other.confirmations == confirmations)&&(identical(other.rbf, rbf) || other.rbf == rbf)&&(identical(other.fees, fees) || other.fees == fees)&&(identical(other.size, size) || other.size == size)&&(identical(other.vSize, vSize) || other.vSize == vSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txId,const DeepCollectionEquality().hash(vin),const DeepCollectionEquality().hash(vout),blockHeight,confirmations,rbf,fees,size,vSize);

@override
String toString() {
  return 'TransactionBtcNodeDto(txId: $txId, vin: $vin, vout: $vout, blockHeight: $blockHeight, confirmations: $confirmations, rbf: $rbf, fees: $fees, size: $size, vSize: $vSize)';
}


}

/// @nodoc
abstract mixin class $TransactionBtcNodeDtoCopyWith<$Res>  {
  factory $TransactionBtcNodeDtoCopyWith(TransactionBtcNodeDto value, $Res Function(TransactionBtcNodeDto) _then) = _$TransactionBtcNodeDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'txid') String txId, List<VinDto> vin, List<VoutDto> vout,@JsonKey(name: 'blockHeight') int blockHeight, int confirmations, bool rbf, String fees, int size,@JsonKey(name: 'vsize') int vSize
});




}
/// @nodoc
class _$TransactionBtcNodeDtoCopyWithImpl<$Res>
    implements $TransactionBtcNodeDtoCopyWith<$Res> {
  _$TransactionBtcNodeDtoCopyWithImpl(this._self, this._then);

  final TransactionBtcNodeDto _self;
  final $Res Function(TransactionBtcNodeDto) _then;

/// Create a copy of TransactionBtcNodeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? txId = null,Object? vin = null,Object? vout = null,Object? blockHeight = null,Object? confirmations = null,Object? rbf = null,Object? fees = null,Object? size = null,Object? vSize = null,}) {
  return _then(_self.copyWith(
txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,vin: null == vin ? _self.vin : vin // ignore: cast_nullable_to_non_nullable
as List<VinDto>,vout: null == vout ? _self.vout : vout // ignore: cast_nullable_to_non_nullable
as List<VoutDto>,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,confirmations: null == confirmations ? _self.confirmations : confirmations // ignore: cast_nullable_to_non_nullable
as int,rbf: null == rbf ? _self.rbf : rbf // ignore: cast_nullable_to_non_nullable
as bool,fees: null == fees ? _self.fees : fees // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,vSize: null == vSize ? _self.vSize : vSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionBtcNodeDto].
extension TransactionBtcNodeDtoPatterns on TransactionBtcNodeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionBtcNodeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionBtcNodeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionBtcNodeDto value)  $default,){
final _that = this;
switch (_that) {
case _TransactionBtcNodeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionBtcNodeDto value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionBtcNodeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'txid')  String txId,  List<VinDto> vin,  List<VoutDto> vout, @JsonKey(name: 'blockHeight')  int blockHeight,  int confirmations,  bool rbf,  String fees,  int size, @JsonKey(name: 'vsize')  int vSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionBtcNodeDto() when $default != null:
return $default(_that.txId,_that.vin,_that.vout,_that.blockHeight,_that.confirmations,_that.rbf,_that.fees,_that.size,_that.vSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'txid')  String txId,  List<VinDto> vin,  List<VoutDto> vout, @JsonKey(name: 'blockHeight')  int blockHeight,  int confirmations,  bool rbf,  String fees,  int size, @JsonKey(name: 'vsize')  int vSize)  $default,) {final _that = this;
switch (_that) {
case _TransactionBtcNodeDto():
return $default(_that.txId,_that.vin,_that.vout,_that.blockHeight,_that.confirmations,_that.rbf,_that.fees,_that.size,_that.vSize);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'txid')  String txId,  List<VinDto> vin,  List<VoutDto> vout, @JsonKey(name: 'blockHeight')  int blockHeight,  int confirmations,  bool rbf,  String fees,  int size, @JsonKey(name: 'vsize')  int vSize)?  $default,) {final _that = this;
switch (_that) {
case _TransactionBtcNodeDto() when $default != null:
return $default(_that.txId,_that.vin,_that.vout,_that.blockHeight,_that.confirmations,_that.rbf,_that.fees,_that.size,_that.vSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionBtcNodeDto extends TransactionBtcNodeDto {
  const _TransactionBtcNodeDto({@JsonKey(name: 'txid') required this.txId, required final  List<VinDto> vin, required final  List<VoutDto> vout, @JsonKey(name: 'blockHeight') required this.blockHeight, required this.confirmations, required this.rbf, required this.fees, required this.size, @JsonKey(name: 'vsize') required this.vSize}): _vin = vin,_vout = vout,super._();
  factory _TransactionBtcNodeDto.fromJson(Map<String, dynamic> json) => _$TransactionBtcNodeDtoFromJson(json);

@override@JsonKey(name: 'txid') final  String txId;
// int? version,
 final  List<VinDto> _vin;
// int? version,
@override List<VinDto> get vin {
  if (_vin is EqualUnmodifiableListView) return _vin;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vin);
}

 final  List<VoutDto> _vout;
@override List<VoutDto> get vout {
  if (_vout is EqualUnmodifiableListView) return _vout;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vout);
}

@override@JsonKey(name: 'blockHeight') final  int blockHeight;
@override final  int confirmations;
@override final  bool rbf;
@override final  String fees;
@override final  int size;
@override@JsonKey(name: 'vsize') final  int vSize;

/// Create a copy of TransactionBtcNodeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionBtcNodeDtoCopyWith<_TransactionBtcNodeDto> get copyWith => __$TransactionBtcNodeDtoCopyWithImpl<_TransactionBtcNodeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionBtcNodeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionBtcNodeDto&&(identical(other.txId, txId) || other.txId == txId)&&const DeepCollectionEquality().equals(other._vin, _vin)&&const DeepCollectionEquality().equals(other._vout, _vout)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight)&&(identical(other.confirmations, confirmations) || other.confirmations == confirmations)&&(identical(other.rbf, rbf) || other.rbf == rbf)&&(identical(other.fees, fees) || other.fees == fees)&&(identical(other.size, size) || other.size == size)&&(identical(other.vSize, vSize) || other.vSize == vSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txId,const DeepCollectionEquality().hash(_vin),const DeepCollectionEquality().hash(_vout),blockHeight,confirmations,rbf,fees,size,vSize);

@override
String toString() {
  return 'TransactionBtcNodeDto(txId: $txId, vin: $vin, vout: $vout, blockHeight: $blockHeight, confirmations: $confirmations, rbf: $rbf, fees: $fees, size: $size, vSize: $vSize)';
}


}

/// @nodoc
abstract mixin class _$TransactionBtcNodeDtoCopyWith<$Res> implements $TransactionBtcNodeDtoCopyWith<$Res> {
  factory _$TransactionBtcNodeDtoCopyWith(_TransactionBtcNodeDto value, $Res Function(_TransactionBtcNodeDto) _then) = __$TransactionBtcNodeDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'txid') String txId, List<VinDto> vin, List<VoutDto> vout,@JsonKey(name: 'blockHeight') int blockHeight, int confirmations, bool rbf, String fees, int size,@JsonKey(name: 'vsize') int vSize
});




}
/// @nodoc
class __$TransactionBtcNodeDtoCopyWithImpl<$Res>
    implements _$TransactionBtcNodeDtoCopyWith<$Res> {
  __$TransactionBtcNodeDtoCopyWithImpl(this._self, this._then);

  final _TransactionBtcNodeDto _self;
  final $Res Function(_TransactionBtcNodeDto) _then;

/// Create a copy of TransactionBtcNodeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txId = null,Object? vin = null,Object? vout = null,Object? blockHeight = null,Object? confirmations = null,Object? rbf = null,Object? fees = null,Object? size = null,Object? vSize = null,}) {
  return _then(_TransactionBtcNodeDto(
txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,vin: null == vin ? _self._vin : vin // ignore: cast_nullable_to_non_nullable
as List<VinDto>,vout: null == vout ? _self._vout : vout // ignore: cast_nullable_to_non_nullable
as List<VoutDto>,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,confirmations: null == confirmations ? _self.confirmations : confirmations // ignore: cast_nullable_to_non_nullable
as int,rbf: null == rbf ? _self.rbf : rbf // ignore: cast_nullable_to_non_nullable
as bool,fees: null == fees ? _self.fees : fees // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,vSize: null == vSize ? _self.vSize : vSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$VinDto {

@JsonKey(name: 'txid') String? get txId;// int? vout,
 int? get sequence; int? get n; List<String>? get addresses;@JsonKey(name: 'isAddress') bool? get isAddress; String? get value;
/// Create a copy of VinDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VinDtoCopyWith<VinDto> get copyWith => _$VinDtoCopyWithImpl<VinDto>(this as VinDto, _$identity);

  /// Serializes this VinDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VinDto&&(identical(other.txId, txId) || other.txId == txId)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.n, n) || other.n == n)&&const DeepCollectionEquality().equals(other.addresses, addresses)&&(identical(other.isAddress, isAddress) || other.isAddress == isAddress)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txId,sequence,n,const DeepCollectionEquality().hash(addresses),isAddress,value);

@override
String toString() {
  return 'VinDto(txId: $txId, sequence: $sequence, n: $n, addresses: $addresses, isAddress: $isAddress, value: $value)';
}


}

/// @nodoc
abstract mixin class $VinDtoCopyWith<$Res>  {
  factory $VinDtoCopyWith(VinDto value, $Res Function(VinDto) _then) = _$VinDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'txid') String? txId, int? sequence, int? n, List<String>? addresses,@JsonKey(name: 'isAddress') bool? isAddress, String? value
});




}
/// @nodoc
class _$VinDtoCopyWithImpl<$Res>
    implements $VinDtoCopyWith<$Res> {
  _$VinDtoCopyWithImpl(this._self, this._then);

  final VinDto _self;
  final $Res Function(VinDto) _then;

/// Create a copy of VinDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? txId = freezed,Object? sequence = freezed,Object? n = freezed,Object? addresses = freezed,Object? isAddress = freezed,Object? value = freezed,}) {
  return _then(_self.copyWith(
txId: freezed == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String?,sequence: freezed == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int?,n: freezed == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int?,addresses: freezed == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>?,isAddress: freezed == isAddress ? _self.isAddress : isAddress // ignore: cast_nullable_to_non_nullable
as bool?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VinDto].
extension VinDtoPatterns on VinDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VinDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VinDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VinDto value)  $default,){
final _that = this;
switch (_that) {
case _VinDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VinDto value)?  $default,){
final _that = this;
switch (_that) {
case _VinDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'txid')  String? txId,  int? sequence,  int? n,  List<String>? addresses, @JsonKey(name: 'isAddress')  bool? isAddress,  String? value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VinDto() when $default != null:
return $default(_that.txId,_that.sequence,_that.n,_that.addresses,_that.isAddress,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'txid')  String? txId,  int? sequence,  int? n,  List<String>? addresses, @JsonKey(name: 'isAddress')  bool? isAddress,  String? value)  $default,) {final _that = this;
switch (_that) {
case _VinDto():
return $default(_that.txId,_that.sequence,_that.n,_that.addresses,_that.isAddress,_that.value);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'txid')  String? txId,  int? sequence,  int? n,  List<String>? addresses, @JsonKey(name: 'isAddress')  bool? isAddress,  String? value)?  $default,) {final _that = this;
switch (_that) {
case _VinDto() when $default != null:
return $default(_that.txId,_that.sequence,_that.n,_that.addresses,_that.isAddress,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VinDto extends VinDto {
  const _VinDto({@JsonKey(name: 'txid') this.txId, this.sequence, this.n, final  List<String>? addresses, @JsonKey(name: 'isAddress') this.isAddress, this.value}): _addresses = addresses,super._();
  factory _VinDto.fromJson(Map<String, dynamic> json) => _$VinDtoFromJson(json);

@override@JsonKey(name: 'txid') final  String? txId;
// int? vout,
@override final  int? sequence;
@override final  int? n;
 final  List<String>? _addresses;
@override List<String>? get addresses {
  final value = _addresses;
  if (value == null) return null;
  if (_addresses is EqualUnmodifiableListView) return _addresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'isAddress') final  bool? isAddress;
@override final  String? value;

/// Create a copy of VinDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VinDtoCopyWith<_VinDto> get copyWith => __$VinDtoCopyWithImpl<_VinDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VinDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VinDto&&(identical(other.txId, txId) || other.txId == txId)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.n, n) || other.n == n)&&const DeepCollectionEquality().equals(other._addresses, _addresses)&&(identical(other.isAddress, isAddress) || other.isAddress == isAddress)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txId,sequence,n,const DeepCollectionEquality().hash(_addresses),isAddress,value);

@override
String toString() {
  return 'VinDto(txId: $txId, sequence: $sequence, n: $n, addresses: $addresses, isAddress: $isAddress, value: $value)';
}


}

/// @nodoc
abstract mixin class _$VinDtoCopyWith<$Res> implements $VinDtoCopyWith<$Res> {
  factory _$VinDtoCopyWith(_VinDto value, $Res Function(_VinDto) _then) = __$VinDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'txid') String? txId, int? sequence, int? n, List<String>? addresses,@JsonKey(name: 'isAddress') bool? isAddress, String? value
});




}
/// @nodoc
class __$VinDtoCopyWithImpl<$Res>
    implements _$VinDtoCopyWith<$Res> {
  __$VinDtoCopyWithImpl(this._self, this._then);

  final _VinDto _self;
  final $Res Function(_VinDto) _then;

/// Create a copy of VinDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txId = freezed,Object? sequence = freezed,Object? n = freezed,Object? addresses = freezed,Object? isAddress = freezed,Object? value = freezed,}) {
  return _then(_VinDto(
txId: freezed == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String?,sequence: freezed == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int?,n: freezed == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int?,addresses: freezed == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>?,isAddress: freezed == isAddress ? _self.isAddress : isAddress // ignore: cast_nullable_to_non_nullable
as bool?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VoutDto {

/// DTO входа Vin
 String? get value; int? get n; String? get hex; List<String>? get addresses;@JsonKey(name: 'isAddress') bool? get isAddress;
/// Create a copy of VoutDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoutDtoCopyWith<VoutDto> get copyWith => _$VoutDtoCopyWithImpl<VoutDto>(this as VoutDto, _$identity);

  /// Serializes this VoutDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoutDto&&(identical(other.value, value) || other.value == value)&&(identical(other.n, n) || other.n == n)&&(identical(other.hex, hex) || other.hex == hex)&&const DeepCollectionEquality().equals(other.addresses, addresses)&&(identical(other.isAddress, isAddress) || other.isAddress == isAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,n,hex,const DeepCollectionEquality().hash(addresses),isAddress);

@override
String toString() {
  return 'VoutDto(value: $value, n: $n, hex: $hex, addresses: $addresses, isAddress: $isAddress)';
}


}

/// @nodoc
abstract mixin class $VoutDtoCopyWith<$Res>  {
  factory $VoutDtoCopyWith(VoutDto value, $Res Function(VoutDto) _then) = _$VoutDtoCopyWithImpl;
@useResult
$Res call({
 String? value, int? n, String? hex, List<String>? addresses,@JsonKey(name: 'isAddress') bool? isAddress
});




}
/// @nodoc
class _$VoutDtoCopyWithImpl<$Res>
    implements $VoutDtoCopyWith<$Res> {
  _$VoutDtoCopyWithImpl(this._self, this._then);

  final VoutDto _self;
  final $Res Function(VoutDto) _then;

/// Create a copy of VoutDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = freezed,Object? n = freezed,Object? hex = freezed,Object? addresses = freezed,Object? isAddress = freezed,}) {
  return _then(_self.copyWith(
value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,n: freezed == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int?,hex: freezed == hex ? _self.hex : hex // ignore: cast_nullable_to_non_nullable
as String?,addresses: freezed == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>?,isAddress: freezed == isAddress ? _self.isAddress : isAddress // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoutDto].
extension VoutDtoPatterns on VoutDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoutDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoutDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoutDto value)  $default,){
final _that = this;
switch (_that) {
case _VoutDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoutDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoutDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? value,  int? n,  String? hex,  List<String>? addresses, @JsonKey(name: 'isAddress')  bool? isAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoutDto() when $default != null:
return $default(_that.value,_that.n,_that.hex,_that.addresses,_that.isAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? value,  int? n,  String? hex,  List<String>? addresses, @JsonKey(name: 'isAddress')  bool? isAddress)  $default,) {final _that = this;
switch (_that) {
case _VoutDto():
return $default(_that.value,_that.n,_that.hex,_that.addresses,_that.isAddress);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? value,  int? n,  String? hex,  List<String>? addresses, @JsonKey(name: 'isAddress')  bool? isAddress)?  $default,) {final _that = this;
switch (_that) {
case _VoutDto() when $default != null:
return $default(_that.value,_that.n,_that.hex,_that.addresses,_that.isAddress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoutDto extends VoutDto {
  const _VoutDto({this.value, this.n, this.hex, final  List<String>? addresses, @JsonKey(name: 'isAddress') this.isAddress}): _addresses = addresses,super._();
  factory _VoutDto.fromJson(Map<String, dynamic> json) => _$VoutDtoFromJson(json);

/// DTO входа Vin
@override final  String? value;
@override final  int? n;
@override final  String? hex;
 final  List<String>? _addresses;
@override List<String>? get addresses {
  final value = _addresses;
  if (value == null) return null;
  if (_addresses is EqualUnmodifiableListView) return _addresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'isAddress') final  bool? isAddress;

/// Create a copy of VoutDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoutDtoCopyWith<_VoutDto> get copyWith => __$VoutDtoCopyWithImpl<_VoutDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoutDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoutDto&&(identical(other.value, value) || other.value == value)&&(identical(other.n, n) || other.n == n)&&(identical(other.hex, hex) || other.hex == hex)&&const DeepCollectionEquality().equals(other._addresses, _addresses)&&(identical(other.isAddress, isAddress) || other.isAddress == isAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,n,hex,const DeepCollectionEquality().hash(_addresses),isAddress);

@override
String toString() {
  return 'VoutDto(value: $value, n: $n, hex: $hex, addresses: $addresses, isAddress: $isAddress)';
}


}

/// @nodoc
abstract mixin class _$VoutDtoCopyWith<$Res> implements $VoutDtoCopyWith<$Res> {
  factory _$VoutDtoCopyWith(_VoutDto value, $Res Function(_VoutDto) _then) = __$VoutDtoCopyWithImpl;
@override @useResult
$Res call({
 String? value, int? n, String? hex, List<String>? addresses,@JsonKey(name: 'isAddress') bool? isAddress
});




}
/// @nodoc
class __$VoutDtoCopyWithImpl<$Res>
    implements _$VoutDtoCopyWith<$Res> {
  __$VoutDtoCopyWithImpl(this._self, this._then);

  final _VoutDto _self;
  final $Res Function(_VoutDto) _then;

/// Create a copy of VoutDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = freezed,Object? n = freezed,Object? hex = freezed,Object? addresses = freezed,Object? isAddress = freezed,}) {
  return _then(_VoutDto(
value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,n: freezed == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int?,hex: freezed == hex ? _self.hex : hex // ignore: cast_nullable_to_non_nullable
as String?,addresses: freezed == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>?,isAddress: freezed == isAddress ? _self.isAddress : isAddress // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
