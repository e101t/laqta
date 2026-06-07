class MarketplaceShortcutAsset {
  final String id;
  final String title;
  final String imagePath;

  const MarketplaceShortcutAsset({
    required this.id,
    required this.title,
    required this.imagePath,
  });
}

class MarketplaceAssets {
  MarketplaceAssets._();

  static const String heroPhotographer =
      'assets/images/marketplace/photographer_main.png';
  static const String heroVenue = 'assets/images/marketplace/venue_main.png';
  static const String heroLocation =
      'assets/images/marketplace/location_main.png';
  static const String heroWedding =
      'assets/images/marketplace/wedding_bride.png';
  static const String heroSoft = 'assets/images/marketplace/bride_portrait.png';
  static const String avatar = 'assets/images/marketplace/avatar_ahmed.jpg';

  static const List<MarketplaceShortcutAsset> storyShortcuts = [
    MarketplaceShortcutAsset(
      id: 'locations',
      title: 'الأماكن',
      imagePath: heroLocation,
    ),
    MarketplaceShortcutAsset(
      id: 'venues',
      title: 'القاعات',
      imagePath: heroVenue,
    ),
    MarketplaceShortcutAsset(
      id: 'photographers',
      title: 'المصورين',
      imagePath: heroPhotographer,
    ),
    MarketplaceShortcutAsset(id: 'follow', title: 'تابع', imagePath: heroSoft),
  ];
}
