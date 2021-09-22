class Product {
  String brand;
  String name;
  int price;
  List<String>? colors = [];
  List<int>? sizes = [];
  List<String>? images = [];
  Product(
      {this.brand = '',
      this.name = '',
      this.price = 0,
      this.colors,
      this.sizes,
      this.images});
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      brand: json['brand'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      colors: json['colors'].cast<String>(),
      sizes: json['sizes'].cast<int>(),
      images: json['images'].cast<String>(),
    );
  }
  Map<String, Object?> toJson() {
    return {
      'brand': brand,
      'name': name,
      'price': price,
      'colors': colors,
      'sizes': sizes,
      'images': images
    };
  }
}
