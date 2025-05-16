import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:django_grocer/models/order_model.dart' as my;
import 'package:django_grocer/services/order_service.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({Key? key, required this.orderId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStream = ref.watch(orderServiceProvider).getOrderStream(orderId);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: StreamBuilder<my.Order?>(
        stream: orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Order not found'));
          }

          final order = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(0, 0), // Use actual coordinates
                    zoom: 15,
                  ),
                  markers: {
                    if (order.driverLocation != null)
                      Marker(
                        markerId: const MarkerId('driver'),
                        position: order.driverLocation!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        ),
                      ),
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: LatLng(0, 0), // Use customer's location
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Status: ${order.status}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (order.driverId != null)
                      FutureBuilder<DocumentSnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(order.driverId)
                                .get(),
                        builder: (context, driverSnapshot) {
                          if (driverSnapshot.connectionState ==
                              ConnectionState.done) {
                            final driverName =
                                driverSnapshot.data?['name'] ?? 'Driver';
                            return Text('Driver: $driverName');
                          }
                          return const Text('Driver: Loading...');
                        },
                      ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: _getProgressValue(order.status),
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

  double _getProgressValue(String status) {
    switch (status) {
      case 'PENDING':
        return 0.2;
      case 'ACCEPTED':
        return 0.4;
      case 'SHOPPING':
        return 0.6;
      case 'ON_THE_WAY':
        return 0.8;
      case 'DELIVERED':
        return 1.0;
      default:
        return 0.0;
    }
  }
}
