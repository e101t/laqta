import 'package:luqta/features/booking/data/dtos/booking_dto.dart';
import 'package:luqta/features/dashboard/domain/entities/dashboard_booking.dart';

class DashboardMapper {
  static DashboardBooking toDomain(BookingDto dto, String customerName) {
    return DashboardBooking(
      id: dto.id,
      customerName: customerName,
      type: dto.type,
      date: DateTime.parse(dto.date),
      time: dto.time,
      status: dto.status,
      price: dto.price,
    );
  }
}
