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
  copyIfPresent('photoMediaId');
  copyIfPresent('photoUrl');
  copyIfPresent('governorate');
  copyIfPresent('role');
  copyIfPresent('createdAt');
  copyIfPresent('updatedAt');

  return publicData;
}
