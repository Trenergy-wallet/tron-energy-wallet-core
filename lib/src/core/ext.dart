/// Расширения на String
extension StringX on String {
  /// Ограничение на максимальную длину
  String maxLen(int max) {
    assert(max > -1, 'maxLen Cant be negative');
    return length < max ? this : substring(0, max);
  }
}
