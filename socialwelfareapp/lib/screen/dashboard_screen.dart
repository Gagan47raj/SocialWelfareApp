import 'package:flutter/material.dart';
import 'package:socialwelfareapp/app_theme.dart';
import 'home_screen.dart';
import 'issue_report_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'package:socialwelfareapp/service/auth_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _screens = [
    HomeScreen(),
    IssueReportScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
            ),
            elevation: 10,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedIndex == 0
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: Icon(Icons.home_outlined, size: 26),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                  child: Icon(Icons.home_filled, size: 26),
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedIndex == 1
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: Icon(Icons.add_circle_outline, size: 26),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                  child: Icon(Icons.add_circle, size: 26),
                ),
                label: "Upload",
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedIndex == 2
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: Icon(Icons.map_outlined, size: 26),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                  child: Icon(Icons.map, size: 26),
                ),
                label: "Map",
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedIndex == 3
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: Icon(Icons.person_outline, size: 26),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                  child: Icon(Icons.person, size: 26),
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
