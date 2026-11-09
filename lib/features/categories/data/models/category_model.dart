class CategoryModel {
  final String slug;
  final String name;

  CategoryModel({required this.slug, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
