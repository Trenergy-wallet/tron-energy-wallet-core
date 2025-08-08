// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../local_account.cg.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalAccount {

 String get name; String get description; String get iconPath; String get iconColorBg; String get address; String get publicKey; String get token; bool get useFavorite; bool get hasWalletRights; bool get useShowPartnerPromo;
/// Create a copy of LocalAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalAccountCopyWith<LocalAccount> get copyWith => _$LocalAccountCopyWithImpl<LocalAccount>(this as LocalAccount, _$identity);

  /// Serializes this LocalAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalAccount&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconPath, iconPath) || other.iconPath == iconPath)&&(identical(other.iconColorBg, iconColorBg) || other.iconColorBg == iconColorBg)&&(identical(other.address, address) || other.address == address)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.token, token) || other.token == token)&&(identical(other.useFavorite, useFavorite) || other.useFavorite == useFavorite)&&(identical(other.hasWalletRights, hasWalletRights) || other.hasWalletRights == hasWalletRights)&&(identical(other.useShowPartnerPromo, useShowPartnerPromo) || other.useShowPartnerPromo == useShowPartnerPromo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,iconPath,iconColorBg,address,publicKey,token,useFavorite,hasWalletRights,useShowPartnerPromo);

@override
String toString() {
  return 'LocalAccount(name: $name, description: $description, iconPath: $iconPath, iconColorBg: $iconColorBg, address: $address, publicKey: $publicKey, token: $token, useFavorite: $useFavorite, hasWalletRights: $hasWalletRights, useShowPartnerPromo: $useShowPartnerPromo)';
}


}

/// @nodoc
abstract mixin class $LocalAccountCopyWith<$Res>  {
  factory $LocalAccountCopyWith(LocalAccount value, $Res Function(LocalAccount) _then) = _$LocalAccountCopyWithImpl;
@useResult
$Res call({
 String name, String description, String iconPath, String iconColorBg, String address, String publicKey, String token, bool useFavorite, bool hasWalletRights, bool useShowPartnerPromo
});




}
/// @nodoc
class _$LocalAccountCopyWithImpl<$Res>
    implements $LocalAccountCopyWith<$Res> {
  _$LocalAccountCopyWithImpl(this._self, this._then);

  final LocalAccount _self;
  final $Res Function(LocalAccount) _then;

/// Create a copy of LocalAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? iconPath = null,Object? iconColorBg = null,Object? address = null,Object? publicKey = null,Object? token = null,Object? useFavorite = null,Object? hasWalletRights = null,Object? useShowPartnerPromo = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,iconPath: null == iconPath ? _self.iconPath : iconPath // ignore: cast_nullable_to_non_nullable
as String,iconColorBg: null == iconColorBg ? _self.iconColorBg : iconColorBg // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,useFavorite: null == useFavorite ? _self.useFavorite : useFavorite // ignore: cast_nullable_to_non_nullable
as bool,hasWalletRights: null == hasWalletRights ? _self.hasWalletRights : hasWalletRights // ignore: cast_nullable_to_non_nullable
as bool,useShowPartnerPromo: null == useShowPartnerPromo ? _self.useShowPartnerPromo : useShowPartnerPromo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalAccount].
extension LocalAccountPatterns on LocalAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalAccount value)  $default,){
final _that = this;
switch (_that) {
case _LocalAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalAccount value)?  $default,){
final _that = this;
switch (_that) {
case _LocalAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  String iconPath,  String iconColorBg,  String address,  String publicKey,  String token,  bool useFavorite,  bool hasWalletRights,  bool useShowPartnerPromo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalAccount() when $default != null:
return $default(_that.name,_that.description,_that.iconPath,_that.iconColorBg,_that.address,_that.publicKey,_that.token,_that.useFavorite,_that.hasWalletRights,_that.useShowPartnerPromo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  String iconPath,  String iconColorBg,  String address,  String publicKey,  String token,  bool useFavorite,  bool hasWalletRights,  bool useShowPartnerPromo)  $default,) {final _that = this;
switch (_that) {
case _LocalAccount():
return $default(_that.name,_that.description,_that.iconPath,_that.iconColorBg,_that.address,_that.publicKey,_that.token,_that.useFavorite,_that.hasWalletRights,_that.useShowPartnerPromo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  String iconPath,  String iconColorBg,  String address,  String publicKey,  String token,  bool useFavorite,  bool hasWalletRights,  bool useShowPartnerPromo)?  $default,) {final _that = this;
switch (_that) {
case _LocalAccount() when $default != null:
return $default(_that.name,_that.description,_that.iconPath,_that.iconColorBg,_that.address,_that.publicKey,_that.token,_that.useFavorite,_that.hasWalletRights,_that.useShowPartnerPromo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalAccount extends LocalAccount {
  const _LocalAccount({required this.name, required this.description, required this.iconPath, required this.iconColorBg, required this.address, required this.publicKey, required this.token, this.useFavorite = false, this.hasWalletRights = false, this.useShowPartnerPromo = true}): super._();
  factory _LocalAccount.fromJson(Map<String, dynamic> json) => _$LocalAccountFromJson(json);

@override final  String name;
@override final  String description;
@override final  String iconPath;
@override final  String iconColorBg;
@override final  String address;
@override final  String publicKey;
@override final  String token;
@override@JsonKey() final  bool useFavorite;
@override@JsonKey() final  bool hasWalletRights;
@override@JsonKey() final  bool useShowPartnerPromo;

/// Create a copy of LocalAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalAccountCopyWith<_LocalAccount> get copyWith => __$LocalAccountCopyWithImpl<_LocalAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalAccount&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconPath, iconPath) || other.iconPath == iconPath)&&(identical(other.iconColorBg, iconColorBg) || other.iconColorBg == iconColorBg)&&(identical(other.address, address) || other.address == address)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.token, token) || other.token == token)&&(identical(other.useFavorite, useFavorite) || other.useFavorite == useFavorite)&&(identical(other.hasWalletRights, hasWalletRights) || other.hasWalletRights == hasWalletRights)&&(identical(other.useShowPartnerPromo, useShowPartnerPromo) || other.useShowPartnerPromo == useShowPartnerPromo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,iconPath,iconColorBg,address,publicKey,token,useFavorite,hasWalletRights,useShowPartnerPromo);

@override
String toString() {
  return 'LocalAccount(name: $name, description: $description, iconPath: $iconPath, iconColorBg: $iconColorBg, address: $address, publicKey: $publicKey, token: $token, useFavorite: $useFavorite, hasWalletRights: $hasWalletRights, useShowPartnerPromo: $useShowPartnerPromo)';
}


}

/// @nodoc
abstract mixin class _$LocalAccountCopyWith<$Res> implements $LocalAccountCopyWith<$Res> {
  factory _$LocalAccountCopyWith(_LocalAccount value, $Res Function(_LocalAccount) _then) = __$LocalAccountCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, String iconPath, String iconColorBg, String address, String publicKey, String token, bool useFavorite, bool hasWalletRights, bool useShowPartnerPromo
});




}
/// @nodoc
class __$LocalAccountCopyWithImpl<$Res>
    implements _$LocalAccountCopyWith<$Res> {
  __$LocalAccountCopyWithImpl(this._self, this._then);

  final _LocalAccount _self;
  final $Res Function(_LocalAccount) _then;

/// Create a copy of LocalAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? iconPath = null,Object? iconColorBg = null,Object? address = null,Object? publicKey = null,Object? token = null,Object? useFavorite = null,Object? hasWalletRights = null,Object? useShowPartnerPromo = null,}) {
  return _then(_LocalAccount(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,iconPath: null == iconPath ? _self.iconPath : iconPath // ignore: cast_nullable_to_non_nullable
as String,iconColorBg: null == iconColorBg ? _self.iconColorBg : iconColorBg // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,useFavorite: null == useFavorite ? _self.useFavorite : useFavorite // ignore: cast_nullable_to_non_nullable
as bool,hasWalletRights: null == hasWalletRights ? _self.hasWalletRights : hasWalletRights // ignore: cast_nullable_to_non_nullable
as bool,useShowPartnerPromo: null == useShowPartnerPromo ? _self.useShowPartnerPromo : useShowPartnerPromo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
