import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../models/event.dart';
import '../services/directions_service.dart';

class MapScreen extends StatefulWidget {
  final List<Event> events;

  MapScreen(this.events);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _setEventMarkers();
  }

  Future<void> _loadCurrentLocation() async {
    final locationService = LocationService();
    final locationData = await locationService.getCurrentLocation();
    if (locationData != null) {
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      });
    }
  }

  void _setEventMarkers() {
    setState(() {
      _markers = widget.events.map((event) {
        return Marker(
          markerId: MarkerId(event.title),
          position: LatLng(event.latitude, event.longitude),
          infoWindow: InfoWindow(
            title: event.title,
            snippet: event.location,
          ),
          onTap: () {
            _drawRoute(LatLng(event.latitude, event.longitude));
          },
        );
      }).toSet();
    });
  }

  Future<void> _drawRoute(LatLng destination) async {
    final directionsService = DirectionsService('AIzaSyBB_OtOooJUHS8jJE4U1RssPXs5nLJGzTs');
    final directions = await directionsService.getDirections(
      _currentLocation!,
      destination,
    );

    if (directions != null) {
      final points = directions['routes'][0]['overview_polyline']['points'];
      final polylineCoordinates = _decodePolyline(points);

      setState(() {
        _polylines.clear(); 
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 4,
        ));
      });
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    final List<LatLng> coordinates = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      coordinates.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return coordinates;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Map')),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 14,
              ),
              markers: _markers,
              polylines: _polylines,
            ),
    );
  }
}
