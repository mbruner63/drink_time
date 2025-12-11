import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/bar_model.dart';

/// Repository for handling marketplace/bars data operations with Supabase
class MarketplaceRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get all bars from the 'bars' table
  Future<List<Bar>> getBars() async {
    try {
      final response = await _client
          .from('bars')
          .select('id, name, location_lat, location_long')
          .order('name'); // Order by name alphabetically

      final List<dynamic> data = response as List<dynamic>;

      return data
          .map((barJson) => Bar.fromJson(barJson as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch bars: $e');
    }
  }

  /// Get bars within a specific radius of given coordinates
  /// Note: This is a simple implementation. For production, consider using PostGIS
  Future<List<Bar>> getBarsNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      // First get all bars (in production, you'd want to use spatial queries)
      final allBars = await getBars();

      // Filter by distance
      return allBars.where((bar) {
        final distance = bar.distanceTo(latitude, longitude);
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch nearby bars: $e');
    }
  }

  /// Get a specific bar by ID
  Future<Bar?> getBarById(String barId) async {
    try {
      final response = await _client
          .from('bars')
          .select('id, name, location_lat, location_long')
          .eq('id', barId)
          .single();

      return Bar.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // No rows found
        return null;
      }
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch bar: $e');
    }
  }

  /// Search bars by name
  Future<List<Bar>> searchBars(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getBars();
      }

      final response = await _client
          .from('bars')
          .select('id, name, location_lat, location_long')
          .ilike('name', '%$query%')
          .order('name');

      final List<dynamic> data = response as List<dynamic>;

      return data
          .map((barJson) => Bar.fromJson(barJson as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search bars: $e');
    }
  }

  /// Get bars ordered by distance from given coordinates
  Future<List<Bar>> getBarsOrderedByDistance({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final allBars = await getBars();

      // Sort by distance
      allBars.sort((a, b) {
        final distanceA = a.distanceTo(latitude, longitude);
        final distanceB = b.distanceTo(latitude, longitude);
        return distanceA.compareTo(distanceB);
      });

      return allBars;
    } catch (e) {
      throw Exception('Failed to fetch bars ordered by distance: $e');
    }
  }

  /// Check if bars table is accessible (useful for debugging)
  Future<bool> checkConnection() async {
    try {
      await _client.from('bars').select('count').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get total count of bars
  Future<int> getBarCount() async {
    try {
      final response = await _client
          .from('bars')
          .select('id')
          .count(CountOption.exact);

      return response.count ?? 0;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to count bars: $e');
    }
  }
}