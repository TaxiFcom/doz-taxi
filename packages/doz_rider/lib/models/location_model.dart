/// Simple location model for the rider app.
/// Represents a geographic point with address info.
class LocationModel {
  final double lat;
  final double lng;
  final String address;
  final String? addressEn;
  final String? placeId;

  const LocationModel({
    required this.lat,
    required this.lng,
    required this.address,
    this.addressEn,
    this.placeId,
  });

  @override
  String toString() => 'LocationModel($lat, $lng, $address)';
}
