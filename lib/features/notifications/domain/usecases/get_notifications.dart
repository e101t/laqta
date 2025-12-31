import 'package:luqta/core/domain/result/result.dart';
import '../entities/notification_model.dart';
import '../repositories/notifications_repository.dart';

class GetNotifications {
  final NotificationsRepository _repository;

  const GetNotifications(this._repository);

  Future<Result<List<NotificationModel>>> call({required String userId}) {
    return _repository.getNotifications(userId: userId);
  }
}
