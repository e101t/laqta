import 'package:mocktail/mocktail.dart';
import 'package:luqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:luqta/features/requests/domain/repositories/requests_repository.dart';
import 'package:luqta/features/booking/domain/repositories/booking_repository.dart';
import 'package:luqta/features/reels/domain/repositories/reels_repository.dart';
import 'package:luqta/features/search/domain/repositories/search_repository.dart';
import 'package:luqta/features/profile/domain/repositories/profile_repository.dart';
import 'package:luqta/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:luqta/features/story/domain/repositories/story_repository.dart';
import 'package:luqta/features/requests/domain/entities/photo_request.dart';
import 'package:luqta/features/requests/domain/entities/request_offer.dart';
import 'package:luqta/features/requests/domain/entities/request_deliverables.dart';
import 'package:luqta/features/booking/domain/entities/booking.dart';
import 'package:luqta/features/notifications/domain/entities/notification_model.dart';
import 'package:luqta/features/reels/domain/entities/reel_model.dart';
import 'package:luqta/core/models/story_model.dart';
import 'package:luqta/features/chat/domain/repositories/chat_repository.dart';
import 'package:luqta/features/chat/domain/entities/chat_thread_preview.dart';
import 'package:luqta/features/chat/domain/entities/chat_thread.dart';
import 'package:luqta/features/chat/domain/entities/chat_message.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockRequestsRepository extends Mock implements RequestsRepository {}
class MockBookingRepository extends Mock implements BookingRepository {}
class MockReelsRepository extends Mock implements ReelsRepository {}
class MockSearchRepository extends Mock implements SearchRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}
class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}
class MockStoryRepository extends Mock implements StoryRepository {}
class MockChatRepository extends Mock implements ChatRepository {}

void registerFallbacks() {
  registerFallbackValue(
    PhotoRequest(
      id: 'id',
      clientId: 'client',
      type: 'type',
      date: '2026-01-01',
      time: '10:00',
      governorate: 'Baghdad',
      durationHours: 2,
      deliverables: const RequestDeliverables(),
      referenceImages: const [],
      status: 'draft',
      offersCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  );
  registerFallbackValue(
    RequestOffer(
      id: 'offer1',
      requestId: 'req1',
      photographerId: 'photog1',
      price: 100,
      currency: 'IQD',
      deliveryDays: 3,
      deliverables: const RequestDeliverables(),
      status: 'submitted',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  );
  registerFallbackValue(
    Booking(
      id: 'book1',
      customerId: 'cust1',
      photographerId: 'photog1',
      date: '2026-02-01',
      time: '10:00',
      duration: 60,
      type: 'type',
      price: 100,
      currency: 'IQD',
      status: 'pending',
      payment: const BookingPayment(),
      location: const BookingLocation(),
      deliverables: const BookingDeliverables(),
      timeline: const BookingTimeline(),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  );
  registerFallbackValue(
    NotificationModel(
      notificationId: 'notif',
      userId: 'user',
      title: 'title',
      body: 'body',
      type: 'system',
      data: const {},
      createdAt: DateTime(2026, 1, 1),
      isRead: false,
    ),
  );
  registerFallbackValue(
    ReelModel(
      reelId: 'reel',
      photographerId: 'photog',
      photographerName: 'Photographer',
      videoUrl: 'https://example.com/video.mp4',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      caption: 'Caption',
      createdAt: DateTime(2026, 1, 1),
    ),
  );
  registerFallbackValue(
    StoryModel(
      storyId: 'story',
      photographerId: 'photog',
      photographerName: 'Photographer',
      photographerPhotoUrl: null,
      imageUrl: 'https://example.com/story.jpg',
      caption: null,
      createdAt: DateTime(2026, 1, 1),
      expiresAt: DateTime(2026, 1, 2),
      views: const [],
      isActive: true,
    ),
  );
  registerFallbackValue(
    ChatThreadPreview(
      chatId: 'chat1',
      userId: 'user2',
      userName: 'User',
      userImage: '',
      lastMessage: 'Hi',
      timestamp: DateTime(2026, 1, 1),
      unreadCount: 0,
      isOnline: false,
    ),
  );
  registerFallbackValue(
    ChatThread(
      id: 'chat1',
      lastMessageAt: DateTime(2026, 1, 1),
      bookingId: 'booking1',
      participants: const ['user1', 'user2'],
    ),
  );
  registerFallbackValue(
    ChatMessage(
      id: 'msg1',
      chatId: 'chat1',
      senderId: 'user1',
      content: 'Hello',
      createdAt: DateTime(2026, 1, 1),
      type: 'text',
    ),
  );
}
