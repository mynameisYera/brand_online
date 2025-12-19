import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io';

class PurchasesConfig {
  static const _androidApiKey = 'PUT_YOUR_ANDROID_API_KEY_HERE';
  static const _iosApiKey = 'appl_tMzEjMtzuHWzkkLKHDGyAxoAwex';
  
  // iOS configuration - these must match your App Store Connect and RevenueCat dashboard
  static const String subscriptionId = 'brand_online'; // Product ID from App Store Connect
  static const String entitlementId = 'brand-online'; // Entitlement ID from RevenueCat dashboard
  static const String offeringId = 'brand_online'; // Offering ID from RevenueCat dashboard
  
  static bool _isInitialized = false;

  /// Platform-based initialization
  static Future<void> init({String? appUserID}) async {
    if (_isInitialized) {
      print('RevenueCat already initialized, skipping...');
      return;
    }
    
    try {
      final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;
      final configuration = PurchasesConfiguration(apiKey);

      if (appUserID != null) {
        configuration.appUserID = appUserID;
      }

      await Purchases.configure(configuration);
      _isInitialized = true;
      
      print('RevenueCat initialized successfully with ${Platform.isIOS ? 'iOS' : 'Android'} API key');

      try {
        final offerings = await Purchases.getOfferings();
        print('Available offerings: ${offerings.all.keys}');
        
        if (offerings.current != null) {
          print('Current offering: ${offerings.current!.identifier}');
          print('Available packages: ${offerings.current!.availablePackages.map((p) => '${p.identifier} (${p.storeProduct.identifier})').toList()}');
        } else {
          print('No current offering available');
          print('All offerings: ${offerings.all.keys}');
        }
      } catch (e) {
        print('Error getting offerings: ${e.toString()}');
      }
    } catch (e) {
      print('Error initializing RevenueCat: $e');
      // Don't throw the error to prevent app crash
      // This might happen during development or if the plugin is not properly set up
    }
  }

  /// Get the offering and entitlement IDs for the subscription
  static (String offeringId, String entitlementId) getOfferIds() {
    return (offeringId, entitlementId);
  }

  /// Get the subscription identifier
  static String getSubscriptionId() {
    return subscriptionId;
  }

  static Future<List<String>> getSubscriptionIds() async {
    try {
      final offerings = await Purchases.getOfferings();
      final availableOffering = offerings.current;

      if (availableOffering == null) return [];

      return availableOffering.availablePackages
          .map((pkg) => pkg.storeProduct.identifier)
          .toList();
    } catch (e) {
      print('Error fetching subscription IDs: $e');
      return [];
    }
  }
}
