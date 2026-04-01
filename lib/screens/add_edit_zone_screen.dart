import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/safe_zone.dart';
import '../services/safe_zone_service.dart';
import '../services/location_service.dart';

class AddEditZoneScreen extends StatefulWidget {
  final SafeZone? zone;

  const AddEditZoneScreen({super.key, this.zone});

  @override
  State<AddEditZoneScreen> createState() => _AddEditZoneScreenState();
}

class _AddEditZoneScreenState extends State<AddEditZoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _radiusController = TextEditingController();
  final _zoneService = SafeZoneService();
  final _locationService = LocationService();
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(0, 0);
  double _radius = 100.0;
  bool _isLoading = false;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.zone != null) {
      _nameController.text = widget.zone!.name;
      _radiusController.text = widget.zone!.radius.toStringAsFixed(0);
      _selectedLocation = LatLng(
        widget.zone!.latitude,
        widget.zone!.longitude,
      );
      _radius = widget.zone!.radius;
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_selectedLocation),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _radiusController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _saveZone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final zone = SafeZone(
        id: widget.zone?.id,
        name: _nameController.text.trim(),
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        radius: _radius,
      );

      if (widget.zone == null) {
        await _zoneService.addSafeZone(zone);
      } else {
        await _zoneService.updateSafeZone(zone);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Set<Circle> _getCircles() {
    return {
      Circle(
        circleId: const CircleId('safe_zone'),
        center: _selectedLocation,
        radius: _radius,
        fillColor: Colors.green.withOpacity(0.2),
        strokeColor: Colors.green,
        strokeWidth: 2,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.zone == null ? 'Add Safe Zone' : 'Edit Safe Zone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'Use Current Location',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation,
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  setState(() => _isMapReady = true);
                },
                onTap: (LatLng location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('zone_center'),
                    position: _selectedLocation,
                    draggable: true,
                    onDragEnd: (LatLng newPosition) {
                      setState(() {
                        _selectedLocation = newPosition;
                      });
                    },
                  ),
                },
                circles: _getCircles(),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
            ),
            // Form
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Zone Name *',
                        prefixIcon: Icon(Icons.label),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a zone name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _radiusController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Radius (meters) *',
                        prefixIcon: Icon(Icons.radio_button_checked),
                        border: OutlineInputBorder(),
                        suffixText: 'meters',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a radius';
                        }
                        final radius = double.tryParse(value);
                        if (radius == null || radius <= 0) {
                          return 'Please enter a valid radius';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final radius = double.tryParse(value);
                        if (radius != null && radius > 0) {
                          setState(() => _radius = radius);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tap on map to set zone center, or drag the marker',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveZone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save Zone',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
