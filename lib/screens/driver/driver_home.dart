import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:django_grocer/models/order_model.dart' as my;
import 'package:django_grocer/services/order_service.dart';
import 'package:django_grocer/screens/driver/delivery_screen.dart';
import 'package:django_grocer/providers/database_provider.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersStream = ref.watch(availableOrdersProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Available Orders')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user?.driverStatus != 'approved') {
            return const Center(
              child: Text('Your driver account is pending approval'),
            );
          }

          return ordersStream.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (orders) {
              if (orders.isEmpty) {
                return const Center(child: Text('No available orders'));
              }

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    child: ListTile(
                      title: Text('Order #${order.id?.substring(0, 8)}'),
                      subtitle: Text('${order.items.length} items'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(orderServiceProvider)
                              .assignDriver(order.id!, user!.id)
                              .then((_) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            DeliveryScreen(orderId: order.id!),
                                  ),
                                );
                              });
                        },
                        child: const Text('Accept'),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

final availableOrdersProvider = StreamProvider<List<my.Order>>((ref) {
  return ref.watch(orderServiceProvider).getOrdersByStatus('PENDING');
});
