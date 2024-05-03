class CategoryWithName {
  final String categoryName;
  final List<HobbyCategory> items;

  CategoryWithName({
    required this.categoryName,
    required this.items,
  });
}

class HobbyCategory {
  final String id;
  final String name;

  HobbyCategory({required this.id, required this.name});

  factory HobbyCategory.fromJson(Map<String, dynamic> json) {
    return HobbyCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}
