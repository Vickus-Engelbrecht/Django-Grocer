import 'package:flutter/material.dart';
import 'package:django_grocer/models/driver_model.dart'; // Adjust path if needed

class ApplicationDetailScreen extends StatelessWidget {
  final DriverApplication application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Application Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Name: ${application.name}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('License Number: ${application.licenseNumber}'),
            const SizedBox(height: 8),
            Text('Vehicle Details: ${application.vehicleDetails}'),
            const SizedBox(height: 8),
            Text('Status: ${application.status}'),
            const SizedBox(height: 8),
            Text('Submitted: ${application.submittedAt}'),
            const SizedBox(height: 16),
            // Example of viewing uploaded document URLs
            ElevatedButton(
              onPressed: () {
                // You can use url_launcher to view document if needed
              },
              child: const Text('View Driver\'s License'),
            ),
            ElevatedButton(
              onPressed: () {
                // Approve or reject logic here
              },
              child: const Text('Approve Application'),
            ),
          ],
        ),
      ),
    );
  }
}
