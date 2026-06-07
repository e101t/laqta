import 'package:flutter/material.dart';

class LaqtaStoryShortcut {
  final String id;
  final String title;
  final String imagePath;

  const LaqtaStoryShortcut({
    required this.id,
    required this.title,
    required this.imagePath,
  });
}

class LaqtaFeedItem {
  final String id;
  final String title;
  final String subtitle;
  final String creatorName;
  final String creatorRole;
  final String imagePath;
  final int likes;
  final int comments;
  final String type;

  const LaqtaFeedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.creatorName,
    required this.creatorRole,
    required this.imagePath,
    required this.likes,
    required this.comments,
    required this.type,
  });
}

class LaqtaVenue {
  final String id;
  final String name;
  final String city;
  final String area;
  final String imagePath;
  final double rating;
  final int reviews;
  final String priceTier;
  final String description;
  final List<String> highlights;
  final int minCapacity;
  final int maxCapacity;

  const LaqtaVenue({
    required this.id,
    required this.name,
    required this.city,
    required this.area,
    required this.imagePath,
    required this.rating,
    required this.reviews,
    required this.priceTier,
    required this.description,
    required this.highlights,
    required this.minCapacity,
    required this.maxCapacity,
  });
}

class LaqtaLocation {
  final String id;
  final String name;
  final String city;
  final String area;
  final String imagePath;
  final double rating;
  final List<String> features;
  final String description;

  const LaqtaLocation({
    required this.id,
    required this.name,
    required this.city,
    required this.area,
    required this.imagePath,
    required this.rating,
    required this.features,
    required this.description,
  });
}

class LaqtaPhotographerShowcase {
  final String id;
  final String name;
  final String title;
  final String city;
  final String coverImagePath;
  final String avatarPath;
  final double rating;
  final int reviews;
  final int projects;
  final String followers;
  final int following;
  final List<String> specialties;
  final List<String> gallery;

  const LaqtaPhotographerShowcase({
    required this.id,
    required this.name,
    required this.title,
    required this.city,
    required this.coverImagePath,
    required this.avatarPath,
    required this.rating,
    required this.reviews,
    required this.projects,
    required this.followers,
    required this.following,
    required this.specialties,
    required this.gallery,
  });
}

class LaqtaSubscriptionPlan {
  final String id;
  final String name;
  final double monthlyPrice;
  final double yearlyPrice;
  final bool highlighted;
  final List<String> features;

  const LaqtaSubscriptionPlan({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.highlighted,
    required this.features,
  });
}

class LaqtaConversation {
  final String id;
  final String name;
  final String subtitle;
  final String timeLabel;
  final int unread;
  final String avatarPath;
  final String type;

  const LaqtaConversation({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.timeLabel,
    required this.unread,
    required this.avatarPath,
    required this.type,
  });
}

class LaqtaMarketplaceData {
  static const String heroPhotographer =
      'assets/images/marketplace/photographer_main.png';
  static const String heroVenue = 'assets/images/marketplace/venue_main.png';
  static const String heroLocation =
      'assets/images/marketplace/location_main.png';
  static const String heroWedding =
      'assets/images/marketplace/wedding_bride.png';
  static const String heroAlt = 'assets/images/marketplace/groom_portrait.png';
  static const String heroSoft = 'assets/images/marketplace/bride_portrait.png';
  static const String avatar = 'assets/images/marketplace/avatar_ahmed.jpg';

  static const List<LaqtaStoryShortcut> storyShortcuts = [
    LaqtaStoryShortcut(
      id: 'locations',
      title: 'الأماكن',
      imagePath: heroLocation,
    ),
    LaqtaStoryShortcut(id: 'venues', title: 'القاعات', imagePath: heroVenue),
    LaqtaStoryShortcut(
      id: 'photographers',
      title: 'المصورين',
      imagePath: heroPhotographer,
    ),
    LaqtaStoryShortcut(id: 'follow', title: 'تابع', imagePath: heroSoft),
  ];

  static const List<LaqtaFeedItem> feedItems = [
    LaqtaFeedItem(
      id: 'feed_1',
      title: 'جلسة في الطبيعة',
      subtitle: 'Ahmed Aliraqi',
      creatorName: 'Ahmed Aliraqi',
      creatorRole: 'مصور زفاف',
      imagePath: heroPhotographer,
      likes: 1200,
      comments: 128,
      type: 'photographer',
    ),
    LaqtaFeedItem(
      id: 'feed_2',
      title: 'قاعة رويال لايف',
      subtitle: 'بغداد',
      creatorName: 'قاعة رويال لايف',
      creatorRole: 'قاعة مناسبات',
      imagePath: heroVenue,
      likes: 980,
      comments: 74,
      type: 'venue',
    ),
    LaqtaFeedItem(
      id: 'feed_3',
      title: 'حديقة السلام',
      subtitle: 'الكرخ',
      creatorName: 'حديقة السلام',
      creatorRole: 'مكان تصوير',
      imagePath: heroLocation,
      likes: 860,
      comments: 51,
      type: 'location',
    ),
  ];

  static const List<LaqtaVenue> venues = [
    LaqtaVenue(
      id: 'royal-life',
      name: 'قاعة رويال لايف',
      city: 'بغداد',
      area: 'المنصور',
      imagePath: heroVenue,
      rating: 4.8,
      reviews: 124,
      priceTier: r'$$$',
      description:
          'قاعة ليف بتصميم فاخر وخدماتها المميزة تجعل يومك حدثًا لا يُنسى.',
      highlights: ['500-800 السعة', 'موقف سيارات', 'خدمة بوفيه', 'ديكور فاخر'],
      minCapacity: 500,
      maxCapacity: 800,
    ),
    LaqtaVenue(
      id: 'awel-hall',
      name: 'قاعة أوال',
      city: 'بغداد',
      area: 'الكرادة',
      imagePath: heroSoft,
      rating: 4.6,
      reviews: 98,
      priceTier: r'$$$',
      description:
          'قاعة عملية بتوزيع أنيق للمقاعد ومساحة مناسبة للحفلات المتوسطة.',
      highlights: [
        '320-450 السعة',
        'مدخل فاخر',
        'إضاءة هادئة',
        'تصميم كلاسيكي',
      ],
      minCapacity: 320,
      maxCapacity: 450,
    ),
    LaqtaVenue(
      id: 'diamond-hall',
      name: 'قاعة الماسة',
      city: 'أربيل',
      area: 'عينكاوا',
      imagePath: heroWedding,
      rating: 4.7,
      reviews: 76,
      priceTier: r'$$$$',
      description:
          'قاعة راقية للمناسبات الخاصة مع خدمة ضيافة وديكور حسب الطلب.',
      highlights: ['250-500 السعة', 'خدمة VIP', 'شاشة عملاقة', 'تنسيق ورد'],
      minCapacity: 250,
      maxCapacity: 500,
    ),
  ];

  static const List<LaqtaLocation> locations = [
    LaqtaLocation(
      id: 'salam-garden',
      name: 'حديقة السلام',
      city: 'بغداد',
      area: 'الكرخ',
      imagePath: heroLocation,
      rating: 4.7,
      features: ['طبيعة', 'مناسب للتصوير', 'إضاءة رائعة', 'جلسات خارجية'],
      description:
          'مكان جميل بمساحات خضراء واسعة يناسب جلسات التصوير المختلفة.',
    ),
    LaqtaLocation(
      id: 'nova-cafe',
      name: 'مقهى نوفا',
      city: 'بغداد',
      area: 'المنصور',
      imagePath: heroSoft,
      rating: 4.5,
      features: ['داخلي', 'ديكور دافئ', 'إضاءة نافذة', 'جلسات هادئة'],
      description:
          'زاوية مثالية لجلسات lifestyle واللقطات الهادئة داخلية الطابع.',
    ),
    LaqtaLocation(
      id: 'dijla-resort',
      name: 'منتجع دجلة',
      city: 'بغداد',
      area: 'الجادرية',
      imagePath: heroWedding,
      rating: 4.8,
      features: ['بحيرات', 'غروب', 'حدائق', 'جلسات زفاف'],
      description:
          'منتجع بصري قوي لمحتوى الزفاف والجلسات المفتوحة ذات الطابع الفاخر.',
    ),
  ];

  static const LaqtaPhotographerShowcase photographer =
      LaqtaPhotographerShowcase(
        id: 'ahmed-aliraqi',
        name: 'Ahmed Aliraqi',
        title: 'مصور زفاف',
        city: 'بغداد',
        coverImagePath: heroPhotographer,
        avatarPath: avatar,
        rating: 4.9,
        reviews: 128,
        projects: 246,
        followers: '12.3K',
        following: 98,
        specialties: ['الزفاف', 'جلسات', 'كواليس', 'استوديو'],
        gallery: [
          heroAlt,
          heroSoft,
          'assets/images/marketplace/couple_portrait.png',
          heroWedding,
          heroVenue,
          heroLocation,
        ],
      );

  static const List<LaqtaSubscriptionPlan> plans = [
    LaqtaSubscriptionPlan(
      id: 'basic',
      name: 'Basic',
      monthlyPrice: 4.99,
      yearlyPrice: 49.0,
      highlighted: false,
      features: [
        '10 صور في البورتفوليو',
        '10 ريلز شهريًا',
        'ظهور عادي في البحث',
        'دعم عادي',
      ],
    ),
    LaqtaSubscriptionPlan(
      id: 'pro',
      name: 'Pro',
      monthlyPrice: 14.99,
      yearlyPrice: 149.0,
      highlighted: true,
      features: [
        '50 صورة في البورتفوليو',
        '30 ريلز شهريًا',
        'ظهور أفضل في البحث',
        'إحصائيات أساسية',
        'خصم على الإعلانات',
      ],
    ),
    LaqtaSubscriptionPlan(
      id: 'elite',
      name: 'Elite',
      monthlyPrice: 29.99,
      yearlyPrice: 299.0,
      highlighted: false,
      features: [
        'صور غير محدودة',
        'ريلز غير محدودة',
        'أعلى ظهور في البحث',
        'إحصائيات متقدمة',
        'شارة احترافية',
        'دعم أسرع',
      ],
    ),
  ];

  static const List<LaqtaConversation> conversations = [
    LaqtaConversation(
      id: 'msg_1',
      name: 'Ahmed Aliraqi',
      subtitle: 'متى تكون متاح للحجز؟',
      timeLabel: '10:30 AM',
      unread: 2,
      avatarPath: avatar,
      type: 'المصورون',
    ),
    LaqtaConversation(
      id: 'msg_2',
      name: 'قاعة رويال لايف',
      subtitle: 'شكرًا لتواصلك معنا',
      timeLabel: '9:45 AM',
      unread: 1,
      avatarPath: heroVenue,
      type: 'القاعات',
    ),
    LaqtaConversation(
      id: 'msg_3',
      name: 'حديقة السلام',
      subtitle: 'تم استلام طلبك',
      timeLabel: 'أمس',
      unread: 0,
      avatarPath: heroLocation,
      type: 'الترتيبات',
    ),
    LaqtaConversation(
      id: 'msg_4',
      name: 'Sara Photography',
      subtitle: 'تم تأكيد الحجز',
      timeLabel: 'أمس',
      unread: 0,
      avatarPath: heroSoft,
      type: 'المصورون',
    ),
  ];

  static LaqtaVenue venueById(String id) =>
      venues.firstWhere((venue) => venue.id == id, orElse: () => venues.first);

  static LaqtaLocation locationById(String id) => locations.firstWhere(
    (location) => location.id == id,
    orElse: () => locations.first,
  );

  static Color tabColorForType(String type) {
    switch (type) {
      case 'venue':
        return const Color(0xFFD6A44A);
      case 'location':
        return const Color(0xFFE7C987);
      default:
        return const Color(0xFFF2D3A3);
    }
  }
}
