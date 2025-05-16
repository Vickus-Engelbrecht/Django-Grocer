import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:django_grocer/models/order_model.dart' as my;

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<my.Order>> getOrdersByStatus(String status) {
    return _db
        .collection('orders')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return my.Order.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Stream<my.Order> getOrderStream(String orderId) {
    return _db.collection('orders').doc(orderId).snapshots().map((doc) {
      return my.Order.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> assignDriver(String orderId, String driverId) async {
    await _db.collection('orders').doc(orderId).update({
      'driverId': driverId,
      'status': 'IN_PROGRESS',
      'assignedAt': FieldValue.serverTimestamp(),
    });
  }

  // Create new order
  Future<void> createOrder(my.Order order) async {
    await _db.collection('orders').add(order.toMap());
  }

  // Get customer orders
  Stream<List<my.Order>> getCustomerOrders(String userId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => my.Order.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({'status': status});
  }
}
