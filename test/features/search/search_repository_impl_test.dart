import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/photographer/data/dtos/photographer_dto.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';
import 'package:laqta/features/search/data/datasources/search_remote_data_source.dart';
import 'package:laqta/features/search/data/repositories/search_repository_impl.dart';

class _FakeSearchRemoteDataSource implements SearchRemoteDataSource {
  _FakeSearchRemoteDataSource({
    required this.users,
    required this.photographers,
  });

  final List<UserProfileDto> users;
  final List<PhotographerDetailsDto> photographers;

  int getPhotographerUsersCalls = 0;
  int getPhotographerDetailsCalls = 0;

  @override
  Future<List<PhotographerDetailsDto>> getPhotographerDetails() async {
    getPhotographerDetailsCalls++;
    return photographers;
  }

  @override
  Future<List<UserProfileDto>> getPhotographerUsers() async {
    getPhotographerUsersCalls++;
    return users;
  }
}

void main() {
  UserProfileDto makeUser({
    required String id,
    required String name,
    required String governorate,
    String? username,
  }) {
    final now = DateTime(2026, 4, 9);
    return UserProfileDto(
      id: id,
      role: 'photographer',
      name: name,
      username: username,
      photoUrl: null,
      governorate: governorate,
      createdAt: now,
      updatedAt: now,
    );
  }

  PhotographerDetailsDto makePhotographer({
    required String id,
    required List<String> specialties,
    required double rate,
    required int reviewsCount,
    required double basePrice,
    required List<String> governorates,
  }) {
    return PhotographerDetailsDto(
      id: id,
      specialties: specialties,
      governorates: governorates,
      rate: rate,
      reviewsCount: reviewsCount,
      basePrice: basePrice,
      currency: 'IQD',
      bio: '',
      instagram: null,
      tiktok: null,
      isVerified: true,
      verifiedAt: null,
      updatedAt: DateTime(2026, 4, 9),
    );
  }

  test(
    'search repository caches merged photographer index across searches',
    () async {
      final remote = _FakeSearchRemoteDataSource(
        users: [
          makeUser(
            id: 'photog_1',
            name: 'Ali Studio',
            governorate: 'Baghdad',
            username: 'alistudio',
          ),
        ],
        photographers: [
          makePhotographer(
            id: 'photog_1',
            specialties: const ['Wedding'],
            rate: 4.8,
            reviewsCount: 12,
            basePrice: 100000,
            governorates: const ['Baghdad'],
          ),
        ],
      );

      final repository = SearchRepositoryImpl(remote);

      final first = await repository.searchPhotographers(query: 'baghdad');
      final second = await repository.searchPhotographers(query: 'wedding');

      expect(first.isSuccess, isTrue);
      expect(second.isSuccess, isTrue);
      expect(remote.getPhotographerUsersCalls, 1);
      expect(remote.getPhotographerDetailsCalls, 1);
    },
  );

  test(
    'search repository filters by name specialty governorate and username',
    () async {
      final remote = _FakeSearchRemoteDataSource(
        users: [
          makeUser(
            id: 'photog_1',
            name: 'Ali Studio',
            governorate: 'Baghdad',
            username: 'alistudio',
          ),
          makeUser(
            id: 'photog_2',
            name: 'Sara Lens',
            governorate: 'Basra',
            username: 'saralens',
          ),
        ],
        photographers: [
          makePhotographer(
            id: 'photog_1',
            specialties: const ['Wedding', 'Portrait'],
            rate: 4.8,
            reviewsCount: 50,
            basePrice: 100000,
            governorates: const ['Baghdad'],
          ),
          makePhotographer(
            id: 'photog_2',
            specialties: const ['Product'],
            rate: 4.6,
            reviewsCount: 20,
            basePrice: 90000,
            governorates: const ['Basra'],
          ),
        ],
      );

      final repository = SearchRepositoryImpl(remote);

      final byName = await repository.searchPhotographers(query: 'ali');
      final bySpecialty = await repository.searchPhotographers(
        query: 'product',
      );
      final byGovernorate = await repository.searchPhotographers(
        query: 'basra',
      );
      final byUsername = await repository.searchPhotographers(
        query: 'saralens',
      );

      expect(byName.valueOrNull?.map((e) => e.id), ['photog_1']);
      expect(bySpecialty.valueOrNull?.map((e) => e.id), ['photog_2']);
      expect(byGovernorate.valueOrNull?.map((e) => e.id), ['photog_2']);
      expect(byUsername.valueOrNull?.map((e) => e.id), ['photog_2']);
    },
  );
}
