import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/ride_provider.dart';
import 'nearby_drivers.dart';

/// Full-screen Google Maps widget with current location and driver markers.
class MapView extends StatefulWidget {
  final LatLng? pickupPoint;
  final LatLng? dropoffPoint;
  final bool showRoute;
  final bool showNearbyDrivers;
  final void Function(GoogleMapController)? onMapCreated;

  const MapView({
    super.key,
    this.pickupPoint,
    this.dropoffPoint,
    this.showRoute = false,
    this.showNearbyDrivers = true,
    this.onMapCreated,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  static const _darkMapStyle = [
    {"elementType":"geometry","stylers":[{"color":"#1a1a2e"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#9CA3AF"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#1a1a2e"}]},
    {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#374151"}]},
    {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#6B7280"}]},
    {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1F2937"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#16213E"}]},
    {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#1F2937"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#374151"}]},
    {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#1F2937"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#111827"}]}
  ];

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  @override
  void didUpdateWidget(MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickupPoint != widget.pickupPoint ||
        oldWidget.dropoffPoint != widget.dropoffPoint) {
      _buildMarkers();
    }
  }

  void _buildMarkers() {
    setState(() {
      _markers.clear();
      _polylines.clear();

      if (widget.pickupPoint != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: widget.pickupPoint!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: const InfoWindow(title: 'Pickup'),
          ),
        );
      }

      if (widget.dropoffPoint != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('dropoff'),
            position: widget.dropoffPoint!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: const InfoWindow(title: 'Dropoff'),
          ),
        );
      }

      if (widget.showRoute &&
          widget.pickupPoint != null &&
          widget.dropoffPoint != null) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: [widget.pickupPoint!, widget.dropoffPoint!],
            color: DozColors.mapRoute,
            width: 4,
            patterns: const [],
          ),
        );
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    controller.setMapStyle(_darkMapStyle.toString());
    widget.onMapCreated?.call(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (_, location, __) {
        final lat = location.lat;
        final lng = location.lng;

        return GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng),
            zoom: AppConstants.defaultZoom,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          buildingsEnabled: false,
        );
      },
    );
  }
}
