import 'package:laqta/core/domain/result/result.dart';
import '../entities/notification_model.dart';
import '../repositories/notifications_repository.dart';

class CreateNotification {
  final NotificationsRepository _repository;

  const CreateNotification(this._repository);

  Future<Result<void>> call(NotificationModel notification) {
    return _repository.createNotification(notification);
  }
}
