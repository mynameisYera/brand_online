# RevenueCat Setup Guide / Руководство по настройке RevenueCat

## Проблема: CONFIGURATION_ERROR

Если вы видите ошибку:
```
CONFIGURATION_ERROR: None of the products registered in the RevenueCat dashboard could be fetched from App Store Connect
```

Это означает, что RevenueCat не может найти продукты в App Store Connect или StoreKit Configuration file.

## Решения / Solutions

### Вариант 1: Использование StoreKit Configuration File (для тестирования)

**Для локального тестирования без настройки App Store Connect:**

1. **Создайте StoreKit Configuration File в Xcode:**
   - Откройте проект в Xcode: `ios/Runner.xcworkspace`
   - В Xcode: File → New → File
   - Выберите "StoreKit Configuration File"
   - Назовите файл (например: `Products.storekit`)
   - Сохраните в папку `ios/Runner/`

2. **Настройте продукты в StoreKit Configuration File:**
   - В Xcode откройте созданный `.storekit` файл
   - Добавьте подписку с ID: `restart_month`
   - Установите тип: Subscription
   - Настройте цену (например: 42000₸)

3. **Настройте проект для использования StoreKit Configuration:**
   - В Xcode выберите схему Runner
   - Product → Scheme → Edit Scheme
   - Run → Options
   - В разделе "StoreKit Configuration" выберите ваш `.storekit` файл

4. **Проверьте настройки в RevenueCat Dashboard:**
   - Убедитесь, что Product ID в RevenueCat соответствует: `restart_month`
   - Убедитесь, что Entitlement ID: `restart-online`
   - Убедитесь, что Offering ID: `restart-offering`

### Вариант 2: Настройка через App Store Connect (для продакшена)

1. **Создайте продукт в App Store Connect:**
   - Войдите в [App Store Connect](https://appstoreconnect.apple.com)
   - Перейдите в раздел "My Apps" → Ваше приложение → "In-App Purchases"
   - Нажмите "+" для создания нового продукта
   - Выберите тип: Auto-Renewable Subscription
   - Product ID: `restart_month`
   - Настройте цену и описание

2. **Дождитесь статуса "Ready to Submit":**
   - Продукты в App Store Connect могут обрабатываться до 24 часов

3. **Настройте RevenueCat Dashboard:**
   - Войдите в [RevenueCat Dashboard](https://app.revenuecat.com)
   - Перейдите в Products → Products
   - Добавьте продукт с ID: `restart_month`
   - Создайте Entitlement с ID: `restart-online`
   - Создайте Offering с ID: `restart-offering`
   - Свяжите продукт с entitlement в offering

4. **Проверьте Bundle ID:**
   - Убедитесь, что Bundle ID в Xcode совпадает с Bundle ID в App Store Connect
   - Проверьте, что Bundle ID совпадает в RevenueCat настройках

### Вариант 3: Тестирование на симуляторе без StoreKit Configuration

Если вы тестируете на симуляторе, вам обязательно нужен StoreKit Configuration file, так как симулятор не может подключиться к реальному App Store.

## Проверка текущих настроек / Checking Current Settings

В файле `lib/pursache/purchase_config.dart` установлены следующие ID:

```dart
subscriptionId = 'restart_month'      // Product ID
entitlementId = 'restart-online'      // Entitlement ID  
offeringId = 'restart-offering'       // Offering ID
```

Эти ID должны совпадать в:
- ✅ App Store Connect (Product ID)
- ✅ RevenueCat Dashboard (Product ID, Entitlement ID, Offering ID)
- ✅ StoreKit Configuration File (для тестирования)

## Полезные ссылки / Useful Links

- [RevenueCat Documentation](https://docs.revenuecat.com/docs/getting-started)
- [RevenueCat - Why are offerings empty?](https://rev.cat/why-are-offerings-empty)
- [Apple StoreKit Testing Guide](https://developer.apple.com/documentation/storekit/testing_in_app_purchases_with_sandbox)

## Отладка / Debugging

Если ошибка продолжается:

1. Проверьте логи в Xcode Console
2. Убедитесь, что вы используете правильный API ключ RevenueCat
3. Проверьте, что все ID совпадают во всех местах
4. Для тестирования обязательно используйте StoreKit Configuration file

