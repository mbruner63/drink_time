/// MenuItem model that represents drinks available for purchase
class MenuItem {
  final String id;
  final String name;
  final int priceInCents;

  const MenuItem({
    required this.id,
    required this.name,
    required this.priceInCents,
  });

  /// Create MenuItem instance from Supabase JSON response
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      priceInCents: json['price_in_cents'] as int,
    );
  }

  /// Convert MenuItem instance to JSON for Supabase operations
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_in_cents': priceInCents,
    };
  }

  /// Create a copy of MenuItem with optional parameter updates
  MenuItem copyWith({
    String? id,
    String? name,
    int? priceInCents,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      priceInCents: priceInCents ?? this.priceInCents,
    );
  }

  /// Get formatted price in dollars
  String get formattedPrice {
    final dollars = priceInCents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }

  /// Get price in dollars as double
  double get priceInDollars => priceInCents / 100.0;

  /// Check if item is free
  bool get isFree => priceInCents == 0;

  /// Get price display with currency symbol
  String get priceDisplay {
    if (isFree) return 'Free';
    return formattedPrice;
  }

  /// Get cents from dollar amount
  static int dollarseToCents(double dollars) {
    return (dollars * 100).round();
  }

  /// Format price in cents to display string
  static String formatPrice(int cents) {
    final dollars = cents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItem &&
        other.id == id &&
        other.name == name &&
        other.priceInCents == priceInCents;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ priceInCents.hashCode;
  }

  @override
  String toString() {
    return 'MenuItem(id: $id, name: $name, price: ${formattedPrice})';
  }
}