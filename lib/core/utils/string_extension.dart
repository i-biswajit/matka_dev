extension StringExtensions on String {
  String toTitleCase() {
    return replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? word : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }
}
