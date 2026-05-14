import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../services/directions_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final LocationService _locationService = LocationService();
  final DirectionsService _directionsService = DirectionsService();

  LatLng? _currentLocation;
  final Set<Polyline> _polylines = {};
  double _desiredDistanceKm = 5.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> _generateRoute() async {
    if (_currentLocation == null) return;

    setState(() {
      _isLoading = true;
      _polylines.clear();
    });

    try {
      final route = await _directionsService.getWalkingRoute(
        _currentLocation!,
        _desiredDistanceKm,
      );

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('walking_route'),
            points: route,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
      
      // Fit map to polyline
      _fitMapToPolyline(route);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating route: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fitMapToPolyline(List<LatLng> points) {
    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50.0, // padding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_currentLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 14,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              polylines: _polylines,
            )
          else
            const Center(child: CircularProgressIndicator()),
          
          // Controls Overlay
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Walking Route Generator',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.directions_walk),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            value: _desiredDistanceKm,
                            min: 1.0,
                            max: 20.0,
                            divisions: 19,
                            label: '${_desiredDistanceKm.toStringAsFixed(1)} km',
                            onChanged: (value) {
                              setState(() {
                                _desiredDistanceKm = value;
                              });
                            },
                          ),
                        ),
                        Text('${_desiredDistanceKm.toStringAsFixed(1)} km'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _generateRoute,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Generate Route'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
