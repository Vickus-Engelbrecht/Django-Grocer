import 'package:flutter/material.dart';
import 'package:django_grocer/models/grocery_item.dart';

class OrderItemInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const OrderItemInput({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Item name',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(icon: const Icon(Icons.add_circle), onPressed: onAdd),
      ],
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onDelete;

  const OrderItemCard({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.name),
        subtitle: Text(item.preferredStore ?? 'No store preference'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Qty: ${item.quantity}'),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderStatusIndicator extends StatelessWidget {
  final String status;

  const OrderStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      switch (status) {
        case 'PENDING':
          return Colors.orange;
        case 'ACCEPTED':
          return Colors.blue;
        case 'SHOPPING':
          return Colors.purple;
        case 'ON_THE_WAY':
          return Colors.teal;
        case 'DELIVERED':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    return Chip(
      label: Text(status),
      backgroundColor: getColor().withOpacity(0.2),
      labelStyle: TextStyle(color: getColor()),
    );
  }
}
