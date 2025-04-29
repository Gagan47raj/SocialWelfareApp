import 'package:flutter/material.dart';
import '../services/department_auth_service.dart';

class DepartmentSignupScreen extends StatefulWidget {
  @override
  _DepartmentSignupScreenState createState() => _DepartmentSignupScreenState();
}

class _DepartmentSignupScreenState extends State<DepartmentSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _parentMinistryController =
      TextEditingController();
  String? _selectedType;
  String? _selectedGovernmentLevel;
  final DepartmentAuthService _authService = DepartmentAuthService();
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _selectedCategories = [];

  // Color palette
  final Color _lightBlue = const Color(0xFFBEE9E8);
  final Color _teal = const Color(0xFF62B6CB);
  final Color _darkBlue = const Color(0xFF1B4965);
  final Color _paleBlue = const Color(0xFFCAE9FF);
  final Color _mediumBlue = const Color(0xFF5FA8D3);

  final List<String> _departmentTypes = [
    'Healthcare',
    'Police',
    'Municipal',
    'Transport',
    'Education',
    'Social Welfare',
    'Public Works',
    'Environment',
    'Others'
  ];

  final List<String> _governmentLevels = [
    'Central',
    'State',
    'District',
    'Municipal',
    'Panchayat'
  ];

  final List<String> _availableCategories = [
    'Housing',
    'Healthcare',
    'Education',
    'Employment',
    'Social Welfare',
    'Disability Services'
  ];

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }
    if (_selectedCategories.isEmpty) {
      setState(() =>
          _errorMessage = 'Please select at least one complaint category');
      return;
    }
    if (_selectedType == null) {
      setState(() => _errorMessage = 'Please select department type');
      return;
    }
    if (_selectedGovernmentLevel == null) {
      setState(() => _errorMessage = 'Please select government level');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        type: _selectedType!,
        governmentLevel: _selectedGovernmentLevel!,
        parentMinistry: _parentMinistryController.text.trim(),
        password: _passwordController.text.trim(),
        complaintCategories: _selectedCategories,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Department registered successfully!'),
          backgroundColor: _teal,
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBlue,
      appBar: AppBar(
        title: Text(
          'Department Registration',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _darkBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_errorMessage != null) SizedBox(height: 20),

              // Department Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Department Name',
                  labelStyle: TextStyle(color: _darkBlue.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _darkBlue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.account_balance, color: _teal),
                  filled: true,
                  fillColor: _paleBlue,
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),

              // Department Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Department Type',
                  labelStyle: TextStyle(color: _darkBlue.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _darkBlue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: _paleBlue,
                ),
                dropdownColor: _paleBlue,
                items: _departmentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type,
                      style: TextStyle(color: _darkBlue),
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              SizedBox(height: 20),

              // Government Level Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGovernmentLevel,
                decoration: InputDecoration(
                  labelText: 'Government Level',
                  labelStyle: TextStyle(color: _darkBlue.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _darkBlue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: _paleBlue,
                ),
                dropdownColor: _paleBlue,
                items: _governmentLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(
                      level,
                      style: TextStyle(color: _darkBlue),
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedGovernmentLevel = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              SizedBox(height: 20),

              // Parent Ministry
              TextFormField(
                controller: _parentMinistryController,
                decoration: InputDecoration(
                  labelText: 'Parent Ministry/Department',
                  labelStyle: TextStyle(color: _darkBlue.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _darkBlue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.people, color: _teal),
                  filled: true,
                  fillColor: _paleBlue,
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Official Email',
                  labelStyle: TextStyle(color: _darkBlue.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _darkBlue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.email, color: _teal),
                  filled: true,
                  fillColor: _paleBlue,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  labelStyle: TextStyle(color: _darkBlue.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _darkBlue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.phone, color: _teal),
                  filled: true,
                  fillColor: _paleBlue,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),

              // Password fields
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: _darkBlue.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _darkBlue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.lock, color: _teal),
                  filled: true,
                  fillColor: _paleBlue,
                ),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: _darkBlue.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _darkBlue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: _teal),
                  filled: true,
                  fillColor: _paleBlue,
                ),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),

              // Complaint Categories
              Text(
                'Complaint Categories:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _darkBlue,
                ),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableCategories.map((category) {
                  return FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: _selectedCategories.contains(category)
                            ? Colors.white
                            : _darkBlue,
                      ),
                    ),
                    selected: _selectedCategories.contains(category),
                    selectedColor: _mediumBlue,
                    backgroundColor: _paleBlue,
                    checkmarkColor: Colors.white,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 30),

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'REGISTER DEPARTMENT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: _mediumBlue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    color: _darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
