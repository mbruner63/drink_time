import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/bar_model.dart';
import '../data/marketplace_repository.dart';

/// Provider for MarketplaceRepository
final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepository();
});

/// FutureProvider for the list of all bars
final barListProvider = FutureProvider<List<Bar>>((ref) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.getBars();
});

/// Provider for searching bars by name
final barSearchProvider = FutureProvider.family<List<Bar>, String>((ref, query) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.searchBars(query);
});

/// Provider for getting bars near a specific location
final nearbyBarsProvider = FutureProvider.family<List<Bar>, LocationQuery>((ref, location) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.getBarsNearLocation(
    latitude: location.latitude,
    longitude: location.longitude,
    radiusKm: location.radiusKm,
  );
});

/// Provider for getting a specific bar by ID
final barByIdProvider = FutureProvider.family<Bar?, String>((ref, barId) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.getBarById(barId);
});

/// Provider for bars ordered by distance from user location
final barsByDistanceProvider = FutureProvider.family<List<Bar>, UserLocation>((ref, userLocation) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.getBarsOrderedByDistance(
    latitude: userLocation.latitude,
    longitude: userLocation.longitude,
  );
});

/// Provider for total bar count
final barCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.getBarCount();
});

/// Provider to check marketplace connection status
final marketplaceConnectionProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.checkConnection();
});

/// StateNotifier for managing marketplace search state
class MarketplaceSearchController extends StateNotifier<MarketplaceSearchState> {
  final MarketplaceRepository _repository;

  MarketplaceSearchController(this._repository) : super(const MarketplaceSearchState());

  /// Search for bars with debounced input
  Future<void> searchBars(String query) async {
    if (query.trim() == state.query.trim()) return;

    state = state.copyWith(
      query: query,
      isLoading: true,
      error: null,
    );

    try {
      final bars = await _repository.searchBars(query);
      state = state.copyWith(
        bars: bars,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Clear search results
  void clearSearch() {
    state = const MarketplaceSearchState();
  }

  /// Refresh search results
  Future<void> refreshSearch() async {
    if (state.query.isNotEmpty) {
      await searchBars(state.query);
    }
  }
}

/// Provider for marketplace search controller
final marketplaceSearchControllerProvider = StateNotifierProvider<MarketplaceSearchController, MarketplaceSearchState>((ref) {
  final repository = ref.read(marketplaceRepositoryProvider);
  return MarketplaceSearchController(repository);
});

/// State class for marketplace search
class MarketplaceSearchState {
  final String query;
  final List<Bar> bars;
  final bool isLoading;
  final String? error;

  const MarketplaceSearchState({
    this.query = '',
    this.bars = const [],
    this.isLoading = false,
    this.error,
  });

  MarketplaceSearchState copyWith({
    String? query,
    List<Bar>? bars,
    bool? isLoading,
    String? error,
  }) {
    return MarketplaceSearchState(
      query: query ?? this.query,
      bars: bars ?? this.bars,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasResults => bars.isNotEmpty;
  bool get hasError => error != null;
  bool get isEmpty => bars.isEmpty && query.isNotEmpty && !isLoading;
}

/// Data class for location-based queries
class LocationQuery {
  final double latitude;
  final double longitude;
  final double radiusKm;

  const LocationQuery({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 10.0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationQuery &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.radiusKm == radiusKm;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^ longitude.hashCode ^ radiusKm.hashCode;
  }
}

/// Data class for user location
class UserLocation {
  final double latitude;
  final double longitude;

  const UserLocation({
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserLocation &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^ longitude.hashCode;
  }
}