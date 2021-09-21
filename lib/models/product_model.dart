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
}
