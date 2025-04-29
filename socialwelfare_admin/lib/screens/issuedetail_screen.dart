import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class IssueDetailScreen extends StatefulWidget {
  final Map<String, dynamic> issueData;
  final String docId;

  const IssueDetailScreen({
    super.key,
    required this.issueData,
    required this.docId,
  });

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final TextEditingController _rejectionReasonController =
      TextEditingController();
  bool _isProcessing = false;
  String? _selectedStatus;
  String _address = 'Loading address...';
  final Color primaryColor = const Color(0xFF3A3550);
  final Color secondaryColor = const Color(0xFF615D73);
  final Color tertiaryColor = const Color(0xFF898696);
  final Color lightColor = const Color(0xFFB0AEB9);
  final Color backgroundColor = const Color(0xFFD8D7DC);

  @override
  void initState() {
    super.initState();
    _convertToAddress();
  }

  Future<void> _convertToAddress() async {
    try {
      final location = widget.issueData['location'];
      if (location == null || location.isEmpty) {
        setState(() => _address = 'No location data');
        return;
      }

      List<String> parts = location.split(',');
      if (parts.length != 2) {
        setState(() => _address = 'Invalid location format');
        return;
      }

      double? latitude = double.tryParse(parts[0].trim());
      double? longitude = double.tryParse(parts[1].trim());

      if (latitude == null || longitude == null) {
        setState(() => _address = 'Invalid coordinates');
        return;
      }

      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address = [
            place.street,
            place.subLocality,
            place.locality,
            place.postalCode,
            place.country
          ].where((part) => part != null && part.isNotEmpty).join(', ');
        });
      } else {
        setState(() => _address =
            '(${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})');
      }
    } catch (e) {
      setState(() => _address = 'Could not fetch address');
    }
  }

  Future<void> _showDepartmentAssignmentDialog() async {
    final departmentsSnapshot =
        await FirebaseFirestore.instance.collection('departments').get();

    if (departmentsSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No departments available',
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: primaryColor,
        ),
      );
      return;
    }

    String? selectedDepartmentId;
    String? selectedDepartmentName;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Assign to Department',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select a department to assign this complaint:',
                      style: GoogleFonts.roboto(),
                    ),
                    const SizedBox(height: 16),
                    ...departmentsSnapshot.docs.map((department) {
                      final data = department.data();
                      final name = data['name'] ?? 'Unnamed Department';
                      final id = department.id;
                      final isSelected = selectedDepartmentId == id;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isSelected ? backgroundColor : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: lightColor),
                        ),
                        child: ListTile(
                          title: Text(
                            name,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            data['parentMinistry'] ?? '',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: secondaryColor,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check, color: primaryColor)
                              : null,
                          onTap: () {
                            setState(() {
                              selectedDepartmentId = id;
                              selectedDepartmentName = name;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.roboto(color: primaryColor),
                ),
              ),
              ElevatedButton(
                onPressed: selectedDepartmentId == null
                    ? null
                    : () async {
                        setState(() => _isProcessing = true);
                        Navigator.pop(context);

                        try {
                          await FirebaseFirestore.instance
                              .collection('issues')
                              .doc(widget.docId)
                              .update({
                            'assignedDepartment': selectedDepartmentName,
                            'assignedDepartmentId': selectedDepartmentId,
                            'status': 'approved',
                          });

                          setState(() {
                            widget.issueData['assignedDepartment'] =
                                selectedDepartmentName;
                            widget.issueData['assignedDepartmentId'] =
                                selectedDepartmentId;
                            widget.issueData['status'] = 'approved';
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Assigned to $selectedDepartmentName',
                                style: GoogleFonts.roboto(),
                              ),
                              backgroundColor: primaryColor,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error assigning department',
                                style: GoogleFonts.roboto(),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          setState(() => _isProcessing = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: Text(
                  'Assign',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  final List<String> _statusOptions = [
    'processing',
    'working on it',
    'problem solved',
    'completed'
  ];

  Future<void> _updateStatus(String status, {String? rejectionReason}) async {
    setState(() => _isProcessing = true);

    try {
      final updateData = <String, dynamic>{
        'status': status,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      };

      if (status == 'completed' || status == 'rejected') {
        updateData['resolvedAt'] = FieldValue.serverTimestamp();
      }

      await FirebaseFirestore.instance
          .collection('issues')
          .doc(widget.docId)
          .update(updateData);

      if (status == 'approved') {
        _showDepartmentAssignmentDialog();
      } else {
        setState(() {
          widget.issueData['status'] = status;
          if (rejectionReason != null) {
            widget.issueData['rejectionReason'] = rejectionReason;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status updated to $status',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: primaryColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating status',
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rejection Reason',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _rejectionReasonController,
              decoration: InputDecoration(
                labelText: 'Reason for rejection',
                labelStyle: GoogleFonts.roboto(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: lightColor),
                ),
              ),
              maxLines: 3,
              style: GoogleFonts.roboto(),
            ),
            const SizedBox(height: 10),
            Text(
              'This reason will be shared with the user',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: tertiaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(color: primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_rejectionReasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please enter rejection reason',
                      style: GoogleFonts.roboto(),
                    ),
                    backgroundColor: primaryColor,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _updateStatus(
                'rejected',
                rejectionReason: _rejectionReasonController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: Text(
              'Submit Rejection',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Update Status',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: _statusOptions.map((status) {
                return RadioListTile<String>(
                  title: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.roboto(),
                  ),
                  value: status,
                  groupValue: _selectedStatus ?? widget.issueData['status'],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                  },
                  activeColor: primaryColor,
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.roboto(color: primaryColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_selectedStatus != null) {
                    Navigator.pop(context);
                    _updateStatus(_selectedStatus!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: Text(
                  'Update Status',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showImageFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Issue Image'),
            backgroundColor: primaryColor,
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: PhotoView(
              imageProvider: NetworkImage(widget.issueData['imageUrl']),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      backgroundColor: _getStatusColor(status),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = widget.issueData['status']?.toString().toLowerCase();
    final isPending = currentStatus == 'pending';
    final isApproved = currentStatus == 'approved';
    final isCompleted = currentStatus == 'completed';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Issue Details',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (isPending)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => _updateStatus('approved'),
              tooltip: 'Approve',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (widget.issueData['imageUrl'] != null)
              GestureDetector(
                onTap: _showImageFullScreen,
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.issueData['imageUrl'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: backgroundColor,
                          child: Icon(
                            Icons.broken_image,
                            size: 60,
                            color: tertiaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Issue Details Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.issueData['title'] ?? 'No title',
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: tertiaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Posted on: ${widget.issueData['timestamp']?.toDate().toString().substring(0, 16) ?? 'Unknown date'}',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description:',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.issueData['description'] ?? 'No description',
                      style: GoogleFonts.roboto(
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isApproved || !isPending)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned Department:',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.issueData['assignedDepartment'] ??
                                'Not assigned',
                            style: GoogleFonts.roboto(
                              color: secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location:',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _address,
                          style: GoogleFonts.roboto(
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Status:',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        _buildStatusChip(currentStatus ?? 'pending'),
                      ],
                    ),
                    if (isApproved && !isCompleted) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing
                              ? null
                              : _showDepartmentAssignmentDialog,
                          icon: Icon(Icons.edit, color: primaryColor),
                          label: Text(
                            'Edit Department Assignment',
                            style: GoogleFonts.roboto(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: backgroundColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: primaryColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Rejection Reason (if rejected)
            if (currentStatus == 'rejected' &&
                widget.issueData['rejectionReason'] != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rejection Reason:',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.issueData['rejectionReason'],
                        style: GoogleFonts.roboto(),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  // Approve/Reject buttons for pending issues
                  if (isPending)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _isProcessing ? null : _showRejectionDialog,
                            icon: Icon(Icons.close, color: Colors.red),
                            label: Text(
                              'Reject',
                              style: GoogleFonts.roboto(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[50],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : _showDepartmentAssignmentDialog,
                            icon: Icon(Icons.check, color: Colors.green),
                            label: Text(
                              'Approve & Assign',
                              style: GoogleFonts.roboto(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[50],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Status update button for approved but not completed issues
                  if ((isApproved || _statusOptions.contains(currentStatus)) &&
                      !isCompleted) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isProcessing ? null : _showStatusUpdateDialog,
                        icon: Icon(Icons.update, color: primaryColor),
                        label: Text(
                          'Update Status',
                          style: GoogleFonts.roboto(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: primaryColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.purple;
      case 'processing':
        return Colors.blue;
      case 'working on it':
        return Colors.orange;
      case 'problem solved':
        return Colors.teal;
      default: // pending
        return Colors.orange;
    }
  }
}
