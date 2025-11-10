/// Extensions on String
extension StringX on String {
  /// Maximum length limit
  String maxLen(int max) {
    assert(max > -1, 'maxLen Cant be negative');
    return length < max ? this : substring(0, max);
  }
}
