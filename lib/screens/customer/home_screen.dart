import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:django_grocer/screens/customer/order_screen.dart';
import 'package:django_grocer/providers/database_provider.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (user) {
          return Column(
            children: [
              ListTile(
                title: Text('Welcome, ${user?.name ?? 'Customer'}'),
                subtitle: Text(user?.email ?? ''),
              ),
              Expanded(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderScreen(),
                        ),
                      );
                    },
                    child: const Text('Create New Order'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
