import 'package:django_grocer/models/grocery_item.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Order {
  final String? id;
  final String customerId;
  final String? driverId;
  final String status;
  final DateTime createdAt;
  final List<GroceryItem> items;
  final LatLng? driverLocation;

  Order({
    this.id,
    required this.customerId,
    this.driverId,
    required this.status,
    required this.createdAt,
    required this.items,
    this.driverLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'driverId': driverId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      if (driverLocation != null)
        'driverLocation': {
          'lat': driverLocation!.latitude,
          'lng': driverLocation!.longitude,
        },
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      customerId: map['customerId'],
      driverId: map['driverId'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      items: List<GroceryItem>.from(
        (map['items'] as List).map((item) => GroceryItem.fromMap(item)),
      ),
      driverLocation:
          map['driverLocation'] != null
              ? LatLng(
                map['driverLocation']['lat'],
                map['driverLocation']['lng'],
              )
              : null,
    );
  }
}
