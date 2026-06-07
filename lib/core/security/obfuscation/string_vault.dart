class StringVault {
  StringVault._();

  static const List<int> _key = <int>[0x4C, 0x41, 0x51, 0x54, 0x41];

  static String decode(List<int> encoded) {
    final chars = encoded.asMap().entries.map(
      (entry) => entry.value ^ _key[entry.key % _key.length],
    );
    return String.fromCharCodes(chars);
  }

  static List<int> encodeForBuildTime(String value) {
    final units = value.codeUnits;
    return units
        .asMap()
        .entries
        .map((entry) => entry.value ^ _key[entry.key % _key.length])
        .toList(growable: false);
  }
}
