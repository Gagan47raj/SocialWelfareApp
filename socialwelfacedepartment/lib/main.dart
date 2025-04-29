import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialwelfacedepartment/firebase_options.dart';
import 'model/department.dart';
import 'screens/department_dashboard_screen.dart';
import 'screens/department_login_screen.dart';
import 'screens/department_signup_screen.dart';
import 'services/department_auth_service.dart'; // if needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('department_email');
    final password = prefs.getString('department_password');

    if (email != null && password != null) {
      // Optional: Try auto login if needed
      final authService = DepartmentAuthService();
      Department? department = await authService.login(email, password);

      if (department != null) {
        return DepartmentDashboardScreen(department: department);
      }
    }

    return DepartmentLoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Welfare App',
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/department_signup':
            return MaterialPageRoute(builder: (_) => DepartmentSignupScreen());
          case '/department_dashboard':
            final department = settings.arguments as Department?;
            if (department == null) {
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(child: Text('Department data missing')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => DepartmentDashboardScreen(department: department),
            );
          default:
            return MaterialPageRoute(builder: (_) => DepartmentLoginScreen());
        }
      },
    );
  }
}
