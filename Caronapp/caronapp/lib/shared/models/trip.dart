class Trip {
  final String driverName;
  final String? avatarUrl;
  final String origin;
  final String destination;
  final String whenLabel;
  final int seats;
  final String? note;

  const Trip({
    required this.driverName,
    this.avatarUrl,
    required this.origin,
    required this.destination,
    required this.whenLabel,
    required this.seats,
    this.note,
  });
}
