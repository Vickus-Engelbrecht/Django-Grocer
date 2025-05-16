import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:django_grocer/models/driver_model.dart';
import 'package:django_grocer/screens/admin/application_detail_screen.dart';

final driverApplicationsStreamProvider =
    StreamProvider<List<DriverApplication>>((ref) {
      return FirebaseFirestore.instance
          .collection('driver_applications')
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  final name =
                      data['name'] ?? 'No name'; // extract name manually
                  return DriverApplication.fromMap(data, doc.id, name);
                }).toList(),
          );
    });

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(driverApplicationsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: applicationsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return const Center(child: Text('No pending applications'));
          }

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return ListTile(
                title: Text(application.name),
                subtitle: Text(application.status),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ApplicationDetailScreen(application: application),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
