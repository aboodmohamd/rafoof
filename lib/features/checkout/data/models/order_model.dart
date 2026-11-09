class OrderModel {
  final int id;
  final int userId;
  final double total;
  final double discountedTotal;
  final int totalProducts;
  final int totalQuantity;
  final String image;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.discountedTotal,
    required this.totalProducts,
    required this.totalQuantity,
    required this.image,
    required this.createdAt,
  });

  double get discount => total - discountedTotal;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final products = json['products'];
    final firstProduct = products is List && products.isNotEmpty
        ? products.first
        : null;

    return OrderModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0,
      discountedTotal:
          double.tryParse(json['discountedTotal']?.toString() ?? '') ?? 0,
      totalProducts: int.tryParse(json['totalProducts']?.toString() ?? '') ?? 0,
      totalQuantity: int.tryParse(json['totalQuantity']?.toString() ?? '') ?? 0,
      image: firstProduct is Map
          ? firstProduct['thumbnail']?.toString() ?? ''
          : '',
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toRow() {
    return {
      'orderId': id,
      'userId': userId,
      'total': total,
      'discountedTotal': discountedTotal,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromRow(Map<String, dynamic> row) {
    return OrderModel(
      id: (row['orderId'] as num?)?.toInt() ?? 0,
      userId: (row['userId'] as num?)?.toInt() ?? 0,
      total: (row['total'] as num?)?.toDouble() ?? 0,
      discountedTotal: (row['discountedTotal'] as num?)?.toDouble() ?? 0,
      totalProducts: (row['totalProducts'] as num?)?.toInt() ?? 0,
      totalQuantity: (row['totalQuantity'] as num?)?.toInt() ?? 0,
      image: row['image']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(row['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
