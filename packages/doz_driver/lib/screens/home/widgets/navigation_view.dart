import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../../providers/driver_provider.dart';
import '../../../providers/ride_provider.dart';

/// Live map showing driver's current position with route to pickup/dropoff.
class NavigationView extends StatefulWidget {
  final bool showPickupRoute;
  final bool showDropoffRoute;

  const NavigationView({
    super.key,
    this.showPickupRoute = false,
    this.showDropoffRoute = false,
  });

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  GoogleMapController? _mapController;

  Set<Marker> _buildMarkers(DriverProvider driver, RideProvider ride) {
    final markers = <Marker>{};
    markers.add(Marker(
      markerId: const MarkerId('driver'),
      position: LatLng(driver.currentLat, driver.currentLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(title: 'You'),
    ));
    if (ride.currentRide != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(ride.currentRide!.pickupLat, ride.currentRide!.pickupLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: ride.currentRide!.pickupAddress),
      ));
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(ride.currentRide!.dropoffLat, ride.currentRide!.dropoffLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: ride.currentRide!.dropoffAddress),
      ));
    }
    return markers;
  }

  Set<Polyline> _buildPolylines(RideProvider ride, DriverProvider driver) {
    if (ride.currentRide == null) return {};
    if (!widget.showPickupRoute && !widget.showDropoffRoute) return {};
    final polylines = <Polyline>{};
    if (widget.showPickupRoute) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route_to_pickup'),
        color: DozColors.primaryGreen,
        width: 4,
        points: [
          LatLng(driver.currentLat, driver.currentLng),
          LatLng(ride.currentRide!.pickupLat, ride.currentRide!.pickupLng),
        ],
      ));
    }
    if (widget.showDropoffRoute) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route_to_dropoff'),
        color: DozColors.primaryGreen,
        width: 4,
        points: [
          LatLng(driver.currentLat, driver.currentLng),
          LatLng(ride.currentRide!.dropoffLat, ride.currentRide!.dropoffLng),
        ],
      ));
    }
    return polylines;
  }

  void _centerOnDriver(DriverProvider driver) {
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(driver.currentLat, driver.currentLng), zoom: 15),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverProvider>();
    final ride = context.watch<RideProvider>();
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(driver.currentLat, driver.currentLng),
            zoom: AppConstants.defaultZoom,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            controller.setMapStyle(_darkMapStyle);
          },
          markers: _buildMarkers(driver, ride),
          polylines: _buildPolylines(ride, driver),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
          padding: const EdgeInsets.only(bottom: 200),
        ),
        Positioned(
          bottom: 220,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'center_map',
            onPressed: () => _centerOnDriver(driver),
            backgroundColor: DozColors.cardDark,
            child: const Icon(Icons.my_location, color: DozColors.primaryGreen, size: 20),
          ),
        ),
      ],
    );
  }
}

const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#212121"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}
]
''';
