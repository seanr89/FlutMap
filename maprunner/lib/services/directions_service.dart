import 'dart:convert';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DirectionsService {
  final String apiKey = "YOUR_API_KEY_HERE";

  Future<List<LatLng>> getWalkingRoute(LatLng start, double distanceKm) async {
    // Generate waypoints for a loop
    // Total distance D is roughly the perimeter of a shape.
    // For a triangle loop, each side is ~D/3.
    // Radius R to a vertex from center (start) for equilateral triangle side s: R = s / sqrt(3)
    // So R = (D/3) / sqrt(3) = D / (3 * sqrt(3))
    
    double side = distanceKm / 3.0;
    double radius = side / sqrt(3);
    
    // Convert km to degrees approximately (1 deg ~ 111 km)
    double radiusDeg = radius / 111.0;
    
    List<LatLng> waypoints = [];
    double baseAngle = Random().nextDouble() * 2 * pi;
    
    for (int i = 0; i < 2; i++) {
      double angle = baseAngle + (i + 1) * (2 * pi / 3);
      double lat = start.latitude + radiusDeg * cos(angle);
      double lng = start.longitude + radiusDeg * sin(angle) / cos(start.latitude * pi / 180);
      waypoints.add(LatLng(lat, lng));
    }

    String origin = "${start.latitude},${start.longitude}";
    String destination = origin;
    String waypointsStr = waypoints.map((p) => "${p.latitude},${p.longitude}").join('|');

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=$origin&'
      'destination=$destination&'
      'waypoints=$waypointsStr&'
      'mode=walking&'
      'key=$apiKey'
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        String encodedPolyline = data['routes'][0]['overview_polyline']['points'];
        return _decodePolyline(encodedPolyline);
      } else {
        throw Exception("Directions API Error: ${data['status']} - ${data['error_message'] ?? ''}");
      }
    } else {
      throw Exception("Failed to fetch directions");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<PointLatLng> result = PolylinePoints.decodePolyline(encoded);
    return result.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }
}
