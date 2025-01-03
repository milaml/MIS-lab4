class Event {
  final String title;
  final DateTime dateTime;
  final String location;
  final double latitude;
  final double longitude;

  Event({
    required this.title,
    required this.dateTime,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      dateTime: DateTime.parse(json['dateTime']),
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
