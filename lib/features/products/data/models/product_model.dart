class ProductModel {
  final int id;
  final String title;
  final double price;
  final double discountPercentage;
  final double rating;
  final String category;
  final String thumbnail;
  final int stock;
  final int minimumOrderQuantity;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.category,
    required this.thumbnail,
    required this.stock,
    required this.minimumOrderQuantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      discountPercentage:
          double.tryParse(json['discountPercentage']?.toString() ?? '') ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      category: json['category']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      stock: int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      minimumOrderQuantity:
          int.tryParse(json['minimumOrderQuantity']?.toString() ?? '') ?? 1,
    );
  }

  Map<String, dynamic> toRow() {
    return {
      'productId': id,
      'name': title,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'category': category,
      'image': thumbnail,
      'stock': stock,
      'minimumOrderQuantity': minimumOrderQuantity,
    };
  }

  factory ProductModel.fromRow(Map<String, dynamic> row) {
    return ProductModel(
      id: (row['productId'] as num?)?.toInt() ?? 0,
      title: row['name']?.toString() ?? '',
      price: (row['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (row['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (row['rating'] as num?)?.toDouble() ?? 0,
      category: row['category']?.toString() ?? '',
      thumbnail: row['image']?.toString() ?? '',
      stock: (row['stock'] as num?)?.toInt() ?? 0,
      minimumOrderQuantity: (row['minimumOrderQuantity'] as num?)?.toInt() ?? 1,
    );
  }
}
