import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final String _subscriptionKey = 'user_subscription_status';
  final String _purchaseDateKey = 'purchase_date';
  
  // Product IDs для разных платформ
  final String monthlyProductId = Platform.isIOS 
      ? 'com.akim.restart.month' 
      : 'com.kanatbek.smart_study_v2';

  bool _isInitialized = false;
  bool _hasActiveSubscription = false;
  DateTime? _purchaseDate;

  bool get hasActiveSubscription => _hasActiveSubscription;
  DateTime? get purchaseDate => _purchaseDate;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Регистрируем StoreKit для iOS
      if (Platform.isIOS) {
        InAppPurchaseStoreKitPlatform.registerPlatform();
      }

      // Загружаем сохраненное состояние подписки
      await _loadSubscriptionStatus();

      // Подписываемся на обновления покупок
      _iap.purchaseStream.listen(_handlePurchaseUpdates);

      _isInitialized = true;
      debugPrint('✅ SubscriptionService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing SubscriptionService: $e');
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasActiveSubscription = prefs.getBool(_subscriptionKey) ?? false;
      
      final purchaseDateString = prefs.getString(_purchaseDateKey);
      if (purchaseDateString != null) {
        _purchaseDate = DateTime.tryParse(purchaseDateString);
      }

      debugPrint('📱 Loaded subscription status: $_hasActiveSubscription');
    } catch (e) {
      debugPrint('❌ Error loading subscription status: $e');
    }
  }

  Future<void> _saveSubscriptionStatus(bool hasSubscription, DateTime? purchaseDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_subscriptionKey, hasSubscription);
      
      if (purchaseDate != null) {
        await prefs.setString(_purchaseDateKey, purchaseDate.toIso8601String());
      } else {
        await prefs.remove(_purchaseDateKey);
      }

      _hasActiveSubscription = hasSubscription;
      _purchaseDate = purchaseDate;

      debugPrint('💾 Saved subscription status: $hasSubscription');
    } catch (e) {
      debugPrint('❌ Error saving subscription status: $e');
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      debugPrint('🔄 Processing purchase: ${purchase.status} for ${purchase.productID}');

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase);
          break;
        case PurchaseStatus.error:
          debugPrint('❌ Purchase error: ${purchase.error?.message}');
          break;
        case PurchaseStatus.canceled:
          debugPrint('⚠️ Purchase cancelled');
          break;
        case PurchaseStatus.pending:
          debugPrint('⏳ Purchase pending');
          break;
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    try {
      // Верифицируем покупку (здесь можно добавить серверную верификацию)
      final isValid = await _verifyPurchase(purchase);
      
      if (isValid) {
        await _saveSubscriptionStatus(true, DateTime.now());
        
        // Завершаем покупку
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        
        debugPrint('✅ Subscription activated successfully');
      } else {
        debugPrint('❌ Purchase verification failed');
      }
    } catch (e) {
      debugPrint('❌ Error handling successful purchase: $e');
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // Базовая верификация - проверяем, что покупка не пустая
    if (purchase.productID != monthlyProductId) {
      debugPrint('❌ Invalid product ID: ${purchase.productID}');
      return false;
    }

    // Здесь можно добавить серверную верификацию
    // Для демонстрации возвращаем true
    return true;
  }

  Future<void> restorePurchases() async {
    try {
      debugPrint('🔄 Restoring purchases...');
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('❌ Error restoring purchases: $e');
    }
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      // Проверяем, не истекла ли подписка
      if (_purchaseDate != null) {
        final now = DateTime.now();
        final difference = now.difference(_purchaseDate!).inDays;
        
        // Предполагаем, что подписка действует 30 дней
        if (difference >= 30) {
          await _saveSubscriptionStatus(false, null);
          debugPrint('⏰ Subscription expired');
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking subscription status: $e');
    }
  }

  Future<void> cancelSubscription() async {
    try {
      await _saveSubscriptionStatus(false, null);
      debugPrint('🚫 Subscription cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling subscription: $e');
    }
  }
}

