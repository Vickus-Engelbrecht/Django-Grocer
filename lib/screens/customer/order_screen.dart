import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:django_grocer/models/order_model.dart';
import 'package:django_grocer/services/order_service.dart';
import 'package:django_grocer/widgets/order_widgets.dart';
import 'package:django_grocer/models/grocery_item.dart';
import 'package:django_grocer/providers/auth_provider.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final _itemController = TextEditingController();
  final _storeController = TextEditingController();
  final List<GroceryItem> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            OrderItemInput(
              controller: _itemController,
              onAdd: () {
                if (_itemController.text.isNotEmpty) {
                  setState(() {
                    _items.add(
                      GroceryItem(
                        name: _itemController.text,
                        quantity: 1,
                        preferredStore:
                            _storeController.text.isNotEmpty
                                ? _storeController.text
                                : null,
                      ),
                    );
                  });
                  _itemController.clear();
                  _storeController.clear();
                }
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  _items.isEmpty
                      ? const Center(child: Text('No items added yet'))
                      : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return OrderItemCard(
                            item: _items[index],
                            onDelete: () {
                              setState(() {
                                _items.removeAt(index);
                              });
                            },
                          );
                        },
                      ),
            ),
            ElevatedButton(
              onPressed:
                  _items.isEmpty
                      ? null
                      : () async {
                        final user = ref.read(authProvider);
                        if (user == null) return;

                        final order = Order(
                          customerId: user.uid,
                          status: 'PENDING',
                          createdAt: DateTime.now(),
                          items: _items,
                        );

                        await ref.read(orderServiceProvider).createOrder(order);
                        Navigator.pop(context);
                      },
              child: const Text('Submit Order'),
            ),
          ],
        ),
      ),
    );
  }
}
