class AnalyticsMetrics {
  final int totalViews;
  final int profileClicks;
  final int bookingRequests;
  final int completedBookings;
  final double revenue;
  final int newFollowers;
  final int storyViews;
  final double avgRating;

  const AnalyticsMetrics({
    required this.totalViews,
    required this.profileClicks,
    required this.bookingRequests,
    required this.completedBookings,
    required this.revenue,
    required this.newFollowers,
    required this.storyViews,
    required this.avgRating,
  });
}
