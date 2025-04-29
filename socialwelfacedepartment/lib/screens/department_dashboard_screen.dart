import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/department.dart';
import '../services/department_auth_service.dart';

class DepartmentDashboardScreen extends StatefulWidget {
  final Department department;

  const DepartmentDashboardScreen({Key? key, required this.department})
      : super(key: key);

  @override
  _DepartmentDashboardScreenState createState() =>
      _DepartmentDashboardScreenState();
}

class _DepartmentDashboardScreenState extends State<DepartmentDashboardScreen> {
  final DepartmentAuthService _authService = DepartmentAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Color palette
  final Color _lightBlue = const Color(0xFFBEE9E8);
  final Color _teal = const Color(0xFF62B6CB);
  final Color _darkBlue = const Color(0xFF1B4965);
  final Color _paleBlue = const Color(0xFFCAE9FF);
  final Color _mediumBlue = const Color(0xFF5FA8D3);

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBlue,
      appBar: AppBar(
        title: Text(
          '${widget.department.name} Dashboard',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _darkBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacementNamed(context, '/department_login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // Header Card
            _buildHeaderCard(),

            // Stats Row with real data
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildStatsRow(),
            ),

            // Issues List
            Expanded(
              child: _buildIssuesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: _paleBlue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment, color: _darkBlue, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Assigned Complaints',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _darkBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'View and manage complaints assigned to your department',
                style: TextStyle(
                  color: _darkBlue.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatusCountCard(
            'pending', 'Pending', Icons.access_time, Colors.orange),
        const SizedBox(width: 10),
        _buildStatusCountCard(
            'in progress', 'In Progress', Icons.build, Colors.blue),
        const SizedBox(width: 10),
        _buildStatusCountCard(
            'resolved', 'Resolved', Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _buildStatusCountCard(
      String status, String title, IconData icon, Color color) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('issues')
            .where('assignedDepartmentId', isEqualTo: widget.department.id)
            .where('status', isEqualTo: status)
            .snapshots(),
        builder: (context, snapshot) {
          int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: _darkBlue.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIssuesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('issues')
          .where('assignedDepartmentId', isEqualTo: widget.department.id)
          .where('status', whereIn: ['approved', 'in progress'])
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_mediumBlue),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var issue = snapshot.data!.docs[index];
            return IssueCard(
              issue: issue.data() as Map<String, dynamic>,
              issueId: issue.id,
              departmentId: widget.department.id,
              colorScheme: {
                'lightBlue': _lightBlue,
                'teal': _teal,
                'darkBlue': _darkBlue,
                'paleBlue': _paleBlue,
                'mediumBlue': _mediumBlue,
              },
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error loading issues',
            style: TextStyle(
              color: _darkBlue,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _mediumBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in, color: _teal, size: 48),
          const SizedBox(height: 16),
          Text(
            'No issues assigned yet',
            style: TextStyle(
              color: _darkBlue,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All caught up! Check back later for new issues.',
            style: TextStyle(
              color: _darkBlue.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class IssueCard extends StatelessWidget {
  final Map<String, dynamic> issue;
  final String issueId;
  final String departmentId;
  final Map<String, Color> colorScheme;

  const IssueCard({
    Key? key,
    required this.issue,
    required this.issueId,
    required this.departmentId,
    required this.colorScheme,
  }) : super(key: key);

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(issue['userId'])
          .get(),
      builder: (context, userSnapshot) {
        String userName = 'Unknown';
        String formattedDate = 'Date Unknown';

        if (userSnapshot.connectionState == ConnectionState.done) {
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            // If user document exists, get the name
            var userData = userSnapshot.data!.data() as Map<String, dynamic>;
            userName = userData['name'] ?? 'Unknown';
            print('User Name: $userName'); // Print the name to console
          } else {
            print('User not found for ID: ${issue['userId']}');
          }
        }

        if (issue['timestamp'] != null) {
          formattedDate = _formatTimestamp(issue['timestamp']);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (issue['imageUrl'] != null && issue['imageUrl'].isNotEmpty)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    children: [
                      Image.network(
                        issue['imageUrl'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme['darkBlue']!.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            issue['status']?.toUpperCase() ?? 'UNKNOWN',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            issue['title'] ?? 'No Title',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme['darkBlue'],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(issue['status'])
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(issue['status']),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            issue['status'] ?? 'Unknown',
                            style: TextStyle(
                              color: _getStatusColor(issue['status']),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      issue['description'] ?? 'No Description',
                      style: TextStyle(
                        color: colorScheme['darkBlue']!.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Metadata
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 16, color: colorScheme['teal']),
                        const SizedBox(width: 6),
                        Text(
                          userName,
                          style: TextStyle(
                            color: colorScheme['darkBlue']!.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.calendar_today,
                            size: 16, color: colorScheme['teal']),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: colorScheme['darkBlue']!.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showUpdateDialog(context),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Update Status'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: colorScheme['mediumBlue'],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return colorScheme['teal']!;
      default:
        return Colors.grey;
    }
  }

  void _showUpdateDialog(BuildContext context) {
    TextEditingController _remarksController = TextEditingController();
    String _selectedStatus = issue['status'] ?? 'approved';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Issue Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme['darkBlue'],
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(color: colorScheme['darkBlue']),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme['teal']!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme['teal']!),
                  ),
                  filled: true,
                  fillColor: colorScheme['paleBlue'],
                ),
                dropdownColor: colorScheme['paleBlue'],
                items: ['approved', 'pending', 'resolved']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            status,
                            style: TextStyle(color: colorScheme['darkBlue']),
                          ),
                        ))
                    .toList(),
                onChanged: (value) => _selectedStatus = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: InputDecoration(
                  labelText: 'Remarks/Resolution Details',
                  labelStyle: TextStyle(color: colorScheme['darkBlue']),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme['teal']!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme['teal']!),
                  ),
                  filled: true,
                  fillColor: colorScheme['paleBlue'],
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: colorScheme['darkBlue']),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('issues')
                          .doc(issueId)
                          .update({
                        'status': _selectedStatus,
                        'remarks': _remarksController.text,
                        'updatedAt': FieldValue.serverTimestamp(),
                        'updatedBy': departmentId,
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Issue updated successfully'),
                          backgroundColor: colorScheme['teal'],
                        ),
                      );
                    },
                    child: const Text('Update'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: colorScheme['mediumBlue'],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
