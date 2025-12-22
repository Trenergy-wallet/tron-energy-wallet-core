// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../wallet.cg.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BlockchainInfo {

 int get id; String get name; String get shortName; String get icon; bool get isNew; List<AppToken> get tokens; AppBlockchain get appBlockchain; bool get supportsEIP1559; int get chainId; int get networkId;
/// Create a copy of BlockchainInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockchainInfoCopyWith<BlockchainInfo> get copyWith => _$BlockchainInfoCopyWithImpl<BlockchainInfo>(this as BlockchainInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockchainInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.isNew, isNew) || other.isNew == isNew)&&const DeepCollectionEquality().equals(other.tokens, tokens)&&(identical(other.appBlockchain, appBlockchain) || other.appBlockchain == appBlockchain)&&(identical(other.supportsEIP1559, supportsEIP1559) || other.supportsEIP1559 == supportsEIP1559)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.networkId, networkId) || other.networkId == networkId));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,shortName,icon,isNew,const DeepCollectionEquality().hash(tokens),appBlockchain,supportsEIP1559,chainId,networkId);

@override
String toString() {
  return 'BlockchainInfo(id: $id, name: $name, shortName: $shortName, icon: $icon, isNew: $isNew, tokens: $tokens, appBlockchain: $appBlockchain, supportsEIP1559: $supportsEIP1559, chainId: $chainId, networkId: $networkId)';
}


}

/// @nodoc
abstract mixin class $BlockchainInfoCopyWith<$Res>  {
  factory $BlockchainInfoCopyWith(BlockchainInfo value, $Res Function(BlockchainInfo) _then) = _$BlockchainInfoCopyWithImpl;
@useResult
$Res call({
 int id, String name, String shortName, String icon, bool isNew, List<AppToken> tokens, AppBlockchain appBlockchain, bool supportsEIP1559, int chainId, int networkId
});




}
/// @nodoc
class _$BlockchainInfoCopyWithImpl<$Res>
    implements $BlockchainInfoCopyWith<$Res> {
  _$BlockchainInfoCopyWithImpl(this._self, this._then);

  final BlockchainInfo _self;
  final $Res Function(BlockchainInfo) _then;

/// Create a copy of BlockchainInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? shortName = null,Object? icon = null,Object? isNew = null,Object? tokens = null,Object? appBlockchain = null,Object? supportsEIP1559 = null,Object? chainId = null,Object? networkId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as List<AppToken>,appBlockchain: null == appBlockchain ? _self.appBlockchain : appBlockchain // ignore: cast_nullable_to_non_nullable
as AppBlockchain,supportsEIP1559: null == supportsEIP1559 ? _self.supportsEIP1559 : supportsEIP1559 // ignore: cast_nullable_to_non_nullable
as bool,chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as int,networkId: null == networkId ? _self.networkId : networkId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BlockchainInfo].
extension BlockchainInfoPatterns on BlockchainInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlockchainInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlockchainInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlockchainInfo value)  $default,){
final _that = this;
switch (_that) {
case _BlockchainInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlockchainInfo value)?  $default,){
final _that = this;
switch (_that) {
case _BlockchainInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String shortName,  String icon,  bool isNew,  List<AppToken> tokens,  AppBlockchain appBlockchain,  bool supportsEIP1559,  int chainId,  int networkId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlockchainInfo() when $default != null:
return $default(_that.id,_that.name,_that.shortName,_that.icon,_that.isNew,_that.tokens,_that.appBlockchain,_that.supportsEIP1559,_that.chainId,_that.networkId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String shortName,  String icon,  bool isNew,  List<AppToken> tokens,  AppBlockchain appBlockchain,  bool supportsEIP1559,  int chainId,  int networkId)  $default,) {final _that = this;
switch (_that) {
case _BlockchainInfo():
return $default(_that.id,_that.name,_that.shortName,_that.icon,_that.isNew,_that.tokens,_that.appBlockchain,_that.supportsEIP1559,_that.chainId,_that.networkId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String shortName,  String icon,  bool isNew,  List<AppToken> tokens,  AppBlockchain appBlockchain,  bool supportsEIP1559,  int chainId,  int networkId)?  $default,) {final _that = this;
switch (_that) {
case _BlockchainInfo() when $default != null:
return $default(_that.id,_that.name,_that.shortName,_that.icon,_that.isNew,_that.tokens,_that.appBlockchain,_that.supportsEIP1559,_that.chainId,_that.networkId);case _:
  return null;

}
}

}

/// @nodoc


class _BlockchainInfo extends BlockchainInfo {
  const _BlockchainInfo({required this.id, required this.name, required this.shortName, required this.icon, required this.isNew, required final  List<AppToken> tokens, required this.appBlockchain, required this.supportsEIP1559, required this.chainId, required this.networkId}): _tokens = tokens,super._();
  

@override final  int id;
@override final  String name;
@override final  String shortName;
@override final  String icon;
@override final  bool isNew;
 final  List<AppToken> _tokens;
@override List<AppToken> get tokens {
  if (_tokens is EqualUnmodifiableListView) return _tokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tokens);
}

@override final  AppBlockchain appBlockchain;
@override final  bool supportsEIP1559;
@override final  int chainId;
@override final  int networkId;

/// Create a copy of BlockchainInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockchainInfoCopyWith<_BlockchainInfo> get copyWith => __$BlockchainInfoCopyWithImpl<_BlockchainInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlockchainInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.isNew, isNew) || other.isNew == isNew)&&const DeepCollectionEquality().equals(other._tokens, _tokens)&&(identical(other.appBlockchain, appBlockchain) || other.appBlockchain == appBlockchain)&&(identical(other.supportsEIP1559, supportsEIP1559) || other.supportsEIP1559 == supportsEIP1559)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.networkId, networkId) || other.networkId == networkId));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,shortName,icon,isNew,const DeepCollectionEquality().hash(_tokens),appBlockchain,supportsEIP1559,chainId,networkId);

@override
String toString() {
  return 'BlockchainInfo(id: $id, name: $name, shortName: $shortName, icon: $icon, isNew: $isNew, tokens: $tokens, appBlockchain: $appBlockchain, supportsEIP1559: $supportsEIP1559, chainId: $chainId, networkId: $networkId)';
}


}

/// @nodoc
abstract mixin class _$BlockchainInfoCopyWith<$Res> implements $BlockchainInfoCopyWith<$Res> {
  factory _$BlockchainInfoCopyWith(_BlockchainInfo value, $Res Function(_BlockchainInfo) _then) = __$BlockchainInfoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String shortName, String icon, bool isNew, List<AppToken> tokens, AppBlockchain appBlockchain, bool supportsEIP1559, int chainId, int networkId
});




}
/// @nodoc
class __$BlockchainInfoCopyWithImpl<$Res>
    implements _$BlockchainInfoCopyWith<$Res> {
  __$BlockchainInfoCopyWithImpl(this._self, this._then);

  final _BlockchainInfo _self;
  final $Res Function(_BlockchainInfo) _then;

/// Create a copy of BlockchainInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? shortName = null,Object? icon = null,Object? isNew = null,Object? tokens = null,Object? appBlockchain = null,Object? supportsEIP1559 = null,Object? chainId = null,Object? networkId = null,}) {
  return _then(_BlockchainInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,tokens: null == tokens ? _self._tokens : tokens // ignore: cast_nullable_to_non_nullable
as List<AppToken>,appBlockchain: null == appBlockchain ? _self.appBlockchain : appBlockchain // ignore: cast_nullable_to_non_nullable
as AppBlockchain,supportsEIP1559: null == supportsEIP1559 ? _self.supportsEIP1559 : supportsEIP1559 // ignore: cast_nullable_to_non_nullable
as bool,chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as int,networkId: null == networkId ? _self.networkId : networkId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$AppCurrency {

 int get id; String get name; String get code; double get usdRate; int? get currentIndex;
/// Create a copy of AppCurrency
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppCurrencyCopyWith<AppCurrency> get copyWith => _$AppCurrencyCopyWithImpl<AppCurrency>(this as AppCurrency, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppCurrency&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.usdRate, usdRate) || other.usdRate == usdRate)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,code,usdRate,currentIndex);

@override
String toString() {
  return 'AppCurrency(id: $id, name: $name, code: $code, usdRate: $usdRate, currentIndex: $currentIndex)';
}


}

/// @nodoc
abstract mixin class $AppCurrencyCopyWith<$Res>  {
  factory $AppCurrencyCopyWith(AppCurrency value, $Res Function(AppCurrency) _then) = _$AppCurrencyCopyWithImpl;
@useResult
$Res call({
 int id, String name, String code, double usdRate, int? currentIndex
});




}
/// @nodoc
class _$AppCurrencyCopyWithImpl<$Res>
    implements $AppCurrencyCopyWith<$Res> {
  _$AppCurrencyCopyWithImpl(this._self, this._then);

  final AppCurrency _self;
  final $Res Function(AppCurrency) _then;

/// Create a copy of AppCurrency
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = null,Object? usdRate = null,Object? currentIndex = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,usdRate: null == usdRate ? _self.usdRate : usdRate // ignore: cast_nullable_to_non_nullable
as double,currentIndex: freezed == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppCurrency].
extension AppCurrencyPatterns on AppCurrency {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppCurrency value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppCurrency() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppCurrency value)  $default,){
final _that = this;
switch (_that) {
case _AppCurrency():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppCurrency value)?  $default,){
final _that = this;
switch (_that) {
case _AppCurrency() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String code,  double usdRate,  int? currentIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppCurrency() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.usdRate,_that.currentIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String code,  double usdRate,  int? currentIndex)  $default,) {final _that = this;
switch (_that) {
case _AppCurrency():
return $default(_that.id,_that.name,_that.code,_that.usdRate,_that.currentIndex);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String code,  double usdRate,  int? currentIndex)?  $default,) {final _that = this;
switch (_that) {
case _AppCurrency() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.usdRate,_that.currentIndex);case _:
  return null;

}
}

}

/// @nodoc


class _AppCurrency implements AppCurrency {
  const _AppCurrency({required this.id, required this.name, required this.code, required this.usdRate, this.currentIndex});
  

@override final  int id;
@override final  String name;
@override final  String code;
@override final  double usdRate;
@override final  int? currentIndex;

/// Create a copy of AppCurrency
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppCurrencyCopyWith<_AppCurrency> get copyWith => __$AppCurrencyCopyWithImpl<_AppCurrency>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppCurrency&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.usdRate, usdRate) || other.usdRate == usdRate)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,code,usdRate,currentIndex);

@override
String toString() {
  return 'AppCurrency(id: $id, name: $name, code: $code, usdRate: $usdRate, currentIndex: $currentIndex)';
}


}

/// @nodoc
abstract mixin class _$AppCurrencyCopyWith<$Res> implements $AppCurrencyCopyWith<$Res> {
  factory _$AppCurrencyCopyWith(_AppCurrency value, $Res Function(_AppCurrency) _then) = __$AppCurrencyCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String code, double usdRate, int? currentIndex
});




}
/// @nodoc
class __$AppCurrencyCopyWithImpl<$Res>
    implements _$AppCurrencyCopyWith<$Res> {
  __$AppCurrencyCopyWithImpl(this._self, this._then);

  final _AppCurrency _self;
  final $Res Function(_AppCurrency) _then;

/// Create a copy of AppCurrency
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = null,Object? usdRate = null,Object? currentIndex = freezed,}) {
  return _then(_AppCurrency(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,usdRate: null == usdRate ? _self.usdRate : usdRate // ignore: cast_nullable_to_non_nullable
as double,currentIndex: freezed == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$AppAsset {

 int get id; BigRational get balance; BigRational get hold; AppToken get token; String get address; int get walletId; String get childWalletAddress;
/// Create a copy of AppAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppAssetCopyWith<AppAsset> get copyWith => _$AppAssetCopyWithImpl<AppAsset>(this as AppAsset, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.hold, hold) || other.hold == hold)&&(identical(other.token, token) || other.token == token)&&(identical(other.address, address) || other.address == address)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.childWalletAddress, childWalletAddress) || other.childWalletAddress == childWalletAddress));
}


@override
int get hashCode => Object.hash(runtimeType,id,balance,hold,token,address,walletId,childWalletAddress);

@override
String toString() {
  return 'AppAsset(id: $id, balance: $balance, hold: $hold, token: $token, address: $address, walletId: $walletId, childWalletAddress: $childWalletAddress)';
}


}

/// @nodoc
abstract mixin class $AppAssetCopyWith<$Res>  {
  factory $AppAssetCopyWith(AppAsset value, $Res Function(AppAsset) _then) = _$AppAssetCopyWithImpl;
@useResult
$Res call({
 int id, BigRational balance, BigRational hold, AppToken token, String address, int walletId, String childWalletAddress
});


$AppTokenCopyWith<$Res> get token;

}
/// @nodoc
class _$AppAssetCopyWithImpl<$Res>
    implements $AppAssetCopyWith<$Res> {
  _$AppAssetCopyWithImpl(this._self, this._then);

  final AppAsset _self;
  final $Res Function(AppAsset) _then;

/// Create a copy of AppAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? balance = null,Object? hold = null,Object? token = null,Object? address = null,Object? walletId = null,Object? childWalletAddress = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as BigRational,hold: null == hold ? _self.hold : hold // ignore: cast_nullable_to_non_nullable
as BigRational,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as AppToken,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as int,childWalletAddress: null == childWalletAddress ? _self.childWalletAddress : childWalletAddress // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AppAsset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppTokenCopyWith<$Res> get token {
  
  return $AppTokenCopyWith<$Res>(_self.token, (value) {
    return _then(_self.copyWith(token: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppAsset].
extension AppAssetPatterns on AppAsset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppAsset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppAsset value)  $default,){
final _that = this;
switch (_that) {
case _AppAsset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppAsset value)?  $default,){
final _that = this;
switch (_that) {
case _AppAsset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  BigRational balance,  BigRational hold,  AppToken token,  String address,  int walletId,  String childWalletAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppAsset() when $default != null:
return $default(_that.id,_that.balance,_that.hold,_that.token,_that.address,_that.walletId,_that.childWalletAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  BigRational balance,  BigRational hold,  AppToken token,  String address,  int walletId,  String childWalletAddress)  $default,) {final _that = this;
switch (_that) {
case _AppAsset():
return $default(_that.id,_that.balance,_that.hold,_that.token,_that.address,_that.walletId,_that.childWalletAddress);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  BigRational balance,  BigRational hold,  AppToken token,  String address,  int walletId,  String childWalletAddress)?  $default,) {final _that = this;
switch (_that) {
case _AppAsset() when $default != null:
return $default(_that.id,_that.balance,_that.hold,_that.token,_that.address,_that.walletId,_that.childWalletAddress);case _:
  return null;

}
}

}

/// @nodoc


class _AppAsset extends AppAsset {
  const _AppAsset({required this.id, required this.balance, required this.hold, required this.token, required this.address, required this.walletId, required this.childWalletAddress}): super._();
  

@override final  int id;
@override final  BigRational balance;
@override final  BigRational hold;
@override final  AppToken token;
@override final  String address;
@override final  int walletId;
@override final  String childWalletAddress;

/// Create a copy of AppAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppAssetCopyWith<_AppAsset> get copyWith => __$AppAssetCopyWithImpl<_AppAsset>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.hold, hold) || other.hold == hold)&&(identical(other.token, token) || other.token == token)&&(identical(other.address, address) || other.address == address)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.childWalletAddress, childWalletAddress) || other.childWalletAddress == childWalletAddress));
}


@override
int get hashCode => Object.hash(runtimeType,id,balance,hold,token,address,walletId,childWalletAddress);

@override
String toString() {
  return 'AppAsset(id: $id, balance: $balance, hold: $hold, token: $token, address: $address, walletId: $walletId, childWalletAddress: $childWalletAddress)';
}


}

/// @nodoc
abstract mixin class _$AppAssetCopyWith<$Res> implements $AppAssetCopyWith<$Res> {
  factory _$AppAssetCopyWith(_AppAsset value, $Res Function(_AppAsset) _then) = __$AppAssetCopyWithImpl;
@override @useResult
$Res call({
 int id, BigRational balance, BigRational hold, AppToken token, String address, int walletId, String childWalletAddress
});


@override $AppTokenCopyWith<$Res> get token;

}
/// @nodoc
class __$AppAssetCopyWithImpl<$Res>
    implements _$AppAssetCopyWith<$Res> {
  __$AppAssetCopyWithImpl(this._self, this._then);

  final _AppAsset _self;
  final $Res Function(_AppAsset) _then;

/// Create a copy of AppAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? balance = null,Object? hold = null,Object? token = null,Object? address = null,Object? walletId = null,Object? childWalletAddress = null,}) {
  return _then(_AppAsset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as BigRational,hold: null == hold ? _self.hold : hold // ignore: cast_nullable_to_non_nullable
as BigRational,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as AppToken,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as int,childWalletAddress: null == childWalletAddress ? _self.childWalletAddress : childWalletAddress // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AppAsset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppTokenCopyWith<$Res> get token {
  
  return $AppTokenCopyWith<$Res>(_self.token, (value) {
    return _then(_self.copyWith(token: value));
  });
}
}

/// @nodoc
mixin _$AppToken {

 int get id; String get name; String get shortName; String get icon; double get usdPrice; double get prevPriceDiffPercent; String get contractAddress; int get decimal; BlockchainInfo get blockchain; TokenWalletType get tokenWalletType; String get description; int get precision; bool get isAddedToAssets;
/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppTokenCopyWith<AppToken> get copyWith => _$AppTokenCopyWithImpl<AppToken>(this as AppToken, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppToken&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.usdPrice, usdPrice) || other.usdPrice == usdPrice)&&(identical(other.prevPriceDiffPercent, prevPriceDiffPercent) || other.prevPriceDiffPercent == prevPriceDiffPercent)&&(identical(other.contractAddress, contractAddress) || other.contractAddress == contractAddress)&&(identical(other.decimal, decimal) || other.decimal == decimal)&&(identical(other.blockchain, blockchain) || other.blockchain == blockchain)&&(identical(other.tokenWalletType, tokenWalletType) || other.tokenWalletType == tokenWalletType)&&(identical(other.description, description) || other.description == description)&&(identical(other.precision, precision) || other.precision == precision)&&(identical(other.isAddedToAssets, isAddedToAssets) || other.isAddedToAssets == isAddedToAssets));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,shortName,icon,usdPrice,prevPriceDiffPercent,contractAddress,decimal,blockchain,tokenWalletType,description,precision,isAddedToAssets);

@override
String toString() {
  return 'AppToken(id: $id, name: $name, shortName: $shortName, icon: $icon, usdPrice: $usdPrice, prevPriceDiffPercent: $prevPriceDiffPercent, contractAddress: $contractAddress, decimal: $decimal, blockchain: $blockchain, tokenWalletType: $tokenWalletType, description: $description, precision: $precision, isAddedToAssets: $isAddedToAssets)';
}


}

/// @nodoc
abstract mixin class $AppTokenCopyWith<$Res>  {
  factory $AppTokenCopyWith(AppToken value, $Res Function(AppToken) _then) = _$AppTokenCopyWithImpl;
@useResult
$Res call({
 int id, String name, String shortName, String icon, double usdPrice, double prevPriceDiffPercent, String contractAddress, int decimal, BlockchainInfo blockchain, TokenWalletType tokenWalletType, String description, int precision, bool isAddedToAssets
});


$BlockchainInfoCopyWith<$Res> get blockchain;

}
/// @nodoc
class _$AppTokenCopyWithImpl<$Res>
    implements $AppTokenCopyWith<$Res> {
  _$AppTokenCopyWithImpl(this._self, this._then);

  final AppToken _self;
  final $Res Function(AppToken) _then;

/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? shortName = null,Object? icon = null,Object? usdPrice = null,Object? prevPriceDiffPercent = null,Object? contractAddress = null,Object? decimal = null,Object? blockchain = null,Object? tokenWalletType = null,Object? description = null,Object? precision = null,Object? isAddedToAssets = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,usdPrice: null == usdPrice ? _self.usdPrice : usdPrice // ignore: cast_nullable_to_non_nullable
as double,prevPriceDiffPercent: null == prevPriceDiffPercent ? _self.prevPriceDiffPercent : prevPriceDiffPercent // ignore: cast_nullable_to_non_nullable
as double,contractAddress: null == contractAddress ? _self.contractAddress : contractAddress // ignore: cast_nullable_to_non_nullable
as String,decimal: null == decimal ? _self.decimal : decimal // ignore: cast_nullable_to_non_nullable
as int,blockchain: null == blockchain ? _self.blockchain : blockchain // ignore: cast_nullable_to_non_nullable
as BlockchainInfo,tokenWalletType: null == tokenWalletType ? _self.tokenWalletType : tokenWalletType // ignore: cast_nullable_to_non_nullable
as TokenWalletType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,precision: null == precision ? _self.precision : precision // ignore: cast_nullable_to_non_nullable
as int,isAddedToAssets: null == isAddedToAssets ? _self.isAddedToAssets : isAddedToAssets // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlockchainInfoCopyWith<$Res> get blockchain {
  
  return $BlockchainInfoCopyWith<$Res>(_self.blockchain, (value) {
    return _then(_self.copyWith(blockchain: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppToken].
extension AppTokenPatterns on AppToken {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppToken value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppToken() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppToken value)  $default,){
final _that = this;
switch (_that) {
case _AppToken():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppToken value)?  $default,){
final _that = this;
switch (_that) {
case _AppToken() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String shortName,  String icon,  double usdPrice,  double prevPriceDiffPercent,  String contractAddress,  int decimal,  BlockchainInfo blockchain,  TokenWalletType tokenWalletType,  String description,  int precision,  bool isAddedToAssets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppToken() when $default != null:
return $default(_that.id,_that.name,_that.shortName,_that.icon,_that.usdPrice,_that.prevPriceDiffPercent,_that.contractAddress,_that.decimal,_that.blockchain,_that.tokenWalletType,_that.description,_that.precision,_that.isAddedToAssets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String shortName,  String icon,  double usdPrice,  double prevPriceDiffPercent,  String contractAddress,  int decimal,  BlockchainInfo blockchain,  TokenWalletType tokenWalletType,  String description,  int precision,  bool isAddedToAssets)  $default,) {final _that = this;
switch (_that) {
case _AppToken():
return $default(_that.id,_that.name,_that.shortName,_that.icon,_that.usdPrice,_that.prevPriceDiffPercent,_that.contractAddress,_that.decimal,_that.blockchain,_that.tokenWalletType,_that.description,_that.precision,_that.isAddedToAssets);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String shortName,  String icon,  double usdPrice,  double prevPriceDiffPercent,  String contractAddress,  int decimal,  BlockchainInfo blockchain,  TokenWalletType tokenWalletType,  String description,  int precision,  bool isAddedToAssets)?  $default,) {final _that = this;
switch (_that) {
case _AppToken() when $default != null:
return $default(_that.id,_that.name,_that.shortName,_that.icon,_that.usdPrice,_that.prevPriceDiffPercent,_that.contractAddress,_that.decimal,_that.blockchain,_that.tokenWalletType,_that.description,_that.precision,_that.isAddedToAssets);case _:
  return null;

}
}

}

/// @nodoc


class _AppToken extends AppToken {
  const _AppToken({required this.id, required this.name, required this.shortName, required this.icon, required this.usdPrice, required this.prevPriceDiffPercent, required this.contractAddress, required this.decimal, required this.blockchain, required this.tokenWalletType, required this.description, required this.precision, this.isAddedToAssets = false}): super._();
  

@override final  int id;
@override final  String name;
@override final  String shortName;
@override final  String icon;
@override final  double usdPrice;
@override final  double prevPriceDiffPercent;
@override final  String contractAddress;
@override final  int decimal;
@override final  BlockchainInfo blockchain;
@override final  TokenWalletType tokenWalletType;
@override final  String description;
@override final  int precision;
@override@JsonKey() final  bool isAddedToAssets;

/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppTokenCopyWith<_AppToken> get copyWith => __$AppTokenCopyWithImpl<_AppToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppToken&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.usdPrice, usdPrice) || other.usdPrice == usdPrice)&&(identical(other.prevPriceDiffPercent, prevPriceDiffPercent) || other.prevPriceDiffPercent == prevPriceDiffPercent)&&(identical(other.contractAddress, contractAddress) || other.contractAddress == contractAddress)&&(identical(other.decimal, decimal) || other.decimal == decimal)&&(identical(other.blockchain, blockchain) || other.blockchain == blockchain)&&(identical(other.tokenWalletType, tokenWalletType) || other.tokenWalletType == tokenWalletType)&&(identical(other.description, description) || other.description == description)&&(identical(other.precision, precision) || other.precision == precision)&&(identical(other.isAddedToAssets, isAddedToAssets) || other.isAddedToAssets == isAddedToAssets));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,shortName,icon,usdPrice,prevPriceDiffPercent,contractAddress,decimal,blockchain,tokenWalletType,description,precision,isAddedToAssets);

@override
String toString() {
  return 'AppToken(id: $id, name: $name, shortName: $shortName, icon: $icon, usdPrice: $usdPrice, prevPriceDiffPercent: $prevPriceDiffPercent, contractAddress: $contractAddress, decimal: $decimal, blockchain: $blockchain, tokenWalletType: $tokenWalletType, description: $description, precision: $precision, isAddedToAssets: $isAddedToAssets)';
}


}

/// @nodoc
abstract mixin class _$AppTokenCopyWith<$Res> implements $AppTokenCopyWith<$Res> {
  factory _$AppTokenCopyWith(_AppToken value, $Res Function(_AppToken) _then) = __$AppTokenCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String shortName, String icon, double usdPrice, double prevPriceDiffPercent, String contractAddress, int decimal, BlockchainInfo blockchain, TokenWalletType tokenWalletType, String description, int precision, bool isAddedToAssets
});


@override $BlockchainInfoCopyWith<$Res> get blockchain;

}
/// @nodoc
class __$AppTokenCopyWithImpl<$Res>
    implements _$AppTokenCopyWith<$Res> {
  __$AppTokenCopyWithImpl(this._self, this._then);

  final _AppToken _self;
  final $Res Function(_AppToken) _then;

/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? shortName = null,Object? icon = null,Object? usdPrice = null,Object? prevPriceDiffPercent = null,Object? contractAddress = null,Object? decimal = null,Object? blockchain = null,Object? tokenWalletType = null,Object? description = null,Object? precision = null,Object? isAddedToAssets = null,}) {
  return _then(_AppToken(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,usdPrice: null == usdPrice ? _self.usdPrice : usdPrice // ignore: cast_nullable_to_non_nullable
as double,prevPriceDiffPercent: null == prevPriceDiffPercent ? _self.prevPriceDiffPercent : prevPriceDiffPercent // ignore: cast_nullable_to_non_nullable
as double,contractAddress: null == contractAddress ? _self.contractAddress : contractAddress // ignore: cast_nullable_to_non_nullable
as String,decimal: null == decimal ? _self.decimal : decimal // ignore: cast_nullable_to_non_nullable
as int,blockchain: null == blockchain ? _self.blockchain : blockchain // ignore: cast_nullable_to_non_nullable
as BlockchainInfo,tokenWalletType: null == tokenWalletType ? _self.tokenWalletType : tokenWalletType // ignore: cast_nullable_to_non_nullable
as TokenWalletType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,precision: null == precision ? _self.precision : precision // ignore: cast_nullable_to_non_nullable
as int,isAddedToAssets: null == isAddedToAssets ? _self.isAddedToAssets : isAddedToAssets // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlockchainInfoCopyWith<$Res> get blockchain {
  
  return $BlockchainInfoCopyWith<$Res>(_self.blockchain, (value) {
    return _then(_self.copyWith(blockchain: value));
  });
}
}

// dart format on
