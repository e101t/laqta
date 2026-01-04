Map<String, dynamic> buildUserPublicData(Map<String, dynamic> data) {
  final publicData = <String, dynamic>{};

  void copyIfPresent(String key) {
    if (data.containsKey(key)) {
      publicData[key] = data[key];
    }
  }

  copyIfPresent('name');
  copyIfPresent('username');
  copyIfPresent('usernameLower');
  copyIfPresent('photoUrl');
  copyIfPresent('governorate');
  copyIfPresent('gender');
  copyIfPresent('age');
  copyIfPresent('birthYear');
  copyIfPresent('role');
  copyIfPresent('profileCompleted');
  copyIfPresent('over18Confirmed');
  copyIfPresent('lang');
  copyIfPresent('lastSeen');
  copyIfPresent('createdAt');
  copyIfPresent('updatedAt');

  return publicData;
}
