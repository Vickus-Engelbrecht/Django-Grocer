import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String userType; // 'customer' or 'driver'
  final String? driverStatus; // 'pending_approval', 'approved', 'rejected'
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.driverStatus,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      userType: data['userType'] ?? 'customer',
      driverStatus: data['driverStatus'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      id: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      userType: map['userType'] ?? '',
      driverStatus: map['driverStatus'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'userType': userType,
      if (driverStatus != null) 'driverStatus': driverStatus,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
