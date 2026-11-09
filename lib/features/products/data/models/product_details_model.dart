import 'package:rafoof/features/products/data/models/product_model.dart';
import 'package:rafoof/features/products/data/models/review_model.dart';

class ProductDetailsModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String brand;
  final String sku;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String availabilityStatus;
  final int minimumOrderQuantity;
  final String shippingInformation;
  final String warrantyInformation;
  final String returnPolicy;
  final String thumbnail;
  final List<String> images;
  final List<ReviewModel> reviews;

  ProductDetailsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.sku,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.availabilityStatus,
    required this.minimumOrderQuantity,
    required this.shippingInformation,
    required this.warrantyInformation,
    required this.returnPolicy,
    required this.thumbnail,
    required this.images,
    required this.reviews,
  });

  double get finalPrice => price * (1 - discountPercentage / 100);

  ProductModel toProductModel() {
    return ProductModel(
      id: id,
      title: title,
      price: price,
      discountPercentage: discountPercentage,
      rating: rating,
      category: category,
      thumbnail: thumbnail,
      stock: stock,
      minimumOrderQuantity: minimumOrderQuantity,
    );
  }

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final rawReviews = json['reviews'];
    final thumbnail = json['thumbnail']?.toString() ?? '';
    final images = rawImages is List
        ? rawImages
              .map((image) => image.toString())
              .where((url) => url.isNotEmpty)
              .toList()
        : <String>[];

    return ProductDetailsModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      discountPercentage:
          double.tryParse(json['discountPercentage']?.toString() ?? '') ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      stock: int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      availabilityStatus: json['availabilityStatus']?.toString() ?? '',
      minimumOrderQuantity:
          int.tryParse(json['minimumOrderQuantity']?.toString() ?? '') ?? 1,
      shippingInformation: json['shippingInformation']?.toString() ?? '',
      warrantyInformation: json['warrantyInformation']?.toString() ?? '',
      returnPolicy: json['returnPolicy']?.toString() ?? '',
      thumbnail: thumbnail,
      images: images.isEmpty && thumbnail.isNotEmpty ? [thumbnail] : images,
      reviews: rawReviews is List
          ? rawReviews
                .whereType<Map<String, dynamic>>()
                .map(ReviewModel.fromJson)
                .toList()
          : <ReviewModel>[],
    );
  }
}
