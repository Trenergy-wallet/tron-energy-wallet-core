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
mixin _$TransactionBtcNode {

 String get txId;// required int version,
 List<Vin> get vin; List<Vout> get vout; int get blockHeight; int get confirmations; bool get rbf; int? get fees; int get size; int get vSize;
/// Create a copy of TransactionBtcNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionBtcNodeCopyWith<TransactionBtcNode> get copyWith => _$TransactionBtcNodeCopyWithImpl<TransactionBtcNode>(this as TransactionBtcNode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionBtcNode&&(identical(other.txId, txId) || other.txId == txId)&&const DeepCollectionEquality().equals(other.vin, vin)&&const DeepCollectionEquality().equals(other.vout, vout)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight)&&(identical(other.confirmations, confirmations) || other.confirmations == confirmations)&&(identical(other.rbf, rbf) || other.rbf == rbf)&&(identical(other.fees, fees) || other.fees == fees)&&(identical(other.size, size) || other.size == size)&&(identical(other.vSize, vSize) || other.vSize == vSize));
}


@override
int get hashCode => Object.hash(runtimeType,txId,const DeepCollectionEquality().hash(vin),const DeepCollectionEquality().hash(vout),blockHeight,confirmations,rbf,fees,size,vSize);

@override
String toString() {
  return 'TransactionBtcNode(txId: $txId, vin: $vin, vout: $vout, blockHeight: $blockHeight, confirmations: $confirmations, rbf: $rbf, fees: $fees, size: $size, vSize: $vSize)';
}


}

/// @nodoc
abstract mixin class $TransactionBtcNodeCopyWith<$Res>  {
  factory $TransactionBtcNodeCopyWith(TransactionBtcNode value, $Res Function(TransactionBtcNode) _then) = _$TransactionBtcNodeCopyWithImpl;
@useResult
$Res call({
 String txId, List<Vin> vin, List<Vout> vout, int blockHeight, int confirmations, bool rbf, int? fees, int size, int vSize
});




}
/// @nodoc
class _$TransactionBtcNodeCopyWithImpl<$Res>
    implements $TransactionBtcNodeCopyWith<$Res> {
  _$TransactionBtcNodeCopyWithImpl(this._self, this._then);

  final TransactionBtcNode _self;
  final $Res Function(TransactionBtcNode) _then;

/// Create a copy of TransactionBtcNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? txId = null,Object? vin = null,Object? vout = null,Object? blockHeight = null,Object? confirmations = null,Object? rbf = null,Object? fees = freezed,Object? size = null,Object? vSize = null,}) {
  return _then(_self.copyWith(
txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,vin: null == vin ? _self.vin : vin // ignore: cast_nullable_to_non_nullable
as List<Vin>,vout: null == vout ? _self.vout : vout // ignore: cast_nullable_to_non_nullable
as List<Vout>,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,confirmations: null == confirmations ? _self.confirmations : confirmations // ignore: cast_nullable_to_non_nullable
as int,rbf: null == rbf ? _self.rbf : rbf // ignore: cast_nullable_to_non_nullable
as bool,fees: freezed == fees ? _self.fees : fees // ignore: cast_nullable_to_non_nullable
as int?,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,vSize: null == vSize ? _self.vSize : vSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionBtcNode].
extension TransactionBtcNodePatterns on TransactionBtcNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionBtcNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionBtcNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionBtcNode value)  $default,){
final _that = this;
switch (_that) {
case _TransactionBtcNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionBtcNode value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionBtcNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String txId,  List<Vin> vin,  List<Vout> vout,  int blockHeight,  int confirmations,  bool rbf,  int? fees,  int size,  int vSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionBtcNode() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String txId,  List<Vin> vin,  List<Vout> vout,  int blockHeight,  int confirmations,  bool rbf,  int? fees,  int size,  int vSize)  $default,) {final _that = this;
switch (_that) {
case _TransactionBtcNode():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String txId,  List<Vin> vin,  List<Vout> vout,  int blockHeight,  int confirmations,  bool rbf,  int? fees,  int size,  int vSize)?  $default,) {final _that = this;
switch (_that) {
case _TransactionBtcNode() when $default != null:
return $default(_that.txId,_that.vin,_that.vout,_that.blockHeight,_that.confirmations,_that.rbf,_that.fees,_that.size,_that.vSize);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionBtcNode extends TransactionBtcNode {
  const _TransactionBtcNode({required this.txId, required final  List<Vin> vin, required final  List<Vout> vout, required this.blockHeight, required this.confirmations, required this.rbf, required this.fees, required this.size, required this.vSize}): _vin = vin,_vout = vout,super._();
  

@override final  String txId;
// required int version,
 final  List<Vin> _vin;
// required int version,
@override List<Vin> get vin {
  if (_vin is EqualUnmodifiableListView) return _vin;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vin);
}

 final  List<Vout> _vout;
@override List<Vout> get vout {
  if (_vout is EqualUnmodifiableListView) return _vout;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vout);
}

@override final  int blockHeight;
@override final  int confirmations;
@override final  bool rbf;
@override final  int? fees;
@override final  int size;
@override final  int vSize;

/// Create a copy of TransactionBtcNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionBtcNodeCopyWith<_TransactionBtcNode> get copyWith => __$TransactionBtcNodeCopyWithImpl<_TransactionBtcNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionBtcNode&&(identical(other.txId, txId) || other.txId == txId)&&const DeepCollectionEquality().equals(other._vin, _vin)&&const DeepCollectionEquality().equals(other._vout, _vout)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight)&&(identical(other.confirmations, confirmations) || other.confirmations == confirmations)&&(identical(other.rbf, rbf) || other.rbf == rbf)&&(identical(other.fees, fees) || other.fees == fees)&&(identical(other.size, size) || other.size == size)&&(identical(other.vSize, vSize) || other.vSize == vSize));
}


@override
int get hashCode => Object.hash(runtimeType,txId,const DeepCollectionEquality().hash(_vin),const DeepCollectionEquality().hash(_vout),blockHeight,confirmations,rbf,fees,size,vSize);

@override
String toString() {
  return 'TransactionBtcNode(txId: $txId, vin: $vin, vout: $vout, blockHeight: $blockHeight, confirmations: $confirmations, rbf: $rbf, fees: $fees, size: $size, vSize: $vSize)';
}


}

/// @nodoc
abstract mixin class _$TransactionBtcNodeCopyWith<$Res> implements $TransactionBtcNodeCopyWith<$Res> {
  factory _$TransactionBtcNodeCopyWith(_TransactionBtcNode value, $Res Function(_TransactionBtcNode) _then) = __$TransactionBtcNodeCopyWithImpl;
@override @useResult
$Res call({
 String txId, List<Vin> vin, List<Vout> vout, int blockHeight, int confirmations, bool rbf, int? fees, int size, int vSize
});




}
/// @nodoc
class __$TransactionBtcNodeCopyWithImpl<$Res>
    implements _$TransactionBtcNodeCopyWith<$Res> {
  __$TransactionBtcNodeCopyWithImpl(this._self, this._then);

  final _TransactionBtcNode _self;
  final $Res Function(_TransactionBtcNode) _then;

/// Create a copy of TransactionBtcNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txId = null,Object? vin = null,Object? vout = null,Object? blockHeight = null,Object? confirmations = null,Object? rbf = null,Object? fees = freezed,Object? size = null,Object? vSize = null,}) {
  return _then(_TransactionBtcNode(
txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,vin: null == vin ? _self._vin : vin // ignore: cast_nullable_to_non_nullable
as List<Vin>,vout: null == vout ? _self._vout : vout // ignore: cast_nullable_to_non_nullable
as List<Vout>,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,confirmations: null == confirmations ? _self.confirmations : confirmations // ignore: cast_nullable_to_non_nullable
as int,rbf: null == rbf ? _self.rbf : rbf // ignore: cast_nullable_to_non_nullable
as bool,fees: freezed == fees ? _self.fees : fees // ignore: cast_nullable_to_non_nullable
as int?,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,vSize: null == vSize ? _self.vSize : vSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$Vin {

 String get txId;// required int vout,
 int get sequence; int get n; List<String> get addresses; bool get isAddress; int get valueInSatoshi;
/// Create a copy of Vin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VinCopyWith<Vin> get copyWith => _$VinCopyWithImpl<Vin>(this as Vin, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vin&&(identical(other.txId, txId) || other.txId == txId)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.n, n) || other.n == n)&&const DeepCollectionEquality().equals(other.addresses, addresses)&&(identical(other.isAddress, isAddress) || other.isAddress == isAddress)&&(identical(other.valueInSatoshi, valueInSatoshi) || other.valueInSatoshi == valueInSatoshi));
}


@override
int get hashCode => Object.hash(runtimeType,txId,sequence,n,const DeepCollectionEquality().hash(addresses),isAddress,valueInSatoshi);

@override
String toString() {
  return 'Vin(txId: $txId, sequence: $sequence, n: $n, addresses: $addresses, isAddress: $isAddress, valueInSatoshi: $valueInSatoshi)';
}


}

/// @nodoc
abstract mixin class $VinCopyWith<$Res>  {
  factory $VinCopyWith(Vin value, $Res Function(Vin) _then) = _$VinCopyWithImpl;
@useResult
$Res call({
 String txId, int sequence, int n, List<String> addresses, bool isAddress, int valueInSatoshi
});




}
/// @nodoc
class _$VinCopyWithImpl<$Res>
    implements $VinCopyWith<$Res> {
  _$VinCopyWithImpl(this._self, this._then);

  final Vin _self;
  final $Res Function(Vin) _then;

/// Create a copy of Vin
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? txId = null,Object? sequence = null,Object? n = null,Object? addresses = null,Object? isAddress = null,Object? valueInSatoshi = null,}) {
  return _then(_self.copyWith(
txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,addresses: null == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>,isAddress: null == isAddress ? _self.isAddress : isAddress // ignore: cast_nullable_to_non_nullable
as bool,valueInSatoshi: null == valueInSatoshi ? _self.valueInSatoshi : valueInSatoshi // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Vin].
extension VinPatterns on Vin {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vin value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vin() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vin value)  $default,){
final _that = this;
switch (_that) {
case _Vin():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vin value)?  $default,){
final _that = this;
switch (_that) {
case _Vin() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String txId,  int sequence,  int n,  List<String> addresses,  bool isAddress,  int valueInSatoshi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vin() when $default != null:
return $default(_that.txId,_that.sequence,_that.n,_that.addresses,_that.isAddress,_that.valueInSatoshi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String txId,  int sequence,  int n,  List<String> addresses,  bool isAddress,  int valueInSatoshi)  $default,) {final _that = this;
switch (_that) {
case _Vin():
return $default(_that.txId,_that.sequence,_that.n,_that.addresses,_that.isAddress,_that.valueInSatoshi);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String txId,  int sequence,  int n,  List<String> addresses,  bool isAddress,  int valueInSatoshi)?  $default,) {final _that = this;
switch (_that) {
case _Vin() when $default != null:
return $default(_that.txId,_that.sequence,_that.n,_that.addresses,_that.isAddress,_that.valueInSatoshi);case _:
  return null;

}
}

}

/// @nodoc


class _Vin implements Vin {
  const _Vin({required this.txId, required this.sequence, required this.n, required final  List<String> addresses, required this.isAddress, required this.valueInSatoshi}): _addresses = addresses;
  

@override final  String txId;
// required int vout,
@override final  int sequence;
@override final  int n;
 final  List<String> _addresses;
@override List<String> get addresses {
  if (_addresses is EqualUnmodifiableListView) return _addresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addresses);
}

@override final  bool isAddress;
@override final  int valueInSatoshi;

/// Create a copy of Vin
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VinCopyWith<_Vin> get copyWith => __$VinCopyWithImpl<_Vin>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vin&&(identical(other.txId, txId) || other.txId == txId)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.n, n) || other.n == n)&&const DeepCollectionEquality().equals(other._addresses, _addresses)&&(identical(other.isAddress, isAddress) || other.isAddress == isAddress)&&(identical(other.valueInSatoshi, valueInSatoshi) || other.valueInSatoshi == valueInSatoshi));
}


@override
int get hashCode => Object.hash(runtimeType,txId,sequence,n,const DeepCollectionEquality().hash(_addresses),isAddress,valueInSatoshi);

@override
String toString() {
  return 'Vin(txId: $txId, sequence: $sequence, n: $n, addresses: $addresses, isAddress: $isAddress, valueInSatoshi: $valueInSatoshi)';
}


}

/// @nodoc
abstract mixin class _$VinCopyWith<$Res> implements $VinCopyWith<$Res> {
  factory _$VinCopyWith(_Vin value, $Res Function(_Vin) _then) = __$VinCopyWithImpl;
@override @useResult
$Res call({
 String txId, int sequence, int n, List<String> addresses, bool isAddress, int valueInSatoshi
});




}
/// @nodoc
class __$VinCopyWithImpl<$Res>
    implements _$VinCopyWith<$Res> {
  __$VinCopyWithImpl(this._self, this._then);

  final _Vin _self;
  final $Res Function(_Vin) _then;

/// Create a copy of Vin
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txId = null,Object? sequence = null,Object? n = null,Object? addresses = null,Object? isAddress = null,Object? valueInSatoshi = null,}) {
  return _then(_Vin(
txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,addresses: null == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>,isAddress: null == isAddress ? _self.isAddress : isAddress // ignore: cast_nullable_to_non_nullable
as bool,valueInSatoshi: null == valueInSatoshi ? _self.valueInSatoshi : valueInSatoshi // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$Vout {

/// DTO входа Vin
 int get valueInSatoshi; int get n; String get hex; List<String> get addresses; bool get isAddress;
/// Create a copy of Vout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoutCopyWith<Vout> get copyWith => _$VoutCopyWithImpl<Vout>(this as Vout, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vout&&(identical(other.valueInSatoshi, valueInSatoshi) || other.valueInSatoshi == valueInSatoshi)&&(identical(other.n, n) || other.n == n)&&(identical(other.hex, hex) || other.hex == hex)&&const DeepCollectionEquality().equals(other.addresses, addresses)&&(identical(other.isAddress, isAddress) || other.isAddress == isAddress));
}


@override
int get hashCode => Object.hash(runtimeType,valueInSatoshi,n,hex,const DeepCollectionEquality().hash(addresses),isAddress);

@override
String toString() {
  return 'Vout(valueInSatoshi: $valueInSatoshi, n: $n, hex: $hex, addresses: $addresses, isAddress: $isAddress)';
}


}

/// @nodoc
abstract mixin class $VoutCopyWith<$Res>  {
  factory $VoutCopyWith(Vout value, $Res Function(Vout) _then) = _$VoutCopyWithImpl;
@useResult
$Res call({
 int valueInSatoshi, int n, String hex, List<String> addresses, bool isAddress
});




}
/// @nodoc
class _$VoutCopyWithImpl<$Res>
    implements $VoutCopyWith<$Res> {
  _$VoutCopyWithImpl(this._self, this._then);

  final Vout _self;
  final $Res Function(Vout) _then;

/// Create a copy of Vout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? valueInSatoshi = null,Object? n = null,Object? hex = null,Object? addresses = null,Object? isAddress = null,}) {
  return _then(_self.copyWith(
valueInSatoshi: null == valueInSatoshi ? _self.valueInSatoshi : valueInSatoshi // ignore: cast_nullable_to_non_nullable
as int,n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,hex: null == hex ? _self.hex : hex // ignore: cast_nullable_to_non_nullable
as String,addresses: null == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>,isAddress: null == isAddress ? _self.isAddress : isAddress // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Vout].
extension VoutPatterns on Vout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vout value)  $default,){
final _that = this;
switch (_that) {
case _Vout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vout value)?  $default,){
final _that = this;
switch (_that) {
case _Vout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int valueInSatoshi,  int n,  String hex,  List<String> addresses,  bool isAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vout() when $default != null:
return $default(_that.valueInSatoshi,_that.n,_that.hex,_that.addresses,_that.isAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int valueInSatoshi,  int n,  String hex,  List<String> addresses,  bool isAddress)  $default,) {final _that = this;
switch (_that) {
case _Vout():
return $default(_that.valueInSatoshi,_that.n,_that.hex,_that.addresses,_that.isAddress);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int valueInSatoshi,  int n,  String hex,  List<String> addresses,  bool isAddress)?  $default,) {final _that = this;
switch (_that) {
case _Vout() when $default != null:
return $default(_that.valueInSatoshi,_that.n,_that.hex,_that.addresses,_that.isAddress);case _:
  return null;

}
}

}

/// @nodoc


class _Vout implements Vout {
  const _Vout({required this.valueInSatoshi, required this.n, required this.hex, required final  List<String> addresses, required this.isAddress}): _addresses = addresses;
  

/// DTO входа Vin
@override final  int valueInSatoshi;
@override final  int n;
@override final  String hex;
 final  List<String> _addresses;
@override List<String> get addresses {
  if (_addresses is EqualUnmodifiableListView) return _addresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addresses);
}

@override final  bool isAddress;

/// Create a copy of Vout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoutCopyWith<_Vout> get copyWith => __$VoutCopyWithImpl<_Vout>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vout&&(identical(other.valueInSatoshi, valueInSatoshi) || other.valueInSatoshi == valueInSatoshi)&&(identical(other.n, n) || other.n == n)&&(identical(other.hex, hex) || other.hex == hex)&&const DeepCollectionEquality().equals(other._addresses, _addresses)&&(identical(other.isAddress, isAddress) || other.isAddress == isAddress));
}


@override
int get hashCode => Object.hash(runtimeType,valueInSatoshi,n,hex,const DeepCollectionEquality().hash(_addresses),isAddress);

@override
String toString() {
  return 'Vout(valueInSatoshi: $valueInSatoshi, n: $n, hex: $hex, addresses: $addresses, isAddress: $isAddress)';
}


}

/// @nodoc
abstract mixin class _$VoutCopyWith<$Res> implements $VoutCopyWith<$Res> {
  factory _$VoutCopyWith(_Vout value, $Res Function(_Vout) _then) = __$VoutCopyWithImpl;
@override @useResult
$Res call({
 int valueInSatoshi, int n, String hex, List<String> addresses, bool isAddress
});




}
/// @nodoc
class __$VoutCopyWithImpl<$Res>
    implements _$VoutCopyWith<$Res> {
  __$VoutCopyWithImpl(this._self, this._then);

  final _Vout _self;
  final $Res Function(_Vout) _then;

/// Create a copy of Vout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? valueInSatoshi = null,Object? n = null,Object? hex = null,Object? addresses = null,Object? isAddress = null,}) {
  return _then(_Vout(
valueInSatoshi: null == valueInSatoshi ? _self.valueInSatoshi : valueInSatoshi // ignore: cast_nullable_to_non_nullable
as int,n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,hex: null == hex ? _self.hex : hex // ignore: cast_nullable_to_non_nullable
as String,addresses: null == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>,isAddress: null == isAddress ? _self.isAddress : isAddress // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
