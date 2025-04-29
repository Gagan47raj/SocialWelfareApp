import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialwelfare_admin/screens/admin_analytics_screen.dart';
import '../services/auth_service.dart';
import 'issuedetail_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final Color primaryColor = const Color(0xFF3A3550);
  final Color secondaryColor = const Color(0xFF615D73);
  final Color tertiaryColor = const Color(0xFF898696);
  final Color lightColor = const Color(0xFFB0AEB9);
  final Color backgroundColor = const Color(0xFFD8D7DC);

  void _showDetails(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IssueDetailScreen(issueData: data, docId: doc.id),
      ),
    );
  }

  void logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void gotoanalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen()),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        chipColor = Colors.green.shade100;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        chipColor = Colors.red.shade100;
        icon = Icons.cancel;
        break;
      case 'resolved':
        chipColor = Colors.blue.shade100;
        icon = Icons.verified;
        break;
      default: // pending
        chipColor = Colors.orange.shade100;
        icon = Icons.access_time;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: primaryColor),
      label: Text(
        status.toUpperCase(),
        style: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
      ),
      backgroundColor: chipColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildIssueCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp?;
    final date = timestamp?.toDate();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetails(context, doc),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data['imageUrl'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        data['imageUrl'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.broken_image,
                              size: 40, color: tertiaryColor),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.photo, size: 40, color: tertiaryColor),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? 'No title',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['description'] ?? 'No description',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusChip(data['status'] ?? 'pending'),
                            if (date != null)
                              Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: tertiaryColor,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (data['location'] != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: tertiaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data['location'],
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: secondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssuesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('issues')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: lightColor),
                const SizedBox(height: 16),
                Text(
                  'No issues reported yet',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: () async {
            // Force refresh by doing nothing - stream will update automatically
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return _buildIssueCard(snapshot.data!.docs[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildDepartmentCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt = data['createdAt'] as Timestamp?;
    final categories = data['complaintCategories'] as List<dynamic>?;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['name'] ?? 'No name',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                Chip(
                  label: Text(
                    data['governmentLevel'] ?? 'N/A',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: backgroundColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Parent Ministry: ${data['parentMinistry'] ?? 'N/A'}',
              style: GoogleFonts.roboto(
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: tertiaryColor),
                const SizedBox(width: 8),
                Text(
                  data['email'] ?? 'No email',
                  style: GoogleFonts.roboto(
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: tertiaryColor),
                const SizedBox(width: 8),
                Text(
                  data['phone'] ?? 'No phone',
                  style: GoogleFonts.roboto(
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
            if (categories != null && categories.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Complaint Categories:',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: categories
                    .map((category) => Chip(
                          label: Text(
                            category.toString(),
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: backgroundColor,
                        ))
                    .toList(),
              ),
            ],
            if (createdAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Created: ${createdAt.toDate().toString().split(' ')[0]}',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: tertiaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('departments').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business, size: 64, color: lightColor),
                const SizedBox(height: 16),
                Text(
                  'No departments found',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildDepartmentCard(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
          );
        }

        if (!authSnapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          });
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(
              'Social Welfare Admin',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
            backgroundColor: primaryColor,
            actions: [
              IconButton(
                  icon: const Icon(Icons.analytics),
                  onPressed: () => gotoanalytics(context),
                  tooltip: 'Analytics',
                  color: Colors.white),
              IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => logout(context),
                  tooltip: 'Logout',
                  color: Colors.white),
            ],
          ),
          body:
              _currentIndex == 0 ? _buildIssuesList() : _buildDepartmentsList(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: lightColor, width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.assignment),
                  label: 'Issues',
                  backgroundColor: backgroundColor,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.business),
                  label: 'Departments',
                  backgroundColor: backgroundColor,
                ),
              ],
              selectedItemColor: primaryColor,
              unselectedItemColor: tertiaryColor,
              selectedLabelStyle:
                  GoogleFonts.roboto(fontWeight: FontWeight.w500),
              unselectedLabelStyle: GoogleFonts.roboto(),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
            ),
          ),
        );
      },
    );
  }
}
