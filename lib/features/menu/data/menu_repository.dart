import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/menu_item_model.dart';

/// Repository for handling menu and purchase operations with Supabase
class MenuRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get menu items for a specific bar
  Future<List<MenuItem>> getMenuForBar(String barId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select('id, name, price_in_cents')
          .eq('bar_id', barId)
          .order('name');

      final List<dynamic> data = response as List<dynamic>;

      return data
          .map((itemJson) => MenuItem.fromJson(itemJson as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch menu: $e');
    }
  }

  /// Purchase a drink and create a coupon (DEBUG VERSION)
  Future<void> purchaseDrink(String userId, String drinkId, int price) async {
    final data = {
      'purchaser_id': userId,
      'menu_item_id': drinkId,
      'qr_secret': 'debug_secret',
      'amount': price, // Verify this KEY is exactly 'amount'
    };
    print('DEBUG: Attempting to insert to coupons table: $data');

    try {
      await _client.from('coupons').insert(data);
      print('DEBUG: Success!');
    } catch (e) {
      print('DEBUG: Error is: $e');
      rethrow;
    }
  }

  /// Get a specific menu item by ID
  Future<MenuItem?> getMenuItemById(String itemId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select('id, name, price_in_cents')
          .eq('id', itemId)
          .single();

      return MenuItem.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // No rows found
        return null;
      }
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch menu item: $e');
    }
  }

  /// Get purchase history for a user
  Future<List<Map<String, dynamic>>> getUserPurchases(String userId) async {
    try {
      final response = await _client
          .from('coupons')
          .select('''
            id,
            amount,
            status,
            qr_secret,
            created_at,
            drink_id,
            menu_items!inner(name, price_in_cents)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch purchase history: $e');
    }
  }

  /// Update coupon status (e.g., when redeemed)
  Future<void> updateCouponStatus({
    required String couponId,
    required String status,
  }) async {
    try {
      await _client
          .from('coupons')
          .update({
            'status': status,
          })
          .eq('id', couponId);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update coupon status: $e');
    }
  }

  /// Get coupon by QR secret (for redemption)
  Future<Map<String, dynamic>?> getCouponByQrSecret(String qrSecret) async {
    try {
      final response = await _client
          .from('coupons')
          .select('''
            id,
            user_id,
            drink_id,
            amount,
            status,
            created_at,
            menu_items!inner(name, price_in_cents)
          ''')
          .eq('qr_secret', qrSecret)
          .single();

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // No rows found
        return null;
      }
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch coupon: $e');
    }
  }

  /// Validate if a bar has menu items
  Future<bool> barHasMenu(String barId) async {
    try {
      final response = await _client
          .from('menu_items')
          .select('id')
          .eq('bar_id', barId)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get total spent by user
  Future<double> getTotalSpentByUser(String userId) async {
    try {
      final response = await _client
          .from('coupons')
          .select('amount')
          .eq('user_id', userId);

      final purchases = response as List<dynamic>;
      final totalCents = purchases.fold<int>(
        0,
        (sum, purchase) => sum + (purchase['amount'] as int),
      );

      return totalCents / 100.0;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to calculate total spent: $e');
    }
  }

  /// Generate random QR secret string
  String _generateQrSecret() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final length = 32; // 32 character secret

    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }
}