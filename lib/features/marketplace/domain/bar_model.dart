import 'dart:math' as math;

/// Bar model that matches the 'bars' table in Supabase database
class Bar {
  final String id;
  final String name;
  final double locationLat;
  final double locationLong;

  const Bar({
    required this.id,
    required this.name,
    required this.locationLat,
    required this.locationLong,
  });

  /// Create Bar instance from Supabase JSON response
  factory Bar.fromJson(Map<String, dynamic> json) {
    return Bar(
      id: json['id'] as String,
      name: json['name'] as String,
      locationLat: (json['location_lat'] as num).toDouble(),
      locationLong: (json['location_long'] as num).toDouble(),
    );
  }

  /// Convert Bar instance to JSON for Supabase operations
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location_lat': locationLat,
      'location_long': locationLong,
    };
  }

  /// Create a copy of Bar with optional parameter updates
  Bar copyWith({
    String? id,
    String? name,
    double? locationLat,
    double? locationLong,
  }) {
    return Bar(
      id: id ?? this.id,
      name: name ?? this.name,
      locationLat: locationLat ?? this.locationLat,
      locationLong: locationLong ?? this.locationLong,
    );
  }

  /// Calculate distance between this bar and given coordinates (simplified)
  /// Returns approximate distance in kilometers
  double distanceTo(double lat, double lng) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers

    double latDiff = (lat - locationLat) * (math.pi / 180);
    double lngDiff = (lng - locationLong) * (math.pi / 180);

    double a = math.pow(math.sin(latDiff / 2), 2) +
        math.pow(math.sin(lngDiff / 2), 2) *
        math.cos(locationLat * math.pi / 180) *
        math.cos(lat * math.pi / 180);

    double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  /// Format coordinates for display
  String get coordinates => '${locationLat.toStringAsFixed(4)}, ${locationLong.toStringAsFixed(4)}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bar &&
        other.id == id &&
        other.name == name &&
        other.locationLat == locationLat &&
        other.locationLong == locationLong;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        locationLat.hashCode ^
        locationLong.hashCode;
  }

  @override
  String toString() {
    return 'Bar(id: $id, name: $name, lat: $locationLat, lng: $locationLong)';
  }
}