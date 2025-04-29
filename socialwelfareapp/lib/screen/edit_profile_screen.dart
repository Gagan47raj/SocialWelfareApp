import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _professionController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  String? _currentLocation;
  File? _selectedImage;
  String? _profileImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic>? data = userSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        setState(() {
          _nameController.text = data['name'] ?? "";
          _phoneController.text = data['phone'] ?? "";
          _professionController.text = data['profession'] ?? "";
          _selectedGender = data['gender'] ?? null;
          _selectedDateOfBirth =
              data['dob'] != null ? DateTime.parse(data['dob']) : null;
          _currentLocation = data['location'];
          _profileImageUrl = data['profileImageUrl'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation =
          "Lat: ${position.latitude}, Lon: ${position.longitude}";
    });
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDateOfBirth = pickedDate;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    User? user = _auth.currentUser;
    if (user == null) return;

    String? newProfileImageUrl = _profileImageUrl;

    if (_selectedImage != null) {
      Reference storageRef =
          _storage.ref().child('profile_images/${user.uid}.jpg');
      await storageRef.putFile(_selectedImage!);
      newProfileImageUrl = await storageRef.getDownloadURL();
    }

    // Get user document reference
    DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
    DocumentSnapshot userSnapshot = await userDoc.get();

    if (!userSnapshot.exists) {
      // If the document does not exist, create it first
      await userDoc.set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'profession': _professionController.text,
        'gender': _selectedGender,
        'dob': _selectedDateOfBirth?.toIso8601String(),
        'location': _currentLocation,
        'profileImageUrl': newProfileImageUrl,
      });
    } else {
      // If the document exists, update it
      await userDoc.update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'profession': _professionController.text,
        'gender': _selectedGender,
        'dob': _selectedDateOfBirth?.toIso8601String(),
        'location': _currentLocation,
        'profileImageUrl': newProfileImageUrl,
      });
    }

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (_profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : AssetImage("assets/default_avatar.png"))
                                as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: "Phone Number"),
                    ),
                    TextField(
                      controller: _professionController,
                      decoration: InputDecoration(labelText: "Profession"),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(labelText: "Gender"),
                      items: ["Male", "Female", "Other"]
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      title: Text(
                          "Date of Birth: ${_selectedDateOfBirth != null ? _selectedDateOfBirth!.toLocal().toString().split(' ')[0] : 'Select'}"),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _selectDateOfBirth(context),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      title: Text(_currentLocation ?? "Get Current Location"),
                      trailing: Icon(Icons.location_on),
                      onTap: _getCurrentLocation,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text("Save Changes"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
