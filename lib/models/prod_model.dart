class ProductModel {
  final String uuid;
  final String name;
  final String imageUrl;
  final String price;
  final String rating;
  final int quantity;

  ProductModel({
    required this.uuid,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.quantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      uuid: json['uuid'],
      name: json['productName'],
      imageUrl: json['imageLink'],
      price: json['price'],
      rating: json['rating'],
      quantity: json['quantity'],
    );
  }
}
