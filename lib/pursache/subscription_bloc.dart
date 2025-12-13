import 'package:flutter/animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:brand_online/pursache/purchase_config.dart';
import 'package:brand_online/pursache/subscription_service_new.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
part 'subscription_bloc.freezed.dart';

@freezed
class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState({
    @Default(false) bool isLoading,
    @Default(false) bool isPurchasing,
    @Default('') String currentPrice,
    @Default('') String originalPrice,
    @Default('1 месяц обучения') String subscriptionPeriod,
    @Default('Brand Online KZ') String subscriptionName,
    String? error,
    VoidCallback? onSuccess,
  }) = _SubscriptionState;
}

@freezed
class SubscriptionEvent with _$SubscriptionEvent {
  const factory SubscriptionEvent.init() = InitSubscription;
  const factory SubscriptionEvent.purchaseSubscription() = PurchaseSubscription;
  // const factory SubscriptionEvent.restorePurchases() = RestorePurchases;
  const factory SubscriptionEvent.openPrivacyPolicy() = OpenPrivacyPolicy;
  const factory SubscriptionEvent.clearError() = ClearError;
}

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionServiceNew _subscriptionService;

  SubscriptionBloc()
    : _subscriptionService = SubscriptionServiceNew(),
      super(const SubscriptionState()) {
    on<InitSubscription>(_onInitSubscription);
    on<PurchaseSubscription>(_onPurchaseSubscription);
    // on<RestorePurchases>(_onRestorePurchases);
    on<OpenPrivacyPolicy>(_onOpenPrivacyPolicy);
    on<ClearError>(_onClearError);
  }

  Future<void> _onInitSubscription(
    InitSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Check current subscription status
      final customerInfo = await Purchases.getCustomerInfo();

      // Check if user has active subscription
      if (customerInfo.entitlements.active.containsKey(
        PurchasesConfig.entitlementId,
      )) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'У вас уже есть активная подписка Brand Online KZ!',
          ),
        );
        return;
      }

      // Fetch real pricing information from store
      try {
        final offerings = await Purchases.getOfferings();
        final spaceProOffering = offerings.all[PurchasesConfig.offeringId];

        if (spaceProOffering != null &&
            spaceProOffering.availablePackages.isNotEmpty) {
          final monthlyPackage = spaceProOffering.availablePackages.first;
          final storeProduct = monthlyPackage.storeProduct;

          // Format price with currency
          final currentPrice = '${storeProduct.priceString} в месяц';

          // For original price, you might want to show a discounted price
          // This is just an example - adjust based on your pricing strategy
          final originalPrice = '${storeProduct.priceString} в месяц';

          emit(
            state.copyWith(
              isLoading: false,
              currentPrice: currentPrice,
              originalPrice: originalPrice,
            ),
          );
        } else {
          emit(
            state.copyWith(
              isLoading: false,
              currentPrice: '42,000₸ в месяц',
              originalPrice: '42,000₸ в месяц',
            ),
          );
        }
      } catch (e) {
        print('Error fetching pricing: $e');
        emit(
          state.copyWith(
            isLoading: false,
            currentPrice: '42,000₸ в месяц',
            originalPrice: '42,000₸ в месяц',
          ),
        );
      }
    } catch (e) {
      print('Init subscription error: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onPurchaseSubscription(
    PurchaseSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(isPurchasing: true));

    print('Purchasing subscription');

    try {
      // Get the subscription offering
      final offerings = await Purchases.getOfferings();
      print('Available offerings: ${offerings.all.keys}');

      // Try to get the space-pro offering specifically
      final spaceProOffering = offerings.all[PurchasesConfig.offeringId];

      if (spaceProOffering == null) {
        print('No space-pro offering available');
        print('Available offerings: ${offerings.all.keys}');
        throw Exception('Space Pro offering not found');
      }

      print('Found offering: ${spaceProOffering.identifier}');
      print(
        'Available packages: ${spaceProOffering.availablePackages.map((p) => '${p.identifier} (${p.storeProduct.identifier})').toList()}',
      );

      // Find the monthly package (usually the first one or look for monthly type)
      final monthlyPackage =
          spaceProOffering.availablePackages.isNotEmpty
              ? spaceProOffering.availablePackages.first
              : throw Exception('No packages available in Space Pro offering');

      print(
        'Selected package: ${monthlyPackage.identifier} (${monthlyPackage.storeProduct.identifier})',
      );
      // final _storage = FlutterSecureStorage(
      //   aOptions: const AndroidOptions(
      //     encryptedSharedPreferences: true,
      //   ),
      // );

      // Purchase the subscription
      final purchaseResult = await Purchases.purchasePackage(monthlyPackage);

      print('Purchase result: ${purchaseResult.toString()}');

      // String? token = await _storage.read(key: 'auth_token');
      // final accountId = token ?? "";
      // final subscriptionData = await _subscriptionService.extractPurchaseData(
      //   purchaseResult,
      //   monthlyPackage,
      //   accountId,
      // );

      final backendSuccess = await _subscriptionService
          .sendSubscriptionToBackend();

      if (backendSuccess) {
        try {
          final offerings = await Purchases.getOfferings();
          final spaceProOffering = offerings.all[PurchasesConfig.offeringId];

          if (spaceProOffering != null &&
              spaceProOffering.availablePackages.isNotEmpty) {
            final monthlyPackage = spaceProOffering.availablePackages.first;
            final storeProduct = monthlyPackage.storeProduct;

            final currentPrice = '${storeProduct.priceString} в месяц';
            final originalPrice = '${storeProduct.priceString} в месяц';


            emit(
               state.copyWith(
                 isPurchasing: false,
                 currentPrice: currentPrice,
                 originalPrice: originalPrice,
                 error: 'Подписка успешно активирована! Добро пожаловать в Brand Online KZ!',
               ),
             );
          } else {
            emit(state.copyWith(isPurchasing: false));
          }
        } catch (e) {
          print('Error refreshing pricing after purchase: $e');
          emit(state.copyWith(isPurchasing: false));
        }
      } else {
        emit(
          state.copyWith(
            isPurchasing: false,
            error:
                'Покупка завершена, но не удалось сохранить на сервере. Обратитесь в поддержку.',
          ),
        );
      }
    } catch (e) {
      print('Purchase error: $e');
      emit(
        state.copyWith(
          isPurchasing: false,
          error: 'Ошибка при покупке подписки. Попробуйте еще раз.',
        ),
      );
    }
  }

  // Future<void> _onRestorePurchases(
  //   RestorePurchases event,
  //   Emitter<SubscriptionState> emit,
  // ) async {
  //   emit(state.copyWith(isLoading: true));

  //   try {

  //     final _storage = FlutterSecureStorage(
  //       aOptions: const AndroidOptions(
  //         encryptedSharedPreferences: true,
  //       ),
  //     );

  //     String? token = await _storage.read(key: 'auth_token');

  //     final accountId = token ?? "";

  //     // Restore purchases using RevenueCat and send to backend
  //     final restoreSuccess = await _subscriptionService.restorePurchases(
  //       accountId,
  //     );

  //     if (restoreSuccess) {
  //       // Success: refresh pricing and stop loading
  //       try {
  //         final offerings = await Purchases.getOfferings();
  //         final spaceProOffering = offerings.all[PurchasesConfig.offeringId];

  //         if (spaceProOffering != null &&
  //             spaceProOffering.availablePackages.isNotEmpty) {
  //           final monthlyPackage = spaceProOffering.availablePackages.first;
  //           final storeProduct = monthlyPackage.storeProduct;

  //           final currentPrice = '${storeProduct.priceString} в месяц';
  //           final originalPrice = '${storeProduct.priceString} в месяц';

  //           // Get customer info to extract purchase data for backend
  //           // final customerInfo = await Purchases.getCustomerInfo();
            
  //           // Extract purchase data and send to backend
  //           // final subscriptionData = await _subscriptionService.extractPurchaseData(
  //           //   customerInfo,
  //           //   monthlyPackage,
  //           //   accountId,
  //           // );

  //           final backendSuccess = await _subscriptionService
  //               .sendSubscriptionToBackend();

  //           if (backendSuccess) {
  //             emit(
  //               state.copyWith(
  //                 isLoading: false,
  //                 currentPrice: currentPrice,
  //                 originalPrice: originalPrice,
  //                 error: 'Покупки успешно восстановлены! Добро пожаловать обратно в Brand Online KZ!',
  //               ),
  //             );
  //           } else {
  //             emit(
  //               state.copyWith(
  //                 isLoading: false,
  //                 currentPrice: currentPrice,
  //                 originalPrice: originalPrice,
  //                 error: 'Покупки восстановлены, но возникла ошибка при синхронизации с сервером.',
  //               ),
  //             );
  //           }
  //         } else {
  //           emit(state.copyWith(isLoading: false));
  //         }
  //       } catch (e) {
  //         print('Error refreshing pricing after restore: $e');
  //         emit(state.copyWith(isLoading: false));
  //       }
  //     } else {
  //       emit(
  //         state.copyWith(
  //           isLoading: false,
  //           error: 'Покупки не найдены или уже восстановлены.',
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('Restore error: $e');
  //     emit(
  //       state.copyWith(
  //         isLoading: false,
  //         error: 'Ошибка при восстановлении покупок.',
  //       ),
  //     );
  //   }
  // }

  Future<void> _onOpenPrivacyPolicy(
    OpenPrivacyPolicy event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      const String privacyUrl = 'https://www.restartonline.kz/privacy-policy';
      final Uri uri = Uri.parse(privacyUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } else {
        emit(
          state.copyWith(
            error: 'Не удалось открыть политику конфиденциальности',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Ошибка при открытии политики конфиденциальности',
        ),
      );
    }
  }

  void _onClearError(ClearError event, Emitter<SubscriptionState> emit) {
    emit(state.copyWith(error: null));
  }
}
