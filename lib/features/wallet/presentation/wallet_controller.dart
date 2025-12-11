import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/wallet_repository.dart';

/// Provider for WalletRepository
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

/// FutureProvider for getting all user's coupons
final myCouponsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final repository = ref.read(walletRepositoryProvider);

  // Run database debug info on first load
  await repository.debugDatabaseInfo();

  return await repository.getMyCoupons(userId);
});

/// FutureProvider for getting purchased coupons only
final purchasedCouponsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final repository = ref.read(walletRepositoryProvider);
  return await repository.getPurchasedCoupons(userId);
});

/// FutureProvider for getting received coupons only
final receivedCouponsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final repository = ref.read(walletRepositoryProvider);
  return await repository.getReceivedCoupons(userId);
});

/// FutureProvider for getting coupons by status
final couponsByStatusProvider = FutureProvider.family<List<Map<String, dynamic>>, CouponStatusQuery>((ref, query) async {
  final repository = ref.read(walletRepositoryProvider);
  return await repository.getCouponsByStatus(
    userId: query.userId,
    status: query.status,
  );
});

/// FutureProvider for getting total coupon value
final totalCouponValueProvider = FutureProvider.family<double, String>((ref, userId) async {
  final repository = ref.read(walletRepositoryProvider);
  return await repository.getTotalCouponValue(userId);
});

/// FutureProvider for getting specific coupon by ID
final couponByIdProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, couponId) async {
  final repository = ref.read(walletRepositoryProvider);
  return await repository.getCouponById(couponId);
});

/// StateNotifier for managing wallet actions
class WalletActionsController extends StateNotifier<WalletActionsState> {
  final WalletRepository _repository;

  WalletActionsController(this._repository) : super(const WalletActionsState());

  /// Redeem a coupon (mark as redeemed)
  Future<void> redeemCoupon(String couponId) async {
    print('🎮 Controller: Starting coupon redemption...');
    print('   🎫 Coupon ID: $couponId');

    state = state.copyWith(isLoading: true, error: null);
    print('   ⏳ State set to loading...');

    try {
      print('📞 Controller: Calling repository updateCouponStatus...');
      await _repository.updateCouponStatus(
        couponId: couponId,
        status: 'redeemed',
      );

      print('✅ Controller: Repository call successful, updating state...');
      state = state.copyWith(
        isLoading: false,
        lastAction: 'Coupon redeemed successfully',
      );
      print('🎉 Controller: State updated with success message');
    } catch (e) {
      print('❌ Controller: Error caught during redemption - $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('💥 Controller: State updated with error message');
    }
  }

  /// Share a coupon with another user
  Future<void> shareCoupon({
    required String couponId,
    required String recipientEmail, // Note: This is actually a username now
  }) async {
    print('🎮 Controller: Starting coupon sharing...');
    print('   🎫 Coupon ID: $couponId');
    print('   👤 Recipient Username: $recipientEmail');

    state = state.copyWith(isLoading: true, error: null);
    print('   ⏳ State set to loading...');

    try {
      print('📞 Controller: Calling repository shareCoupon...');
      await _repository.shareCoupon(
        couponId: couponId,
        recipientEmail: recipientEmail,
      );

      print('✅ Controller: Repository call successful, updating state...');
      state = state.copyWith(
        isLoading: false,
        lastAction: 'Coupon shared successfully with $recipientEmail',
      );
      print('🎉 Controller: State updated with success message');
    } catch (e) {
      print('❌ Controller: Error caught - $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('💥 Controller: State updated with error message');
    }
  }

  /// Clear the action state
  void clearState() {
    state = const WalletActionsState();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for wallet actions controller
final walletActionsControllerProvider = StateNotifierProvider<WalletActionsController, WalletActionsState>((ref) {
  final repository = ref.read(walletRepositoryProvider);
  return WalletActionsController(repository);
});

/// State class for wallet actions
class WalletActionsState {
  final bool isLoading;
  final String? error;
  final String? lastAction;

  const WalletActionsState({
    this.isLoading = false,
    this.error,
    this.lastAction,
  });

  WalletActionsState copyWith({
    bool? isLoading,
    String? error,
    String? lastAction,
  }) {
    return WalletActionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastAction: lastAction ?? this.lastAction,
    );
  }

  bool get hasError => error != null;
  bool get hasAction => lastAction != null;
}

/// Data class for coupon status queries
class CouponStatusQuery {
  final String userId;
  final String status;

  const CouponStatusQuery({
    required this.userId,
    required this.status,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CouponStatusQuery &&
        other.userId == userId &&
        other.status == status;
  }

  @override
  int get hashCode {
    return userId.hashCode ^ status.hashCode;
  }
}

/// Helper methods for coupon data
class CouponHelper {
  /// Extract drink name from coupon data
  static String getDrinkName(Map<String, dynamic> coupon) {
    return coupon['drink_name'] as String? ?? 'Unknown Drink';
  }

  /// Extract bar name from coupon data
  static String getBarName(Map<String, dynamic> coupon) {
    return coupon['bar_name'] as String? ?? 'Unknown Bar';
  }

  /// Extract price from coupon data
  static double getPrice(Map<String, dynamic> coupon) {
    final amount = coupon['amount'] as int? ?? 0;
    return amount / 100.0;
  }

  /// Format price display
  static String getFormattedPrice(Map<String, dynamic> coupon) {
    final price = getPrice(coupon);
    return '\$${price.toStringAsFixed(2)}';
  }

  /// Get coupon status display
  static String getStatusDisplay(Map<String, dynamic> coupon) {
    final status = coupon['status'] as String? ?? 'unknown';
    switch (status) {
      case 'purchased':
        return 'Ready to Share';
      case 'shared':
        return 'Shared';
      case 'redeemed':
        return 'Redeemed';
      default:
        return status.toUpperCase();
    }
  }

  /// Check if coupon can be shared
  static bool canShare(Map<String, dynamic> coupon) {
    final status = coupon['status'] as String? ?? '';
    return status == 'purchased';
  }

  /// Check if coupon can be redeemed
  static bool canRedeem(Map<String, dynamic> coupon) {
    final status = coupon['status'] as String? ?? '';
    return status == 'purchased' || status == 'shared';
  }

  /// Get QR secret for display
  static String getQrSecret(Map<String, dynamic> coupon) {
    return coupon['qr_secret'] as String? ?? '';
  }

  /// Get creation date
  static DateTime? getCreatedAt(Map<String, dynamic> coupon) {
    final createdAtString = coupon['created_at'] as String?;
    if (createdAtString != null) {
      return DateTime.tryParse(createdAtString);
    }
    return null;
  }

  /// Format creation date
  static String getFormattedDate(Map<String, dynamic> coupon) {
    final date = getCreatedAt(coupon);
    if (date != null) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'Unknown Date';
  }

  /// Get recipient name - handles both profile usernames and invite emails
  static String getRecipientName(Map<String, dynamic> coupon) {
    // First check if there's a recipient username from the flat structure
    final recipientUsername = coupon['recipient_username'] as String?;
    if (recipientUsername != null && recipientUsername.isNotEmpty) {
      return recipientUsername;
    }

    // If no username found, check for recipient_email (invite scenario)
    final recipientEmail = coupon['recipient_email'] as String?;
    if (recipientEmail != null && recipientEmail.isNotEmpty) {
      return recipientEmail; // Email invite
    }

    return 'Unknown Recipient';
  }

  /// Get purchaser name from profiles
  static String getPurchaserName(Map<String, dynamic> coupon) {
    return coupon['purchaser_username'] as String? ?? 'Unknown Purchaser';
  }

  /// Get bar address from coupon data (if available)
  static String? getBarAddress(Map<String, dynamic> coupon) {
    return coupon['bar_address'] as String?;
  }

  /// Get bar coordinates (latitude and longitude) from coupon data (if available)
  static Map<String, double>? getBarCoordinates(Map<String, dynamic> coupon) {
    // Try multiple possible field names for coordinates
    final latitude = coupon['bar_latitude'] as double? ??
                    coupon['location_lat'] as double? ??
                    coupon['lat'] as double?;

    final longitude = coupon['bar_longitude'] as double? ??
                     coupon['location_long'] as double? ??
                     coupon['lng'] as double? ??
                     coupon['long'] as double?;

    if (latitude != null && longitude != null) {
      return {'latitude': latitude, 'longitude': longitude};
    }
    return null;
  }

  /// Get bar ID from coupon data (if available)
  static String? getBarId(Map<String, dynamic> coupon) {
    return coupon['bar_id'] as String?;
  }

  /// Generate Google Maps URL for the bar
  static String getGoogleMapsUrl(Map<String, dynamic> coupon) {
    final coordinates = getBarCoordinates(coupon);
    final address = getBarAddress(coupon);
    final barName = getBarName(coupon);

    // If we have coordinates, use them for precise location
    if (coordinates != null) {
      final lat = coordinates['latitude']!;
      final lng = coordinates['longitude']!;
      return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    }

    // If we have an address, use it
    if (address != null && address.isNotEmpty) {
      final encodedAddress = Uri.encodeComponent(address);
      return 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    }

    // Fallback to bar name search
    final encodedBarName = Uri.encodeComponent(barName);
    return 'https://www.google.com/maps/search/?api=1&query=$encodedBarName';
  }
}