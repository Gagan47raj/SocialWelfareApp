import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final auth = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Color scheme matching the login screen
  final Color primaryColor = const Color(0xFF3A3550);
  final Color secondaryColor = const Color(0xFF615D73);
  final Color tertiaryColor = const Color(0xFF898696);
  final Color lightColor = const Color(0xFFB0AEB9);
  final Color backgroundColor = const Color(0xFFD8D7DC);

  void signup() async {
    if (passCtrl.text != confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Passwords do not match",
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await auth.signup(emailCtrl.text, passCtrl.text);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Signup failed. Please try again.",
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: primaryColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Admin Registration",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Create Admin Account",
                            style: GoogleFonts.roboto(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Fill in the details to register as an administrator",
                            style: GoogleFonts.roboto(
                              color: secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "Email Address",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              color: secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: emailCtrl,
                            style: GoogleFonts.roboto(),
                            decoration: InputDecoration(
                              hintText: "Enter official email",
                              hintStyle: GoogleFonts.roboto(color: lightColor),
                              prefixIcon:
                                  Icon(Icons.email, color: tertiaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: lightColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: lightColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Password",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              color: secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: passCtrl,
                            style: GoogleFonts.roboto(),
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: "Create a strong password",
                              hintStyle: GoogleFonts.roboto(color: lightColor),
                              prefixIcon:
                                  Icon(Icons.lock, color: tertiaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: tertiaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: lightColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: lightColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Confirm Password",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              color: secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: confirmPassCtrl,
                            style: GoogleFonts.roboto(),
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              hintText: "Re-enter your password",
                              hintStyle: GoogleFonts.roboto(color: lightColor),
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: tertiaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: tertiaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: lightColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: lightColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: signup,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: primaryColor,
                              ),
                              child: Text(
                                "REGISTER ADMIN ACCOUNT",
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              "By registering, you agree to the terms of service",
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: tertiaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
