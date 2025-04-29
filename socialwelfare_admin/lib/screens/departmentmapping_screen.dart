import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DepartmentMappingScreen extends StatefulWidget {
  final Map<String, dynamic> issueData;
  final String docId;

  const DepartmentMappingScreen({
    super.key,
    required this.issueData,
    required this.docId,
  });

  @override
  State<DepartmentMappingScreen> createState() =>
      _DepartmentMappingScreenState();
}

class _DepartmentMappingScreenState extends State<DepartmentMappingScreen> {
  String? _selectedDepartment;
  bool _isProcessing = false;
  final List<String> _departments = [
    'Public Works',
    'Health Department',
    'Education',
    'Transportation',
    'Sanitation',
    'Public Safety',
    'Environmental',
    'Housing',
  ];

  // This could be replaced with an ML API call
  String? _suggestedDepartment;

  @override
  void initState() {
    super.initState();
    // Simulate ML/AI department suggestion
    _suggestDepartment();
  }

  void _suggestDepartment() {
    // This is a mock implementation - replace with actual ML API call
    final description = widget.issueData['description']?.toLowerCase() ?? '';

    if (description.contains('road') || description.contains('pothole')) {
      _suggestedDepartment = 'Public Works';
    } else if (description.contains('health') ||
        description.contains('hospital')) {
      _suggestedDepartment = 'Health Department';
    } else if (description.contains('school') ||
        description.contains('education')) {
      _suggestedDepartment = 'Education';
    } else if (description.contains('garbage') ||
        description.contains('waste')) {
      _suggestedDepartment = 'Sanitation';
    }

    if (_suggestedDepartment != null) {
      _selectedDepartment = _suggestedDepartment;
    }

    if (mounted) setState(() {});
  }

  Future<void> _assignToDepartment() async {
    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await FirebaseFirestore.instance
          .collection('issues')
          .doc(widget.docId)
          .update({
        'assignedDepartment': _selectedDepartment,
        'assignedAt': FieldValue.serverTimestamp(),
      });

      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assigned to $_selectedDepartment')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign to Department'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Issue: ${widget.issueData['title']}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            if (_suggestedDepartment != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggested Department:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _suggestedDepartment!,
                    style: const TextStyle(color: Colors.green, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            const Text(
              'Select Department:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              items: _departments
                  .map((dept) => DropdownMenuItem(
                        value: dept,
                        child: Text(dept),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedDepartment = value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select a department',
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _assignToDepartment,
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text('Assign to Department'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
