import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/services/FirestoreService.dart';

class ProductCard extends StatefulWidget {
  final String productId;
  final String brand;
  final String name;
  final String imageUrl;
  final int price;
  final int defaultSize;
  final String defaultColor;
  final bool isFavorite;
  final Function showCartItems;
  ProductCard(
      {required this.productId,
      required this.brand,
      required this.name,
      required this.imageUrl,
      required this.price,
      required this.defaultSize,
      required this.defaultColor,
      required this.isFavorite,
      required this.showCartItems});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Future addToCart() async {
    await FirestoreService().addToCart(widget.productId,
        color: widget.defaultColor,
        size: widget.defaultSize,
        price: widget.price);
  }

  Future toggleFavorite() async {
    await FirestoreService().toggleFavorite(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 4,
        color: Color(0xFFF4F5FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () async {
                          await toggleFavorite();
                        },
                        icon: (widget.isFavorite)
                            ? Icon(Icons.favorite, color: Colors.red)
                            : Icon(Icons.favorite_outline)),
                    IconButton(
                        onPressed: () async {
                          await addToCart();
                          await Future.delayed(Duration(milliseconds: 100));
                          await widget.showCartItems();
                        },
                        icon: Icon(Icons.add, color: Color(0xFFF68A0A)))
                  ],
                ),
              ),
              Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    child: Hero(
                      tag: widget.productId,
                      child: FadeInImage.assetNetwork(
                          fit: BoxFit.contain,
                          placeholder: "assets/loading.gif",
                          image: widget.imageUrl),
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(widget.brand),
                      Text(widget.name),
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: Text("\$${widget.price}",
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFF68A0A),
                          fontWeight: FontWeight.bold)))
            ],
          ),
        ));
  }
}
