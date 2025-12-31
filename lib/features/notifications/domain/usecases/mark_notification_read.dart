import 'package:luqta/core/domain/result/result.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationRead {
  final NotificationsRepository _repository;

  const MarkNotificationRead(this._repository);

  Future<Result<void>> call(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
