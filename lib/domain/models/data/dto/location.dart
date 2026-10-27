class Location {
  final double longitude;
  final double latitude;
  final bool? isLocationFromMock;

  const Location({
    required this.longitude,
    required this.latitude,
    this.isLocationFromMock,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      longitude: json['long'],
      latitude: json['lat'],
      isLocationFromMock: json['isLocationFromMock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'long': longitude,
      'lat': latitude,
      'isLocationFromMock': isLocationFromMock,
    };
  }
}
