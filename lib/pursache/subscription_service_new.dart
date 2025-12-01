import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../general/GeneralUtil.dart';
import 'purchase_config.dart';

class SubscriptionServiceNew {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: GeneralUtil.BASE_URL),
  );
  final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Extract purchase data from CustomerInfo or PurchaseResult
  Future<Map<String, dynamic>> extractPurchaseData(
    dynamic purchaseData,
    Package package,
    String accountId,
  ) async {
    try {
      // Extract transaction identifiers
      String? transactionId;
      String? originalTransactionId;
      String? productId;
      String? purchaseDate;

      if (purchaseData is CustomerInfo) {
        // For restore purchases or purchase result
        final activeEntitlement = purchaseData.entitlements.active[
          PurchasesConfig.entitlementId
        ];
        
        if (activeEntitlement != null) {
          // In RevenueCat SDK, latestPurchaseDate and originalPurchaseDate are Strings
          final latestPurchaseDate = activeEntitlement.latestPurchaseDate;
          final originalPurchaseDate = activeEntitlement.originalPurchaseDate;
          
          // Use dates directly as they're already strings
          if (latestPurchaseDate.isNotEmpty) {
            transactionId = latestPurchaseDate;
            purchaseDate = latestPurchaseDate;
          }
          
          if (originalPurchaseDate.isNotEmpty) {
            originalTransactionId = originalPurchaseDate;
          }
          
          productId = activeEntitlement.productIdentifier;
        }
      }

      return {
        'transaction_id': transactionId ?? '',
        'original_transaction_id': originalTransactionId ?? '',
        'product_id': productId ?? package.storeProduct.identifier,
        'purchase_date': purchaseDate ?? DateTime.now().toIso8601String(),
        'account_id': accountId,
        'platform': 'ios', // You can make this dynamic based on Platform
      };
    } catch (e) {
      print('Error extracting purchase data: $e');
      return {
        'transaction_id': '',
        'original_transaction_id': '',
        'product_id': package.storeProduct.identifier,
        'purchase_date': DateTime.now().toIso8601String(),
        'account_id': accountId,
        'platform': 'ios',
      };
    }
  }

  /// open subscription for one month
  Future<bool> sendSubscriptionToBackend() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      final response = await _dio.post(
        '/edu/permissions/grant-monthly/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Subscription data sent to backend successfully');
        return true;
      } else {
        print('Backend returned status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending subscription to backend: $e');
      return false;
    }
  }

  Future<bool> deleteSubscriptionToBackend() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      final response = await _dio.post(
        '/edu/permissions/finish/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Subscription data sent to backend successfully');
        return true;
      } else {
        print('Backend returned status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending subscription to backend: $e');
      return false;
    }
  }

  /// Restore purchases from RevenueCat
  Future<bool> restorePurchases(String accountId) async {
    try {
      await Purchases.restorePurchases();
      
      // Get customer info after restore
      final customerInfo = await Purchases.getCustomerInfo();
      
      // Check if user has active subscription
      if (customerInfo.entitlements.active.containsKey(PurchasesConfig.entitlementId)) {
        final offerings = await Purchases.getOfferings();
        final offering = offerings.all[PurchasesConfig.offeringId];
        
        if (offering != null && offering.availablePackages.isNotEmpty) {
          
          return await sendSubscriptionToBackend();
        }
      }
      
      return false;
    } catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }

  /// Get user account ID from storage or profile
  Future<String> getAccountId() async {
    try {
      // Try to get user ID from profile data or storage
      // For now, using a combination of token and username
      final token = await _storage.read(key: 'auth_token');
      final username = await _storage.read(key: 'username');
      
      // You might want to get the actual user ID from your profile service
      // For now, using username as account identifier
      return username ?? token ?? 'unknown';
    } catch (e) {
      print('Error getting account ID: $e');
      return 'unknown';
    }
  }
}

