// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SubscriptionState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isPurchasing => throw _privateConstructorUsedError;
  String get currentPrice => throw _privateConstructorUsedError;
  String get originalPrice => throw _privateConstructorUsedError;
  String get subscriptionPeriod => throw _privateConstructorUsedError;
  String get subscriptionName => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  VoidCallback? get onSuccess => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionStateCopyWith<SubscriptionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionStateCopyWith<$Res> {
  factory $SubscriptionStateCopyWith(
          SubscriptionState value, $Res Function(SubscriptionState) then) =
      _$SubscriptionStateCopyWithImpl<$Res, SubscriptionState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isPurchasing,
      String currentPrice,
      String originalPrice,
      String subscriptionPeriod,
      String subscriptionName,
      String? error,
      VoidCallback? onSuccess});
}

/// @nodoc
class _$SubscriptionStateCopyWithImpl<$Res, $Val extends SubscriptionState>
    implements $SubscriptionStateCopyWith<$Res> {
  _$SubscriptionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isPurchasing = null,
    Object? currentPrice = null,
    Object? originalPrice = null,
    Object? subscriptionPeriod = null,
    Object? subscriptionName = null,
    Object? error = freezed,
    Object? onSuccess = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isPurchasing: null == isPurchasing
          ? _value.isPurchasing
          : isPurchasing // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPrice: null == currentPrice
          ? _value.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as String,
      originalPrice: null == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as String,
      subscriptionPeriod: null == subscriptionPeriod
          ? _value.subscriptionPeriod
          : subscriptionPeriod // ignore: cast_nullable_to_non_nullable
              as String,
      subscriptionName: null == subscriptionName
          ? _value.subscriptionName
          : subscriptionName // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      onSuccess: freezed == onSuccess
          ? _value.onSuccess
          : onSuccess // ignore: cast_nullable_to_non_nullable
              as VoidCallback?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionStateImplCopyWith<$Res>
    implements $SubscriptionStateCopyWith<$Res> {
  factory _$$SubscriptionStateImplCopyWith(_$SubscriptionStateImpl value,
          $Res Function(_$SubscriptionStateImpl) then) =
      __$$SubscriptionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isPurchasing,
      String currentPrice,
      String originalPrice,
      String subscriptionPeriod,
      String subscriptionName,
      String? error,
      VoidCallback? onSuccess});
}

/// @nodoc
class __$$SubscriptionStateImplCopyWithImpl<$Res>
    extends _$SubscriptionStateCopyWithImpl<$Res, _$SubscriptionStateImpl>
    implements _$$SubscriptionStateImplCopyWith<$Res> {
  __$$SubscriptionStateImplCopyWithImpl(_$SubscriptionStateImpl _value,
      $Res Function(_$SubscriptionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isPurchasing = null,
    Object? currentPrice = null,
    Object? originalPrice = null,
    Object? subscriptionPeriod = null,
    Object? subscriptionName = null,
    Object? error = freezed,
    Object? onSuccess = freezed,
  }) {
    return _then(_$SubscriptionStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isPurchasing: null == isPurchasing
          ? _value.isPurchasing
          : isPurchasing // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPrice: null == currentPrice
          ? _value.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as String,
      originalPrice: null == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as String,
      subscriptionPeriod: null == subscriptionPeriod
          ? _value.subscriptionPeriod
          : subscriptionPeriod // ignore: cast_nullable_to_non_nullable
              as String,
      subscriptionName: null == subscriptionName
          ? _value.subscriptionName
          : subscriptionName // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      onSuccess: freezed == onSuccess
          ? _value.onSuccess
          : onSuccess // ignore: cast_nullable_to_non_nullable
              as VoidCallback?,
    ));
  }
}

/// @nodoc

class _$SubscriptionStateImpl implements _SubscriptionState {
  const _$SubscriptionStateImpl(
      {this.isLoading = false,
      this.isPurchasing = false,
      this.currentPrice = '',
      this.originalPrice = '',
      this.subscriptionPeriod = '1 месяц обучения',
      this.subscriptionName = 'Brand Online KZ',
      this.error,
      this.onSuccess});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isPurchasing;
  @override
  @JsonKey()
  final String currentPrice;
  @override
  @JsonKey()
  final String originalPrice;
  @override
  @JsonKey()
  final String subscriptionPeriod;
  @override
  @JsonKey()
  final String subscriptionName;
  @override
  final String? error;
  @override
  final VoidCallback? onSuccess;

  @override
  String toString() {
    return 'SubscriptionState(isLoading: $isLoading, isPurchasing: $isPurchasing, currentPrice: $currentPrice, originalPrice: $originalPrice, subscriptionPeriod: $subscriptionPeriod, subscriptionName: $subscriptionName, error: $error, onSuccess: $onSuccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isPurchasing, isPurchasing) ||
                other.isPurchasing == isPurchasing) &&
            (identical(other.currentPrice, currentPrice) ||
                other.currentPrice == currentPrice) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.subscriptionPeriod, subscriptionPeriod) ||
                other.subscriptionPeriod == subscriptionPeriod) &&
            (identical(other.subscriptionName, subscriptionName) ||
                other.subscriptionName == subscriptionName) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.onSuccess, onSuccess) ||
                other.onSuccess == onSuccess));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isPurchasing,
      currentPrice,
      originalPrice,
      subscriptionPeriod,
      subscriptionName,
      error,
      onSuccess);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionStateImplCopyWith<_$SubscriptionStateImpl> get copyWith =>
      __$$SubscriptionStateImplCopyWithImpl<_$SubscriptionStateImpl>(
          this, _$identity);
}

abstract class _SubscriptionState implements SubscriptionState {
  const factory _SubscriptionState(
      {final bool isLoading,
      final bool isPurchasing,
      final String currentPrice,
      final String originalPrice,
      final String subscriptionPeriod,
      final String subscriptionName,
      final String? error,
      final VoidCallback? onSuccess}) = _$SubscriptionStateImpl;

  @override
  bool get isLoading;
  @override
  bool get isPurchasing;
  @override
  String get currentPrice;
  @override
  String get originalPrice;
  @override
  String get subscriptionPeriod;
  @override
  String get subscriptionName;
  @override
  String? get error;
  @override
  VoidCallback? get onSuccess;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionStateImplCopyWith<_$SubscriptionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SubscriptionEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function() purchaseSubscription,
    required TResult Function() openPrivacyPolicy,
    required TResult Function() clearError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function()? purchaseSubscription,
    TResult? Function()? openPrivacyPolicy,
    TResult? Function()? clearError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function()? purchaseSubscription,
    TResult Function()? openPrivacyPolicy,
    TResult Function()? clearError,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InitSubscription value) init,
    required TResult Function(PurchaseSubscription value) purchaseSubscription,
    required TResult Function(OpenPrivacyPolicy value) openPrivacyPolicy,
    required TResult Function(ClearError value) clearError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InitSubscription value)? init,
    TResult? Function(PurchaseSubscription value)? purchaseSubscription,
    TResult? Function(OpenPrivacyPolicy value)? openPrivacyPolicy,
    TResult? Function(ClearError value)? clearError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InitSubscription value)? init,
    TResult Function(PurchaseSubscription value)? purchaseSubscription,
    TResult Function(OpenPrivacyPolicy value)? openPrivacyPolicy,
    TResult Function(ClearError value)? clearError,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionEventCopyWith<$Res> {
  factory $SubscriptionEventCopyWith(
          SubscriptionEvent value, $Res Function(SubscriptionEvent) then) =
      _$SubscriptionEventCopyWithImpl<$Res, SubscriptionEvent>;
}

/// @nodoc
class _$SubscriptionEventCopyWithImpl<$Res, $Val extends SubscriptionEvent>
    implements $SubscriptionEventCopyWith<$Res> {
  _$SubscriptionEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitSubscriptionImplCopyWith<$Res> {
  factory _$$InitSubscriptionImplCopyWith(_$InitSubscriptionImpl value,
          $Res Function(_$InitSubscriptionImpl) then) =
      __$$InitSubscriptionImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitSubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionEventCopyWithImpl<$Res, _$InitSubscriptionImpl>
    implements _$$InitSubscriptionImplCopyWith<$Res> {
  __$$InitSubscriptionImplCopyWithImpl(_$InitSubscriptionImpl _value,
      $Res Function(_$InitSubscriptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitSubscriptionImpl implements InitSubscription {
  const _$InitSubscriptionImpl();

  @override
  String toString() {
    return 'SubscriptionEvent.init()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitSubscriptionImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function() purchaseSubscription,
    required TResult Function() openPrivacyPolicy,
    required TResult Function() clearError,
  }) {
    return init();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function()? purchaseSubscription,
    TResult? Function()? openPrivacyPolicy,
    TResult? Function()? clearError,
  }) {
    return init?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function()? purchaseSubscription,
    TResult Function()? openPrivacyPolicy,
    TResult Function()? clearError,
    required TResult orElse(),
  }) {
    if (init != null) {
      return init();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InitSubscription value) init,
    required TResult Function(PurchaseSubscription value) purchaseSubscription,
    required TResult Function(OpenPrivacyPolicy value) openPrivacyPolicy,
    required TResult Function(ClearError value) clearError,
  }) {
    return init(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InitSubscription value)? init,
    TResult? Function(PurchaseSubscription value)? purchaseSubscription,
    TResult? Function(OpenPrivacyPolicy value)? openPrivacyPolicy,
    TResult? Function(ClearError value)? clearError,
  }) {
    return init?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InitSubscription value)? init,
    TResult Function(PurchaseSubscription value)? purchaseSubscription,
    TResult Function(OpenPrivacyPolicy value)? openPrivacyPolicy,
    TResult Function(ClearError value)? clearError,
    required TResult orElse(),
  }) {
    if (init != null) {
      return init(this);
    }
    return orElse();
  }
}

abstract class InitSubscription implements SubscriptionEvent {
  const factory InitSubscription() = _$InitSubscriptionImpl;
}

/// @nodoc
abstract class _$$PurchaseSubscriptionImplCopyWith<$Res> {
  factory _$$PurchaseSubscriptionImplCopyWith(_$PurchaseSubscriptionImpl value,
          $Res Function(_$PurchaseSubscriptionImpl) then) =
      __$$PurchaseSubscriptionImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PurchaseSubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionEventCopyWithImpl<$Res, _$PurchaseSubscriptionImpl>
    implements _$$PurchaseSubscriptionImplCopyWith<$Res> {
  __$$PurchaseSubscriptionImplCopyWithImpl(_$PurchaseSubscriptionImpl _value,
      $Res Function(_$PurchaseSubscriptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PurchaseSubscriptionImpl implements PurchaseSubscription {
  const _$PurchaseSubscriptionImpl();

  @override
  String toString() {
    return 'SubscriptionEvent.purchaseSubscription()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseSubscriptionImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function() purchaseSubscription,
    required TResult Function() openPrivacyPolicy,
    required TResult Function() clearError,
  }) {
    return purchaseSubscription();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function()? purchaseSubscription,
    TResult? Function()? openPrivacyPolicy,
    TResult? Function()? clearError,
  }) {
    return purchaseSubscription?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function()? purchaseSubscription,
    TResult Function()? openPrivacyPolicy,
    TResult Function()? clearError,
    required TResult orElse(),
  }) {
    if (purchaseSubscription != null) {
      return purchaseSubscription();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InitSubscription value) init,
    required TResult Function(PurchaseSubscription value) purchaseSubscription,
    required TResult Function(OpenPrivacyPolicy value) openPrivacyPolicy,
    required TResult Function(ClearError value) clearError,
  }) {
    return purchaseSubscription(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InitSubscription value)? init,
    TResult? Function(PurchaseSubscription value)? purchaseSubscription,
    TResult? Function(OpenPrivacyPolicy value)? openPrivacyPolicy,
    TResult? Function(ClearError value)? clearError,
  }) {
    return purchaseSubscription?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InitSubscription value)? init,
    TResult Function(PurchaseSubscription value)? purchaseSubscription,
    TResult Function(OpenPrivacyPolicy value)? openPrivacyPolicy,
    TResult Function(ClearError value)? clearError,
    required TResult orElse(),
  }) {
    if (purchaseSubscription != null) {
      return purchaseSubscription(this);
    }
    return orElse();
  }
}

abstract class PurchaseSubscription implements SubscriptionEvent {
  const factory PurchaseSubscription() = _$PurchaseSubscriptionImpl;
}

/// @nodoc
abstract class _$$OpenPrivacyPolicyImplCopyWith<$Res> {
  factory _$$OpenPrivacyPolicyImplCopyWith(_$OpenPrivacyPolicyImpl value,
          $Res Function(_$OpenPrivacyPolicyImpl) then) =
      __$$OpenPrivacyPolicyImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$OpenPrivacyPolicyImplCopyWithImpl<$Res>
    extends _$SubscriptionEventCopyWithImpl<$Res, _$OpenPrivacyPolicyImpl>
    implements _$$OpenPrivacyPolicyImplCopyWith<$Res> {
  __$$OpenPrivacyPolicyImplCopyWithImpl(_$OpenPrivacyPolicyImpl _value,
      $Res Function(_$OpenPrivacyPolicyImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$OpenPrivacyPolicyImpl implements OpenPrivacyPolicy {
  const _$OpenPrivacyPolicyImpl();

  @override
  String toString() {
    return 'SubscriptionEvent.openPrivacyPolicy()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$OpenPrivacyPolicyImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function() purchaseSubscription,
    required TResult Function() openPrivacyPolicy,
    required TResult Function() clearError,
  }) {
    return openPrivacyPolicy();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function()? purchaseSubscription,
    TResult? Function()? openPrivacyPolicy,
    TResult? Function()? clearError,
  }) {
    return openPrivacyPolicy?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function()? purchaseSubscription,
    TResult Function()? openPrivacyPolicy,
    TResult Function()? clearError,
    required TResult orElse(),
  }) {
    if (openPrivacyPolicy != null) {
      return openPrivacyPolicy();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InitSubscription value) init,
    required TResult Function(PurchaseSubscription value) purchaseSubscription,
    required TResult Function(OpenPrivacyPolicy value) openPrivacyPolicy,
    required TResult Function(ClearError value) clearError,
  }) {
    return openPrivacyPolicy(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InitSubscription value)? init,
    TResult? Function(PurchaseSubscription value)? purchaseSubscription,
    TResult? Function(OpenPrivacyPolicy value)? openPrivacyPolicy,
    TResult? Function(ClearError value)? clearError,
  }) {
    return openPrivacyPolicy?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InitSubscription value)? init,
    TResult Function(PurchaseSubscription value)? purchaseSubscription,
    TResult Function(OpenPrivacyPolicy value)? openPrivacyPolicy,
    TResult Function(ClearError value)? clearError,
    required TResult orElse(),
  }) {
    if (openPrivacyPolicy != null) {
      return openPrivacyPolicy(this);
    }
    return orElse();
  }
}

abstract class OpenPrivacyPolicy implements SubscriptionEvent {
  const factory OpenPrivacyPolicy() = _$OpenPrivacyPolicyImpl;
}

/// @nodoc
abstract class _$$ClearErrorImplCopyWith<$Res> {
  factory _$$ClearErrorImplCopyWith(
          _$ClearErrorImpl value, $Res Function(_$ClearErrorImpl) then) =
      __$$ClearErrorImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ClearErrorImplCopyWithImpl<$Res>
    extends _$SubscriptionEventCopyWithImpl<$Res, _$ClearErrorImpl>
    implements _$$ClearErrorImplCopyWith<$Res> {
  __$$ClearErrorImplCopyWithImpl(
      _$ClearErrorImpl _value, $Res Function(_$ClearErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ClearErrorImpl implements ClearError {
  const _$ClearErrorImpl();

  @override
  String toString() {
    return 'SubscriptionEvent.clearError()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ClearErrorImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function() purchaseSubscription,
    required TResult Function() openPrivacyPolicy,
    required TResult Function() clearError,
  }) {
    return clearError();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function()? purchaseSubscription,
    TResult? Function()? openPrivacyPolicy,
    TResult? Function()? clearError,
  }) {
    return clearError?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function()? purchaseSubscription,
    TResult Function()? openPrivacyPolicy,
    TResult Function()? clearError,
    required TResult orElse(),
  }) {
    if (clearError != null) {
      return clearError();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InitSubscription value) init,
    required TResult Function(PurchaseSubscription value) purchaseSubscription,
    required TResult Function(OpenPrivacyPolicy value) openPrivacyPolicy,
    required TResult Function(ClearError value) clearError,
  }) {
    return clearError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InitSubscription value)? init,
    TResult? Function(PurchaseSubscription value)? purchaseSubscription,
    TResult? Function(OpenPrivacyPolicy value)? openPrivacyPolicy,
    TResult? Function(ClearError value)? clearError,
  }) {
    return clearError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InitSubscription value)? init,
    TResult Function(PurchaseSubscription value)? purchaseSubscription,
    TResult Function(OpenPrivacyPolicy value)? openPrivacyPolicy,
    TResult Function(ClearError value)? clearError,
    required TResult orElse(),
  }) {
    if (clearError != null) {
      return clearError(this);
    }
    return orElse();
  }
}

abstract class ClearError implements SubscriptionEvent {
  const factory ClearError() = _$ClearErrorImpl;
}
