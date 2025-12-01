// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
// import 'package:brand_online/roadMap/ui/widget/custom_button_widget.dart';
// // import 'package:url_launcher/url_launcher.dart';

// class NoSubPageIos extends StatefulWidget {
//   final String whatsappUrl;
//   const NoSubPageIos({super.key, required this.whatsappUrl});

//   @override
//   State<NoSubPageIos> createState() => _NoSubPageIosState();
// }

// class _NoSubPageIosState extends State<NoSubPageIos> {
//   final InAppPurchase _iap = InAppPurchase.instance;
//   List<ProductDetails> _products = [];
//   final String productId = 'com.brand.online.month';

//   @override
//   void initState() {
//     super.initState();
//     debugPrint('🚀 initState called');

//     if (Platform.isIOS) {
//       debugPrint('📲 Registering StoreKit platform for iOS');
//       InAppPurchaseStoreKitPlatform.registerPlatform();
//     }

//     debugPrint('🔔 Subscribing to purchase stream');
//     _iap.purchaseStream.listen(_handlePurchaseUpdates);

//     _loadProducts();
//   }

//   Future<void> _loadProducts() async {
//     debugPrint('🛒 Querying product details for: $productId');
//     final response = await _iap.queryProductDetails({productId});

//     if (response.error != null) {
//       debugPrint('❌ Failed to load products: ${response.error!.message}');
//     } else if (response.notFoundIDs.isNotEmpty) {
//       debugPrint('⚠️ Product not found: ${response.notFoundIDs}');
//     } else {
//       debugPrint('✅ Products loaded: ${response.productDetails.length}');
//     }

//     setState(() {
//       _products = response.productDetails.toList();
//     });
//   }

//   void _buy() {
//     debugPrint('🛍️ Buy button pressed');

//     if (_products.isEmpty) {
//       debugPrint('⚠️ No products available to purchase');
//       return;
//     }

//     final product = _products.first;
//     debugPrint('🧾 Initiating purchase for: ${product.id}');
//     final purchaseParam = PurchaseParam(productDetails: product);

//     _iap.buyNonConsumable(purchaseParam: purchaseParam);
//   }

//   void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
//     debugPrint('📦 Handling purchase updates: ${purchases.length} item(s)');

//     for (final purchase in purchases) {
//       debugPrint('🔄 Purchase status: ${purchase.status} for ${purchase.productID}');

//       switch (purchase.status) {
//         case PurchaseStatus.purchased:
//           debugPrint('🎉 Purchase completed successfully');

//           if (purchase is AppStorePurchaseDetails) {
//             final transactionId = purchase.skPaymentTransaction.transactionIdentifier;
//             debugPrint('🧾 iOS Transaction ID: $transactionId');
//           } else if (Platform.isAndroid) {
//             final purchaseToken = purchase.verificationData.serverVerificationData;
//             debugPrint('🔑 Android Purchase Token: $purchaseToken');
//           }

//           if (purchase.pendingCompletePurchase) {
//             debugPrint('✅ Completing pending purchase');
//             _iap.completePurchase(purchase);
//           }
//           break;

//         case PurchaseStatus.error:
//           debugPrint('❌ Purchase error: ${purchase.error?.message}');
//           break;

//         case PurchaseStatus.canceled:
//           debugPrint('⚠️ Purchase cancelled by user');
//           break;

//         default:
//           break;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset('assets/images/admbarys.png', width: 150, height: 150),
//               const SizedBox(height: 10),
//               CustomButtonWidget(
//                 color: Colors.black,
//                 text: "Оплатить ",
//                 textColor: Colors.white,
//                 onTap: _buy,
//               ),
//               SizedBox(height: 10,),
//               Text("Купить месячную подписку")
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
