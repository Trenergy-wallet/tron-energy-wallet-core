// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../estimate_fee.cg.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EstimateFeeModel {

 double get fee; double get energy; Fees get fees;
/// Create a copy of EstimateFeeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EstimateFeeModelCopyWith<EstimateFeeModel> get copyWith => _$EstimateFeeModelCopyWithImpl<EstimateFeeModel>(this as EstimateFeeModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EstimateFeeModel&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.fees, fees) || other.fees == fees));
}


@override
int get hashCode => Object.hash(runtimeType,fee,energy,fees);

@override
String toString() {
  return 'EstimateFeeModel(fee: $fee, energy: $energy, fees: $fees)';
}


}

/// @nodoc
abstract mixin class $EstimateFeeModelCopyWith<$Res>  {
  factory $EstimateFeeModelCopyWith(EstimateFeeModel value, $Res Function(EstimateFeeModel) _then) = _$EstimateFeeModelCopyWithImpl;
@useResult
$Res call({
 double fee, double energy, Fees fees
});


$FeesCopyWith<$Res> get fees;

}
/// @nodoc
class _$EstimateFeeModelCopyWithImpl<$Res>
    implements $EstimateFeeModelCopyWith<$Res> {
  _$EstimateFeeModelCopyWithImpl(this._self, this._then);

  final EstimateFeeModel _self;
  final $Res Function(EstimateFeeModel) _then;

/// Create a copy of EstimateFeeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fee = null,Object? energy = null,Object? fees = null,}) {
  return _then(_self.copyWith(
fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as double,fees: null == fees ? _self.fees : fees // ignore: cast_nullable_to_non_nullable
as Fees,
  ));
}
/// Create a copy of EstimateFeeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FeesCopyWith<$Res> get fees {
  
  return $FeesCopyWith<$Res>(_self.fees, (value) {
    return _then(_self.copyWith(fees: value));
  });
}
}


/// Adds pattern-matching-related methods to [EstimateFeeModel].
extension EstimateFeeModelPatterns on EstimateFeeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EstimateFeeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EstimateFeeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EstimateFeeModel value)  $default,){
final _that = this;
switch (_that) {
case _EstimateFeeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EstimateFeeModel value)?  $default,){
final _that = this;
switch (_that) {
case _EstimateFeeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double fee,  double energy,  Fees fees)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EstimateFeeModel() when $default != null:
return $default(_that.fee,_that.energy,_that.fees);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double fee,  double energy,  Fees fees)  $default,) {final _that = this;
switch (_that) {
case _EstimateFeeModel():
return $default(_that.fee,_that.energy,_that.fees);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double fee,  double energy,  Fees fees)?  $default,) {final _that = this;
switch (_that) {
case _EstimateFeeModel() when $default != null:
return $default(_that.fee,_that.energy,_that.fees);case _:
  return null;

}
}

}

/// @nodoc


class _EstimateFeeModel extends EstimateFeeModel {
  const _EstimateFeeModel({required this.fee, required this.energy, required this.fees}): super._();
  

@override final  double fee;
@override final  double energy;
@override final  Fees fees;

/// Create a copy of EstimateFeeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EstimateFeeModelCopyWith<_EstimateFeeModel> get copyWith => __$EstimateFeeModelCopyWithImpl<_EstimateFeeModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EstimateFeeModel&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.fees, fees) || other.fees == fees));
}


@override
int get hashCode => Object.hash(runtimeType,fee,energy,fees);

@override
String toString() {
  return 'EstimateFeeModel(fee: $fee, energy: $energy, fees: $fees)';
}


}

/// @nodoc
abstract mixin class _$EstimateFeeModelCopyWith<$Res> implements $EstimateFeeModelCopyWith<$Res> {
  factory _$EstimateFeeModelCopyWith(_EstimateFeeModel value, $Res Function(_EstimateFeeModel) _then) = __$EstimateFeeModelCopyWithImpl;
@override @useResult
$Res call({
 double fee, double energy, Fees fees
});


@override $FeesCopyWith<$Res> get fees;

}
/// @nodoc
class __$EstimateFeeModelCopyWithImpl<$Res>
    implements _$EstimateFeeModelCopyWith<$Res> {
  __$EstimateFeeModelCopyWithImpl(this._self, this._then);

  final _EstimateFeeModel _self;
  final $Res Function(_EstimateFeeModel) _then;

/// Create a copy of EstimateFeeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fee = null,Object? energy = null,Object? fees = null,}) {
  return _then(_EstimateFeeModel(
fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as double,fees: null == fees ? _self.fees : fees // ignore: cast_nullable_to_non_nullable
as Fees,
  ));
}

/// Create a copy of EstimateFeeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FeesCopyWith<$Res> get fees {
  
  return $FeesCopyWith<$Res>(_self.fees, (value) {
    return _then(_self.copyWith(fees: value));
  });
}
}

/// @nodoc
mixin _$Fees {

 int get fastestFee; int get halfHourFee; int get hourFee; int get economyFee; int get minimumFee;
/// Create a copy of Fees
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeesCopyWith<Fees> get copyWith => _$FeesCopyWithImpl<Fees>(this as Fees, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Fees&&(identical(other.fastestFee, fastestFee) || other.fastestFee == fastestFee)&&(identical(other.halfHourFee, halfHourFee) || other.halfHourFee == halfHourFee)&&(identical(other.hourFee, hourFee) || other.hourFee == hourFee)&&(identical(other.economyFee, economyFee) || other.economyFee == economyFee)&&(identical(other.minimumFee, minimumFee) || other.minimumFee == minimumFee));
}


@override
int get hashCode => Object.hash(runtimeType,fastestFee,halfHourFee,hourFee,economyFee,minimumFee);

@override
String toString() {
  return 'Fees(fastestFee: $fastestFee, halfHourFee: $halfHourFee, hourFee: $hourFee, economyFee: $economyFee, minimumFee: $minimumFee)';
}


}

/// @nodoc
abstract mixin class $FeesCopyWith<$Res>  {
  factory $FeesCopyWith(Fees value, $Res Function(Fees) _then) = _$FeesCopyWithImpl;
@useResult
$Res call({
 int fastestFee, int halfHourFee, int hourFee, int economyFee, int minimumFee
});




}
/// @nodoc
class _$FeesCopyWithImpl<$Res>
    implements $FeesCopyWith<$Res> {
  _$FeesCopyWithImpl(this._self, this._then);

  final Fees _self;
  final $Res Function(Fees) _then;

/// Create a copy of Fees
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fastestFee = null,Object? halfHourFee = null,Object? hourFee = null,Object? economyFee = null,Object? minimumFee = null,}) {
  return _then(_self.copyWith(
fastestFee: null == fastestFee ? _self.fastestFee : fastestFee // ignore: cast_nullable_to_non_nullable
as int,halfHourFee: null == halfHourFee ? _self.halfHourFee : halfHourFee // ignore: cast_nullable_to_non_nullable
as int,hourFee: null == hourFee ? _self.hourFee : hourFee // ignore: cast_nullable_to_non_nullable
as int,economyFee: null == economyFee ? _self.economyFee : economyFee // ignore: cast_nullable_to_non_nullable
as int,minimumFee: null == minimumFee ? _self.minimumFee : minimumFee // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Fees].
extension FeesPatterns on Fees {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Fees value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Fees() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Fees value)  $default,){
final _that = this;
switch (_that) {
case _Fees():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Fees value)?  $default,){
final _that = this;
switch (_that) {
case _Fees() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int fastestFee,  int halfHourFee,  int hourFee,  int economyFee,  int minimumFee)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Fees() when $default != null:
return $default(_that.fastestFee,_that.halfHourFee,_that.hourFee,_that.economyFee,_that.minimumFee);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int fastestFee,  int halfHourFee,  int hourFee,  int economyFee,  int minimumFee)  $default,) {final _that = this;
switch (_that) {
case _Fees():
return $default(_that.fastestFee,_that.halfHourFee,_that.hourFee,_that.economyFee,_that.minimumFee);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int fastestFee,  int halfHourFee,  int hourFee,  int economyFee,  int minimumFee)?  $default,) {final _that = this;
switch (_that) {
case _Fees() when $default != null:
return $default(_that.fastestFee,_that.halfHourFee,_that.hourFee,_that.economyFee,_that.minimumFee);case _:
  return null;

}
}

}

/// @nodoc


class _Fees extends Fees {
  const _Fees({required this.fastestFee, required this.halfHourFee, required this.hourFee, required this.economyFee, required this.minimumFee}): super._();
  

@override final  int fastestFee;
@override final  int halfHourFee;
@override final  int hourFee;
@override final  int economyFee;
@override final  int minimumFee;

/// Create a copy of Fees
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeesCopyWith<_Fees> get copyWith => __$FeesCopyWithImpl<_Fees>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Fees&&(identical(other.fastestFee, fastestFee) || other.fastestFee == fastestFee)&&(identical(other.halfHourFee, halfHourFee) || other.halfHourFee == halfHourFee)&&(identical(other.hourFee, hourFee) || other.hourFee == hourFee)&&(identical(other.economyFee, economyFee) || other.economyFee == economyFee)&&(identical(other.minimumFee, minimumFee) || other.minimumFee == minimumFee));
}


@override
int get hashCode => Object.hash(runtimeType,fastestFee,halfHourFee,hourFee,economyFee,minimumFee);

@override
String toString() {
  return 'Fees(fastestFee: $fastestFee, halfHourFee: $halfHourFee, hourFee: $hourFee, economyFee: $economyFee, minimumFee: $minimumFee)';
}


}

/// @nodoc
abstract mixin class _$FeesCopyWith<$Res> implements $FeesCopyWith<$Res> {
  factory _$FeesCopyWith(_Fees value, $Res Function(_Fees) _then) = __$FeesCopyWithImpl;
@override @useResult
$Res call({
 int fastestFee, int halfHourFee, int hourFee, int economyFee, int minimumFee
});




}
/// @nodoc
class __$FeesCopyWithImpl<$Res>
    implements _$FeesCopyWith<$Res> {
  __$FeesCopyWithImpl(this._self, this._then);

  final _Fees _self;
  final $Res Function(_Fees) _then;

/// Create a copy of Fees
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fastestFee = null,Object? halfHourFee = null,Object? hourFee = null,Object? economyFee = null,Object? minimumFee = null,}) {
  return _then(_Fees(
fastestFee: null == fastestFee ? _self.fastestFee : fastestFee // ignore: cast_nullable_to_non_nullable
as int,halfHourFee: null == halfHourFee ? _self.halfHourFee : halfHourFee // ignore: cast_nullable_to_non_nullable
as int,hourFee: null == hourFee ? _self.hourFee : hourFee // ignore: cast_nullable_to_non_nullable
as int,economyFee: null == economyFee ? _self.economyFee : economyFee // ignore: cast_nullable_to_non_nullable
as int,minimumFee: null == minimumFee ? _self.minimumFee : minimumFee // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
