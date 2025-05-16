import 'package:cloud_firestore/cloud_firestore.dart';

class DriverApplication {
  final String id;
  final String name;
  final String userId;
  final String licenseNumber;
  final String vehicleDetails;
  final String licenseUrl;
  final String idUrl;
  final String proofOfResidenceUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime submittedAt;

  DriverApplication({
    required this.id,
    required this.name,
    required this.userId,
    required this.licenseNumber,
    required this.vehicleDetails,
    required this.licenseUrl,
    required this.idUrl,
    required this.proofOfResidenceUrl,
    required this.status,
    required this.submittedAt,
  });

  factory DriverApplication.fromMap(
    Map<String, dynamic> data,
    String id,
    String name,
  ) {
    return DriverApplication(
      id: id,
      name: name,
      userId: data['userId'],
      licenseNumber: data['licenseNumber'],
      vehicleDetails: data['vehicleDetails'],
      licenseUrl: data['licenseUrl'],
      idUrl: data['idUrl'],
      proofOfResidenceUrl: data['proofOfResidenceUrl'],
      status: data['status'] ?? 'pending',
      submittedAt:
          (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'licenseNumber': licenseNumber,
      'vehicleDetails': vehicleDetails,
      'licenseUrl': licenseUrl,
      'idUrl': idUrl,
      'proofOfResidenceUrl': proofOfResidenceUrl,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }
}
