import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late gmaps.GoogleMapController mapController;
  gmaps.LatLng? _initialPosition;
  Set<gmaps.Marker> _markers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _determinePosition(); // Automatically fetch location on start
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _initialPosition = gmaps.LatLng(position.latitude, position.longitude);
        _markers.clear(); // clear previous marker if any
        _markers.add(
          gmaps.Marker(
            markerId: const gmaps.MarkerId('currentLocation'),
            position: _initialPosition!,
            infoWindow: const gmaps.InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error determining location: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          _isLoading || _initialPosition == null
              ? const Center(child: CircularProgressIndicator())
              : gmaps.GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: gmaps.CameraPosition(
                  target: _initialPosition!,
                  zoom: 14.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: gmaps.MapType.normal,
              ),
          if (!_isLoading && _initialPosition != null)
            Positioned(
              bottom: 20,
              left: 20,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _determinePosition();
                },
                child: const Icon(Icons.my_location),
              ),
            ),
        ],
      ),
    );
  }
}
