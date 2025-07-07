extension StringExtension on String {
  String toTitleCase() {
    return split(' ').map((str) => str[0].toUpperCase() + str.substring(1)).join(' ');
  }
}