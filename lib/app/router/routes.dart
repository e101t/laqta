class Routes {
  // Paths
  static const String splash = '/';
  static const String language = '/language';
  static const String auth = '/auth';
  static const String signUpDetails = '/sign-up';
  static const String role = '/role';
  static const String blocked = '/blocked';
  static const String main = '/main';

  static const String photographer = '/photographer/:id';

  static const String bookings = '/bookings';
  static const String booking = '/booking/:id';
  static const String requests = '/requests';
  static const String requestCreate = '/requests/create';
  static const String requestDetails = '/requests/:id';
  static const String offerSubmit = '/requests/:id/offer';
  static const String shop = '/shop';

  static const String chatList = '/chats';
  static const String chat = '/chat/:id';

  static const String dashboard = '/dashboard';
  static const String notifications = '/notifications';

  static const String profile = '/profile';
  static const String basicInfo = '/basic-info';
  static const String portfolioEditor = '/portfolio-editor';

  static const String settings = '/settings';
  static const String favorites = '/favorites';
  static const String search = '/search';
  static const String explore = '/explore';
  static const String venues = '/venues';
  static const String venueDetails = '/venues/:id';
  static const String venueBooking = '/venues/:id/book';
  static const String locationDetails = '/locations/:id';
  static const String subscriptionPlans = '/plans';
  static const String sponsoredAd = '/sponsored-ad';
  static const String campaignAnalytics = '/campaigns/:id/analytics';
  static const String photographerVerification = '/photographer-verification';

  static const String policy = '/policy';
  static const String terms = '/terms';
  static const String deleteAccountPolicy = '/delete-account-policy';
  static const String contentPolicy = '/content-policy';

  static const String loyalty = '/loyalty';
  static const String analytics = '/analytics';
  static const String achievements = '/achievements';
  static const String availability = '/availability';

  static const String bookingPolicies = '/booking-policies';

  static const String payment = '/payment';
  static const String writeReview = '/write-review';
  static const String createPost = '/create-post';
  static const String createStory = '/create-story';

  // Names (GoRoute name:)
  static const String nSplash = 'splash';
  static const String nLanguage = 'language';
  static const String nAuth = 'auth';
  static const String nSignUpDetails = 'sign_up_details';
  static const String nRole = 'role';
  static const String nBlocked = 'blocked';
  static const String nMain = 'main';

  static const String nPhotographer = 'photographer';

  static const String nBookings = 'bookings';
  static const String nBooking = 'booking';
  static const String nRequests = 'requests';
  static const String nRequestCreate = 'request_create';
  static const String nRequestDetails = 'request_details';
  static const String nOfferSubmit = 'offer_submit';
  static const String nShop = 'shop';

  static const String nChatList = 'chat_list';
  static const String nChat = 'chat';

  static const String nDashboard = 'dashboard';
  static const String nNotifications = 'notifications';

  static const String nProfile = 'profile';
  static const String nBasicInfo = 'basic_info';
  static const String nPortfolioEditor = 'portfolio_editor';

  static const String nSettings = 'settings';
  static const String nFavorites = 'favorites';
  static const String nSearch = 'search';
  static const String nExplore = 'explore';
  static const String nVenues = 'venues';
  static const String nVenueDetails = 'venue_details';
  static const String nVenueBooking = 'venue_booking';
  static const String nLocationDetails = 'location_details';
  static const String nSubscriptionPlans = 'subscription_plans';
  static const String nSponsoredAd = 'sponsored_ad';
  static const String nCampaignAnalytics = 'campaign_analytics';
  static const String nPhotographerVerification = 'photographer_verification';

  static const String nPolicy = 'policy';
  static const String nTerms = 'terms';
  static const String nDeleteAccountPolicy = 'delete_account_policy';
  static const String nContentPolicy = 'content_policy';

  static const String nLoyalty = 'loyalty';
  static const String nAnalytics = 'analytics';
  static const String nAchievements = 'achievements';
  static const String nAvailability = 'availability';
  static const String nBookingPolicies = 'booking_policies';

  static const String nPayment = 'payment';
  static const String nWriteReview = 'write_review';
  static const String nCreatePost = 'create_post';
  static const String nCreateStory = 'create_story';
}
