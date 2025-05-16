import 'package:django_grocer/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:django_grocer/models/user_model.dart';
import 'package:django_grocer/models/driver_model.dart';
import 'auth_provider.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userDataProvider = Provider.family<Stream<AppUser?>, String>((ref, uid) {
  return ref.watch(storageServiceProvider).getUserStream(uid);
});

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(authProvider);
  if (auth == null) return Stream.value(null);

  return ref.watch(userDataProvider(auth.uid));
});

final driverApplicationsProvider = StreamProvider<List<DriverApplication>>((
  ref,
) {
  return ref
      .watch(firestoreProvider)
      .collection('driver_applications')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map(
                  (doc) => DriverApplication.fromMap(
                    doc.data(),
                    doc.id,
                    doc.data()['name'],
                  ),
                )
                .toList(),
      );
});
