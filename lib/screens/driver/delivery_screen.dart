import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:django_grocer/models/order_model.dart';
import 'package:django_grocer/services/order_service.dart';

class DeliveryScreen extends ConsumerStatefulWidget {
  final String orderId;

  const DeliveryScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  ConsumerState<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends ConsumerState<DeliveryScreen> {
  String _currentStatus = 'ACCEPTED';

  @override
  Widget build(BuildContext context) {
    final orderStream = ref
        .watch(orderServiceProvider)
        .getOrderStream(widget.orderId);

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery')),
      body: StreamBuilder<Order?>(
        stream: orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Order not found'));
          }

          final order = snapshot.data!;
          _currentStatus = order.status;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Text(
                      'Order Status: ${order.status}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Items:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...order.items
                        .map(
                          (item) => ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                              item.preferredStore ?? 'No store preference',
                            ),
                            trailing: Text('Qty: ${item.quantity}'),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_currentStatus == 'ACCEPTED')
                      ElevatedButton(
                        onPressed: () => _updateStatus('SHOPPING'),
                        child: const Text('Start Shopping'),
                      ),
                    if (_currentStatus == 'SHOPPING')
                      ElevatedButton(
                        onPressed: () => _updateStatus('ON_THE_WAY'),
                        child: const Text('Start Delivery'),
                      ),
                    if (_currentStatus == 'ON_THE_WAY')
                      ElevatedButton(
                        onPressed: () => _updateStatus('DELIVERED'),
                        child: const Text('Mark as Delivered'),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    await ref
        .read(orderServiceProvider)
        .updateOrderStatus(widget.orderId, newStatus);
    setState(() => _currentStatus = newStatus);
  }
}
