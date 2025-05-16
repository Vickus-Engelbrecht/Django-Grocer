import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:django_grocer/providers/auth_provider.dart';
import 'package:django_grocer/screens/driver/driver_home.dart';
import 'dart:io';

class DriverRegistrationScreen extends ConsumerStatefulWidget {
  const DriverRegistrationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState
    extends ConsumerState<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  final _vehicleController = TextEditingController();
  File? _licenseImage;
  File? _idImage;
  File? _proofOfResidence;
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source, String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (type == 'license') {
          _licenseImage = File(pickedFile.path);
        } else if (type == 'id') {
          _idImage = File(pickedFile.path);
        } else if (type == 'residence') {
          _proofOfResidence = File(pickedFile.path);
        }
      });
    }
  }

  Future<String> _uploadFile(File file, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate() &&
        _licenseImage != null &&
        _idImage != null &&
        _proofOfResidence != null) {
      setState(() => _isSubmitting = true);

      try {
        final userId = ref.read(authProvider)?.uid;
        if (userId == null) throw Exception('User not authenticated');

        // Upload all documents
        final licenseUrl = await _uploadFile(
          _licenseImage!,
          'drivers/$userId/license_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        final idUrl = await _uploadFile(
          _idImage!,
          'drivers/$userId/id_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        final residenceUrl = await _uploadFile(
          _proofOfResidence!,
          'drivers/$userId/residence_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        // Save driver application
        await FirebaseFirestore.instance
            .collection('driver_applications')
            .doc(userId)
            .set({
              'licenseNumber': _licenseController.text,
              'vehicleDetails': _vehicleController.text,
              'licenseUrl': licenseUrl,
              'idUrl': idUrl,
              'proofOfResidenceUrl': residenceUrl,
              'userId': userId,
              'status': 'pending',
              'submittedAt': FieldValue.serverTimestamp(),
            });

        // Update user role to driver (pending approval)
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'driverStatus': 'pending_approval'},
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application: $e')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(labelText: 'License Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your license number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _vehicleController,
                decoration: const InputDecoration(labelText: 'Vehicle Details'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Driver License Photo:'),
              _licenseImage != null
                  ? Image.file(_licenseImage!, height: 150)
                  : const SizedBox(height: 150, child: Placeholder()),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _pickImage(ImageSource.camera, 'license'),
                    child: const Text('Take Photo'),
                  ),
                  TextButton(
                    onPressed: () => _pickImage(ImageSource.gallery, 'license'),
                    child: const Text('Choose from Gallery'),
                  ),
                ],
              ),
              // Similar UI blocks for ID and Proof of Residence
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
