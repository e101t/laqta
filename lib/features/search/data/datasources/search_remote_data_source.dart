import 'package:luqta/features/photographer/data/dtos/photographer_dto.dart';
import 'package:luqta/features/profile/data/dtos/user_profile_dto.dart';

abstract class SearchRemoteDataSource {
  Future<List<UserProfileDto>> getPhotographerUsers();

  Future<List<PhotographerDetailsDto>> getPhotographerDetails();
}
