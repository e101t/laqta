import 'package:laqta/core/domain/result/result.dart';
import '../repositories/notifications_repository.dart';

class MarkAllNotificationsRead {
  final NotificationsRepository _repository;

  const MarkAllNotificationsRead(this._repository);

  Future<Result<void>> call({
    required String userId,
    required List<String> notificationIds,
  }) {
    return _repository.markAllAsRead(
      userId: userId,
      notificationIds: notificationIds,
    );
  }
}
