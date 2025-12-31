class DashboardBooking {
  final String id;
  final String customerName;
  final String type;
  final DateTime date;
  final String time;
  final String status;
  final double price;

  const DashboardBooking({
    required this.id,
    required this.customerName,
    required this.type,
    required this.date,
    required this.time,
    required this.status,
    required this.price,
  });
}
