import 'package:laqta/core/domain/result/result.dart';
import '../repositories/notifications_repository.dart';

class DeleteNotification {
  final NotificationsRepository _repository;

  const DeleteNotification(this._repository);

  Future<Result<void>> call(String notificationId) {
    return _repository.deleteNotification(notificationId);
  }
}
