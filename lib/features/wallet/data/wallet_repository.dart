import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for handling wallet/coupon operations with Supabase
class WalletRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get all coupons for the current user (purchased or received)
  Future<List<Map<String, dynamic>>> getMyCoupons(String userId) async {
    try {
      // Call the SQL function directly
      final List<dynamic> response = await _client.rpc(
        'get_my_coupons_v2',
        params: {'user_uuid': userId},
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch coupons: $e');
    }
  }

  /// Get purchased coupons only (coupons the user bought)
  Future<List<Map<String, dynamic>>> getPurchasedCoupons(String userId) async {
    try {
      // Get all coupons using the working SQL function
      final allCoupons = await getMyCoupons(userId);

      // Filter for coupons where this user is the purchaser
      final purchasedCoupons = allCoupons.where((coupon) =>
        coupon['purchaser_id'] == userId
      ).toList();

      return purchasedCoupons;
    } catch (e) {
      throw Exception('Failed to fetch purchased coupons: $e');
    }
  }

  /// Get received coupons only (coupons shared with the user)
  Future<List<Map<String, dynamic>>> getReceivedCoupons(String userId) async {
    try {
      // Get all coupons using the working SQL function
      final allCoupons = await getMyCoupons(userId);

      // Filter for coupons where this user is the recipient
      final receivedCoupons = allCoupons.where((coupon) =>
        coupon['recipient_id'] == userId
      ).toList();

      return receivedCoupons;
    } catch (e) {
      throw Exception('Failed to fetch received coupons: $e');
    }
  }

  /// Get coupon by ID with full details
  Future<Map<String, dynamic>?> getCouponById(String couponId) async {
    print('🔍 SQL DEBUG: getCouponById() called');
    print('   📝 couponId: $couponId');

    try {
      print('   🚀 Executing query: SELECT coupon by ID');
      print('   📊 Table: coupons');
      print('   🔗 Joins: profiles!purchaser_id(username), profiles!recipient_id(username), menu_items(name, price_in_cents, bars(name))');
      print('   🎯 Filter: id.eq.$couponId');

      final response = await _client
          .from('coupons')
          .select('id, status, purchaser_id, recipient_id, recipient_email, amount, created_at, qr_secret, profiles!purchaser_id(username), profiles!recipient_id(username), menu_items(name, price_in_cents, bars(name))')
          .eq('id', couponId)
          .single();

      print('   ✅ Query successful - Response type: ${response.runtimeType}');

      final result = response as Map<String, dynamic>;
      print('   🎉 getCouponById() completed successfully');
      return result;
    } on PostgrestException catch (e) {
      print('   ❌ PostgrestException in getCouponById():');
      print('      Code: ${e.code}');
      print('      Message: ${e.message}');
      print('      Details: ${e.details}');
      print('      Hint: ${e.hint}');

      if (e.code == 'PGRST116') {
        print('   🚫 No rows found for couponId: $couponId');
        return null;
      }
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('   💥 General exception in getCouponById(): $e');
      throw Exception('Failed to fetch coupon: $e');
    }
  }

  /// Update coupon status (e.g., mark as redeemed)
  Future<void> updateCouponStatus({
    required String couponId,
    required String status,
  }) async {
    print('🔍 SQL DEBUG: updateCouponStatus() called');
    print('   📝 couponId: $couponId');
    print('   📝 status: $status');

    try {
      print('   🚀 Executing UPDATE query');
      print('   📊 Table: coupons');
      print('   📝 SET: status = $status');
      print('   🎯 WHERE: id = $couponId');

      final response = await _client
          .from('coupons')
          .update({
            'status': status,
          })
          .eq('id', couponId)
          .select();

      print('   ✅ UPDATE successful');
      print('   📈 Response: ${response.toString()}');
      print('   🎉 updateCouponStatus() completed successfully');

    } on PostgrestException catch (e) {
      print('   ❌ PostgrestException in updateCouponStatus():');
      print('      Code: ${e.code}');
      print('      Message: ${e.message}');
      print('      Details: ${e.details}');
      print('      Hint: ${e.hint}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('   💥 General exception in updateCouponStatus(): $e');
      throw Exception('Failed to update coupon status: $e');
    }
  }

  /// Share a coupon with another user by username
  Future<void> shareCoupon({
    required String couponId,
    required String recipientEmail, // Note: This is actually a username now
  }) async {
    print('🔄 Starting coupon sharing process...');
    print('   👤 Recipient username: $recipientEmail');
    print('   🎫 Coupon ID: $couponId');

    try {
      // First, verify the coupon exists and get its current state
      print('🔍 Step 1: Checking coupon exists and current state...');
      final existingCoupon = await _client
          .from('coupons')
          .select('id, status, purchaser_id, recipient_id, amount')
          .eq('id', couponId)
          .single();

      print('   ✅ Coupon found: ${existingCoupon.toString()}');

      // Check if coupon is in shareable state
      final currentStatus = existingCoupon['status'] as String?;
      print('   📊 Current coupon status: $currentStatus');

      if (currentStatus != 'purchased') {
        throw Exception('Coupon cannot be shared - current status: $currentStatus (must be "purchased")');
      }

      // Try to get the recipient user ID by username
      print('🔍 Step 2: Looking up recipient user by username...');

      String? recipientId;
      Map<String, dynamic> updateData;

      try {
        final userResponse = await _client
            .from('profiles')
            .select('id, username')
            .eq('username', recipientEmail)
            .single();

        print('   ✅ User found: ${userResponse.toString()}');
        recipientId = userResponse['id'] as String;
        print('   👤 Recipient ID: $recipientId');

        // Check if trying to share with self
        final purchaserId = existingCoupon['purchaser_id'] as String?;
        if (purchaserId == recipientId) {
          throw Exception('Cannot share coupon with yourself');
        }

        // User exists - use recipient_id
        updateData = {
          'recipient_id': recipientId,
          'recipient_email': null, // Clear email since user exists
          'status': 'shared',
        };

      } catch (e) {
        if (e is PostgrestException && e.code == 'PGRST116') {
          // User not found - create invite with recipient_email
          print('   🚫 User not found in profiles table, creating invite...');
          updateData = {
            'recipient_id': null, // No user ID since they don't exist
            'recipient_email': recipientEmail, // Store email for invite
            'status': 'shared', // Still mark as shared (invite pending)
          };
        } else {
          // Some other error occurred
          rethrow;
        }
      }

      // Update the coupon in the database
      print('🔍 Step 3: Updating coupon in database...');
      print('   📝 Update data: ${updateData.toString()}');

      final updateResponse = await _client
          .from('coupons')
          .update(updateData)
          .eq('id', couponId)
          .select('id, status, recipient_id, recipient_email');

      print('   ✅ Update response: ${updateResponse.toString()}');

      // Verify the update was successful
      print('🔍 Step 4: Verifying update was successful...');
      final updatedCoupon = await _client
          .from('coupons')
          .select('id, status, purchaser_id, recipient_id, recipient_email')
          .eq('id', couponId)
          .single();

      print('   ✅ Updated coupon: ${updatedCoupon.toString()}');

      if (recipientId != null) {
        print('🎉 Coupon sharing completed successfully to existing user!');
      } else {
        print('📧 Coupon invite created successfully for email: $recipientEmail');
      }

    } on PostgrestException catch (e) {
      print('❌ Database error during sharing:');
      print('   Error code: ${e.code}');
      print('   Error message: ${e.message}');
      print('   Error details: ${e.details}');
      print('   Error hint: ${e.hint}');

      throw Exception('Database error: ${e.message} (Code: ${e.code})');
    } catch (e) {
      print('❌ General error during sharing: $e');
      throw Exception('Failed to share coupon: $e');
    }
  }

  /// Get total value of user's coupons
  Future<double> getTotalCouponValue(String userId) async {
    try {
      final coupons = await getMyCoupons(userId);

      double totalValue = 0.0;
      for (final coupon in coupons) {
        if (coupon['status'] == 'purchased' || coupon['status'] == 'shared') {
          final amount = coupon['amount'] as int;
          totalValue += amount / 100.0;
        }
      }

      return totalValue;
    } catch (e) {
      throw Exception('Failed to calculate total coupon value: $e');
    }
  }

  /// Get coupons by status
  Future<List<Map<String, dynamic>>> getCouponsByStatus({
    required String userId,
    required String status,
  }) async {
    print('🔍 SQL DEBUG: getCouponsByStatus() called');
    print('   📝 userId: $userId');
    print('   📝 requested status: $status');

    try {
      // Get all coupons using the working SQL function
      print('   🚀 Getting all coupons first...');
      final allCoupons = await getMyCoupons(userId);
      print('   📊 Total coupons found: ${allCoupons.length}');

      // Debug: Show all coupon statuses
      print('   🔍 All coupon statuses:');
      for (int i = 0; i < allCoupons.length; i++) {
        final coupon = allCoupons[i];
        print('      [$i] ID: ${coupon['id']}, Status: "${coupon['status']}", Drink: ${coupon['drink_name'] ?? 'N/A'}');
      }

      // Filter by status
      print('   🎯 Filtering for status: "$status"');
      final filteredCoupons = allCoupons.where((coupon) {
        final couponStatus = coupon['status'];
        final matches = couponStatus == status;
        print('      Coupon ${coupon['id']}: status="$couponStatus" matches="$matches" (comparing "$couponStatus" == "$status")');
        return matches;
      }).toList();

      print('   ✅ Filtered result: ${filteredCoupons.length} coupons match status "$status"');
      print('   🎉 getCouponsByStatus() completed successfully');

      return filteredCoupons;
    } catch (e) {
      print('   💥 Error in getCouponsByStatus: $e');
      throw Exception('Failed to fetch coupons by status: $e');
    }
  }

  /// Check if user owns or has access to a coupon
  Future<bool> canAccessCoupon(String userId, String couponId) async {
    try {
      final response = await _client
          .from('coupons')
          .select('id')
          .or('purchaser_id.eq.$userId,recipient_id.eq.$userId')
          .eq('id', couponId)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get bar location coordinates by bar ID
  Future<Map<String, double>?> getBarCoordinates(String barId) async {
    print('📍 SQL DEBUG: getBarCoordinates() called');
    print('   📝 barId: $barId');

    try {
      print('   🚀 Executing bar coordinates query');
      print('   📊 Table: bars');
      print('   🔗 Select: location_lat, location_long');
      print('   🎯 Filter: id.eq.$barId');

      final response = await _client
          .from('bars')
          .select('location_lat, location_long')
          .eq('id', barId)
          .single();

      print('   ✅ Query successful - Response: ${response.toString()}');

      final lat = response['location_lat'] as double?;
      final lng = response['location_long'] as double?;

      if (lat != null && lng != null) {
        final coordinates = {'latitude': lat, 'longitude': lng};
        print('   🎉 getBarCoordinates() completed - coordinates: $coordinates');
        return coordinates;
      } else {
        print('   ⚠️ No valid coordinates found');
        return null;
      }
    } on PostgrestException catch (e) {
      print('   ❌ PostgrestException in getBarCoordinates():');
      print('      Code: ${e.code}');
      print('      Message: ${e.message}');
      print('      Details: ${e.details}');
      print('      Hint: ${e.hint}');
      return null;
    } catch (e) {
      print('   💥 General exception in getBarCoordinates(): $e');
      return null;
    }
  }

  /// Debug function to inspect database schema and data
  Future<void> debugDatabaseInfo() async {
    print('🔍 =================DEBUG DATABASE INFO=================');

    try {
      // Check profiles table structure and sample data
      print('🔍 SQL DEBUG: About to query PROFILES table');
      print('   📊 Table: profiles');
      print('   🔗 Select: *');
      print('   📏 Limit: 3');
      print('👥 PROFILES TABLE:');

      final profiles = await _client
          .from('profiles')
          .select('*')
          .limit(3);
      print('   ✅ Profiles query successful');
      print('   Sample profiles: ${profiles.toString()}');

      // Check coupons table structure and sample data
      print('🔍 SQL DEBUG: About to query COUPONS table');
      print('   📊 Table: coupons');
      print('   🔗 Select: id, status, purchaser_id, recipient_id, recipient_email, amount, created_at');
      print('   📏 Limit: 5');
      print('🎫 COUPONS TABLE:');

      final coupons = await _client
          .from('coupons')
          .select('id, status, purchaser_id, recipient_id, recipient_email, amount, created_at')
          .limit(5);
      print('   ✅ Coupons query successful');
      print('   Sample coupons: ${coupons.toString()}');

      // Check for specific columns that might be missing
      print('🔍 SQL DEBUG: About to query test COUPON');
      print('   📊 Table: coupons');
      print('   🔗 Select: id, status, purchaser_id, recipient_id, created_at');
      print('   📏 Limit: 1');
      print('   📝 Method: single()');
      print('🔍 Testing specific coupon queries...');

      final testCoupon = await _client
          .from('coupons')
          .select('id, status, purchaser_id, recipient_id, created_at')
          .limit(1)
          .single();
      print('   ✅ Test coupon query successful');
      print('   Test coupon structure: ${testCoupon.toString()}');

      // Check bars table for location data
      print('🔍 SQL DEBUG: About to query BARS table for location data');
      print('   📊 Table: bars');
      print('   🔗 Select: id, name, location_lat, location_long');
      print('   📏 Limit: 3');
      print('🏢 BARS TABLE:');

      final bars = await _client
          .from('bars')
          .select('id, name, location_lat, location_long')
          .limit(3);
      print('   ✅ Bars query successful');
      print('   Sample bars: ${bars.toString()}');

    } catch (e) {
      print('❌ Error during database inspection: $e');
      if (e is PostgrestException) {
        print('   🔍 PostgrestException details:');
        print('      Code: ${e.code}');
        print('      Message: ${e.message}');
        print('      Details: ${e.details}');
        print('      Hint: ${e.hint}');
      }
    }

    print('🔍 ===============================================');
  }
}