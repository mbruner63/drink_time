import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/menu_item_model.dart';
import '../data/menu_repository.dart';

/// Provider for MenuRepository
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

/// FutureProvider for getting menu items for a specific bar
final menuItemsProvider = FutureProvider.family<List<MenuItem>, String>((ref, barId) async {
  final repository = ref.read(menuRepositoryProvider);
  return await repository.getMenuForBar(barId);
});

/// StateNotifier for managing purchase state
class PurchaseController extends StateNotifier<PurchaseState> {
  final MenuRepository _repository;

  PurchaseController(this._repository) : super(const PurchaseState());

  /// Purchase a drink and create a coupon
  Future<String?> purchaseDrink({
    required String userId,
    required String drinkId,
    required int amount,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      purchasedCouponId: null,
    );

    try {
      await _repository.purchaseDrink(userId, drinkId, amount);
      final couponId = 'debug_coupon_id'; // Temporary since debug function returns void

      state = state.copyWith(
        isLoading: false,
        purchasedCouponId: couponId,
        lastPurchase: PurchaseInfo(
          drinkId: drinkId,
          amount: amount,
          couponId: couponId,
          timestamp: DateTime.now(),
        ),
      );

      return couponId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Clear purchase state
  void clearPurchaseState() {
    state = const PurchaseState();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for PurchaseController
final purchaseControllerProvider = StateNotifierProvider<PurchaseController, PurchaseState>((ref) {
  final repository = ref.read(menuRepositoryProvider);
  return PurchaseController(repository);
});

/// State class for purchase operations
class PurchaseState {
  final bool isLoading;
  final String? error;
  final String? purchasedCouponId;
  final PurchaseInfo? lastPurchase;

  const PurchaseState({
    this.isLoading = false,
    this.error,
    this.purchasedCouponId,
    this.lastPurchase,
  });

  PurchaseState copyWith({
    bool? isLoading,
    String? error,
    String? purchasedCouponId,
    PurchaseInfo? lastPurchase,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      purchasedCouponId: purchasedCouponId ?? this.purchasedCouponId,
      lastPurchase: lastPurchase ?? this.lastPurchase,
    );
  }

  bool get hasError => error != null;
  bool get hasSuccessfulPurchase => purchasedCouponId != null;
}

/// Information about a purchase
class PurchaseInfo {
  final String drinkId;
  final int amount;
  final String couponId;
  final DateTime timestamp;

  const PurchaseInfo({
    required this.drinkId,
    required this.amount,
    required this.couponId,
    required this.timestamp,
  });

  String get formattedAmount {
    final dollars = amount / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }
}

/// Provider for individual menu item
final menuItemProvider = FutureProvider.family<MenuItem?, String>((ref, itemId) async {
  final repository = ref.read(menuRepositoryProvider);
  return await repository.getMenuItemById(itemId);
});

/// Provider for user's purchase history
final userPurchaseHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final repository = ref.read(menuRepositoryProvider);
  return await repository.getUserPurchases(userId);
});

/// Provider for checking if a bar has menu items
final barHasMenuProvider = FutureProvider.family<bool, String>((ref, barId) async {
  final repository = ref.read(menuRepositoryProvider);
  return await repository.barHasMenu(barId);
});

/// Provider for user's total spending
final userTotalSpentProvider = FutureProvider.family<double, String>((ref, userId) async {
  final repository = ref.read(menuRepositoryProvider);
  return await repository.getTotalSpentByUser(userId);
});

/// StateNotifier for managing individual item purchase states
class ItemPurchaseController extends StateNotifier<Map<String, bool>> {
  final Ref _ref;

  ItemPurchaseController(this._ref) : super({});

  /// Set loading state for a specific item
  void setItemLoading(String itemId, bool isLoading) {
    state = {...state, itemId: isLoading};
  }

  /// Check if specific item is loading
  bool isItemLoading(String itemId) {
    return state[itemId] ?? false;
  }

  /// Clear all loading states
  void clearAllLoading() {
    state = {};
  }

  /// Purchase specific item
  Future<String?> purchaseItem({
    required String userId,
    required MenuItem item,
  }) async {
    setItemLoading(item.id, true);

    try {
      final result = await _ref.read(purchaseControllerProvider.notifier).purchaseDrink(
        userId: userId,
        drinkId: item.id,
        amount: item.priceInCents,
      );

      setItemLoading(item.id, false);
      return result;
    } catch (e) {
      setItemLoading(item.id, false);
      rethrow;
    }
  }
}

/// Provider for individual item purchase states
final itemPurchaseControllerProvider = StateNotifierProvider<ItemPurchaseController, Map<String, bool>>((ref) {
  return ItemPurchaseController(ref);
});