import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  // TODO: Declare fields (id, name, quantity, price, category, createdAt)
  final String? id;
  final String name;
  final int quantity;
  final double price;
  final String category;
  final DateTime createdAt;

  // TODO: Create constructor with named parameters
  Item({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    required this.createdAt,
  });

  // TODO: Implement toMap() for Firestore
  Map<String, dynamic> toMap() {
    return {
      // TODO: Convert all fields to map
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // TODO: Implement fromMap() factory constructor
  factory Item.fromMap(String id, Map<String, dynamic> map) {
    return Item(
      // TODO: Extract values from map
      id: id,
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] is int)
        ? (map['price'] as int).toDouble()
        : (map['price'] ?? 0.0),
      category: map['category'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
