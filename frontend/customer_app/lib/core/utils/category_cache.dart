class CategoryCache {
  static final Map<String, String> _cache = {};

  static void addAll(List<dynamic> categories) {
    for (final cat in categories) {
      if (cat.image != null && cat.image!.isNotEmpty) {
        _cache[cat.id] = cat.image!;
      }
    }
  }

  static String? getImageUrl(String categoryId) => _cache[categoryId];
}
