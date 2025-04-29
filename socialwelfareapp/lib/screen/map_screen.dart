import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socialwelfareapp/app_theme.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;

  List<Marker> _issueMarkers = [];
  // User? _currentUser;
  LatLng? _currentLocation;
  double _zoomLevel = 14.0;
  bool _isLoading = true;
  bool _locationPermissionDenied = false;
  bool _locationServiceEnabled = false;

  @override
  void initState() {
    super.initState();
    // _currentUser = FirebaseAuth.instance.currentUser;
    _mapController = MapController(); // Initialize immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    // _currentUser = FirebaseAuth.instance.currentUser;
    // await _determineCurrentLocation();
    // if (_currentUser != null) {
    //   await _loadUserIssues();
    // }
    await _determineCurrentLocation();
    await _loadAllIssues();
  }

  Future<void> _determineCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationServiceEnabled = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationPermissionDenied = true);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationPermissionDenied = true);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
        _locationServiceEnabled = true;
      });

      // Move map after ensuring everything is initialized
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentLocation != null) {
          _mapController.move(_currentLocation!, _zoomLevel);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _locationPermissionDenied = true;
      });
      debugPrint('Location error: $e');
    }
  }

  Future<void> _loadAllIssues() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('issues').get();

      List<Marker> markers = [];

      for (var doc in snapshot.docs) {
        try {
          var data = doc.data() as Map<String, dynamic>;
          String locationStr = data['location'];
          double lat, lon;

          if (locationStr.contains('Lat:')) {
            var parts = locationStr.split(', ');
            lat = double.parse(parts[0].replaceAll('Lat:', '').trim());
            lon = double.parse(parts[1].replaceAll('Lon:', '').trim());
          } else {
            var coords = locationStr.split(', ');
            lat = double.parse(coords[0]);
            lon = double.parse(coords[1]);
          }

          markers.add(
            Marker(
              point: LatLng(lat, lon),
              builder: (ctx) => GestureDetector(
                onTap: () => _showIssueDetails(context, data),
                child: Icon(
                  Icons.location_pin,
                  color: _getStatusColor(data['status'] ?? 'Pending'),
                  size: 40,
                ),
              ),
            ),
          );
        } catch (e) {
          debugPrint('Error parsing issue ${doc.id}: $e');
        }
      }

      setState(() => _issueMarkers = markers);
    } catch (e) {
      debugPrint('Load issues error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load issues. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'approved':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showIssueDetails(BuildContext context, Map<String, dynamic> issue) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                issue['title'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 16),
              if (issue['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    issue['imageUrl'],
                    headers: {"User-Agent": "SocialWelfareApp/1.0"},
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(Icons.broken_image, size: 40),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 16),
              _buildDetailRow(Icons.description, issue['description']),
              SizedBox(height: 8),
              _buildDetailRow(Icons.location_on, issue['location']),
              SizedBox(height: 8),
              _buildDetailRow(
                Icons.calendar_today,
                '${issue['timestamp'].toDate().toLocal()}',
              ),
              SizedBox(height: 8),
              _buildDetailRow(
                Icons.info,
                'Status: ${issue['status']}',
                statusColor: issue['status'] == 'Pending'
                    ? Colors.orange
                    : issue['status'] == 'Resolved'
                        ? Colors.green
                        : Colors.grey,
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CLOSE',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {Color? statusColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: statusColor ?? Colors.grey.shade800,
              fontWeight: statusColor != null ? FontWeight.bold : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Reported Issues',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : _locationPermissionDenied
              ? _buildPermissionDeniedView()
              : _buildMapView(),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 60, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Location Access Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please enable location services to view issues on the map',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Enable Location'),
              onPressed: _determineCurrentLocation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _currentLocation ?? LatLng(28.6139, 77.2090),
            zoom: _zoomLevel,
            interactiveFlags: InteractiveFlag.all,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.socialwelfareapp',
            ),
            MarkerLayer(
              markers: [
                ..._issueMarkers,
                if (_currentLocation != null)
                  Marker(
                    width: 50.0,
                    height: 50.0,
                    point: _currentLocation!,
                    builder: (ctx) => Container(
                      child: Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: "zoom_in",
                mini: true,
                backgroundColor: Colors.white,
                child: Icon(Icons.add, color: AppTheme.primaryColor),
                onPressed: () {
                  setState(() {
                    _zoomLevel += 1;
                    _mapController.move(_mapController.center, _zoomLevel);
                  });
                },
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "zoom_out",
                mini: true,
                backgroundColor: Colors.white,
                child: Icon(Icons.remove, color: AppTheme.primaryColor),
                onPressed: () {
                  setState(() {
                    _zoomLevel -= 1;
                    _mapController.move(_mapController.center, _zoomLevel);
                  });
                },
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "current_location",
                mini: true,
                backgroundColor: AppTheme.primaryColor,
                child: Icon(Icons.my_location, color: Colors.white),
                onPressed: _goToCurrentLocation,
              ),
            ],
          ),
        ),
        if (_issueMarkers.isNotEmpty)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                '${_issueMarkers.length} reported issues',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _goToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, _zoomLevel);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
