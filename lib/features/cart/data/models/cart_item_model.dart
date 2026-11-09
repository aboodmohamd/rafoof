class CartItemModel {
  final int productId;
  final String name;
  final double price;
  final double discountPercentage;
  final int quantity;
  final String image;
  final int stock;
  final int minimumOrderQuantity;

  double get finalPrice => price * (1 - discountPercentage / 100);
  double get total => price * quantity;
  double get finalTotal => finalPrice * quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.discountPercentage,
    required this.quantity,
    required this.image,
    required this.stock,
    required this.minimumOrderQuantity,
  });

  Map<String, dynamic> toRow() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'discountPercentage': discountPercentage,
      'quantity': quantity,
      'image': image,
      'stock': stock,
      'minimumOrderQuantity': minimumOrderQuantity,
    };
  }

  factory CartItemModel.fromRow(Map<String, dynamic> row) {
    return CartItemModel(
      productId: (row['productId'] as num?)?.toInt() ?? 0,
      name: row['name']?.toString() ?? '',
      price: (row['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (row['discountPercentage'] as num?)?.toDouble() ?? 0,
      quantity: (row['quantity'] as num?)?.toInt() ?? 1,
      image: row['image']?.toString() ?? '',
      stock: (row['stock'] as num?)?.toInt() ?? 0,
      minimumOrderQuantity: (row['minimumOrderQuantity'] as num?)?.toInt() ?? 1,
    );
  }
}
