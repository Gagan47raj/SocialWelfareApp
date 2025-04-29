import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/department.dart';
import '../services/department_auth_service.dart';

class DepartmentLoginScreen extends StatefulWidget {
  @override
  _DepartmentLoginScreenState createState() => _DepartmentLoginScreenState();
}

class _DepartmentLoginScreenState extends State<DepartmentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DepartmentAuthService _authService = DepartmentAuthService();
  bool _isLoading = false;
  String? _errorMessage;

  // Color palette
  final Color _lightBlue = const Color(0xFFBEE9E8);
  final Color _teal = const Color(0xFF62B6CB);
  final Color _darkBlue = const Color(0xFF1B4965);
  final Color _paleBlue = const Color(0xFFCAE9FF);
  final Color _mediumBlue = const Color(0xFF5FA8D3);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Department? department = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (department != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('department_email', _emailController.text.trim());
        await prefs.setString(
            'department_password', _passwordController.text.trim());

        Navigator.pushReplacementNamed(
          context,
          '/department_dashboard',
          arguments: department,
        );
      } else {
        setState(() {
          _errorMessage = 'Department not found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed. Please check your credentials.';
      });
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
          'Department Portal',
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
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                // Department Logo/Icon
                Icon(
                  Icons.account_balance,
                  size: 80,
                  color: _darkBlue,
                ),
                SizedBox(height: 20),
                Text(
                  'Department Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                ),
                SizedBox(height: 30),
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
                  validator: (value) => value!.isEmpty
                      ? 'Please enter your official email'
                      : null,
                ),
                SizedBox(height: 20),
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
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your password' : null,
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: _mediumBlue),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
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
                          'LOGIN',
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
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                SizedBox(height: 20),
                Divider(color: _teal.withOpacity(0.3)),
                SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/department_signup'),
                  child: Text(
                    'REGISTER NEW DEPARTMENT',
                    style: TextStyle(
                      color: _darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _darkBlue),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
