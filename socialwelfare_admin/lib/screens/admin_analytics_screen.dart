import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  int total = 0;
  int resolved = 0;
  int pending = 0;
  int rejected = 0;
  Map<String, int> departmentCounts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    setState(() => isLoading = true);

    final querySnapshot =
        await FirebaseFirestore.instance.collection('issues').get();

    int totalCount = 0;
    int resolvedCount = 0;
    int pendingCount = 0;
    int rejectedCount = 0;
    Map<String, int> deptCounts = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      totalCount++;

      final status = data['status']?.toString().toLowerCase() ?? 'pending';
      if (status == 'resolved') {
        resolvedCount++;
      } else if (status == 'pending') {
        pendingCount++;
      } else if (status == 'rejected') {
        rejectedCount++;
      }

      final dept = data['assignedDepartment']?.toString() ?? 'Unknown';
      deptCounts[dept] = (deptCounts[dept] ?? 0) + 1;
    }

    setState(() {
      total = totalCount;
      resolved = resolvedCount;
      pending = pendingCount;
      rejected = rejectedCount;
      departmentCounts = deptCounts;
      isLoading = false;
    });
  }

  List<ChartData> _getStatusChartData() {
    return [
      ChartData('Resolved', resolved, Colors.green),
      ChartData('Pending', pending, Colors.orange),
      ChartData('Rejected', rejected, Colors.red),
    ];
  }

  List<ChartData> _getDepartmentChartData() {
    return departmentCounts.entries.map((entry) {
      return ChartData(
        entry.key,
        entry.value,
        Colors.primaries[entry.key.length % Colors.primaries.length],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchAnalytics,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade50,
                    Colors.grey.shade100,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        _buildSummaryCard(
                          'Total',
                          total.toString(),
                          Icons.inventory,
                          Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryCard(
                          'Resolved',
                          resolved.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryCard(
                          'Pending',
                          pending.toString(),
                          Icons.access_time,
                          Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryCard(
                          'Rejected',
                          rejected.toString(),
                          Icons.cancel,
                          Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status Chart
                    const Text(
                      'Complaints by Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SfCircularChart(
                        series: <CircularSeries>[
                          PieSeries<ChartData, String>(
                            dataSource: _getStatusChartData(),
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            pointColorMapper: (ChartData data, _) => data.color,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                            ),
                            radius: '80%',
                          ),
                        ],
                        legend: Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Department Chart
                    const Text(
                      'Complaints by Department',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SfCircularChart(
                        series: <CircularSeries>[
                          DoughnutSeries<ChartData, String>(
                            dataSource: _getDepartmentChartData(),
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            pointColorMapper: (ChartData data, _) => data.color,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                            ),
                            innerRadius: '60%',
                          ),
                        ],
                        legend: Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Department List
                    const Text(
                      'Department Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...departmentCounts.entries.map((entry) {
                      final percentage =
                          ((entry.value / total) * 100).toStringAsFixed(1);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Card(
                          elevation: 1,
                          child: ListTile(
                            title: Text(entry.key),
                            trailing: Text('$entry.value ($percentage%)'),
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.primaries[
                                    entry.key.length % Colors.primaries.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String x;
  final int y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}
