import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendor_app/core/localization/app_localizations.dart';

void main() {
  group('AppLocalizations Tests', () {
    test('English translations work correctly', () {
      final locEn = AppLocalizations(const Locale('en'));
      expect(locEn.translate('login'), 'Login');
      expect(locEn.translate('dashboard'), 'Dashboard');
      expect(locEn.translate('language'), 'Language');
      expect(locEn.translate('order_management'), 'Order Management');
      expect(locEn.translate('my_products'), 'My Products');
      expect(locEn.translate('alerts'), 'Alerts');
      expect(locEn.translate('alert_inventory_sync_title'), 'Inventory Sync Complete');
      expect(locEn.translate('order_documents_printables'), 'Order Documents & Printables');
      expect(locEn.translate('shipping_label'), 'Shipping Label');
      expect(locEn.translate('inventory_stock_manager'), 'Inventory & Stock Manager');
      expect(locEn.currentLanguageName, 'English');
      expect(locEn.isRTL, false);
    });

    test('Arabic translations work correctly and identify RTL', () {
      final locAr = AppLocalizations(const Locale('ar'));
      expect(locAr.translate('login'), 'تسجيل الدخول');
      expect(locAr.translate('dashboard'), 'لوحة التحكم');
      expect(locAr.translate('language'), 'اللغة');
      expect(locAr.translate('order_management'), 'إدارة الطلبات');
      expect(locAr.translate('my_products'), 'منتجاتي');
      expect(locAr.translate('alerts'), 'التنبيهات');
      expect(locAr.translate('alert_inventory_sync_title'), 'اكتملت مزامنة المخزون');
      expect(locAr.translate('order_documents_printables'), 'مستندات ومطبوعات الطلب');
      expect(locAr.translate('shipping_label'), 'ملصق الشحن');
      expect(locAr.translate('inventory_stock_manager'), 'إدارة المخزون والمستودع');
      expect(locAr.currentLanguageName, 'العربية');
      expect(locAr.isRTL, true);
    });

    test('Hindi translations work correctly', () {
      final locHi = AppLocalizations(const Locale('hi'));
      expect(locHi.translate('login'), 'लॉग इन करें');
      expect(locHi.translate('dashboard'), 'डैशबोर्ड');
      expect(locHi.translate('order_management'), 'ऑर्डर प्रबंधन');
      expect(locHi.translate('my_products'), 'मेरे उत्पाद');
      expect(locHi.translate('alerts'), 'अलर्ट');
      expect(locHi.translate('alert_inventory_sync_title'), 'इन्वेंटरी सिंक पूर्ण');
      expect(locHi.translate('order_documents_printables'), 'ऑर्डर दस्तावेज़ व प्रिंट');
      expect(locHi.translate('shipping_label'), 'शिपिंग लेबल');
      expect(locHi.translate('inventory_stock_manager'), 'इन्वेंटरी और स्टॉक प्रबंधक');
      expect(locHi.currentLanguageName, 'हिंदी');
      expect(locHi.isRTL, false);
    });
  });
}

