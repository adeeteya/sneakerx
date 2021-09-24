import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/models/product_model.dart';
import 'package:sneakerx/services/firestore_service.dart';

class ProductCard extends StatefulWidget {
  final String productId;
  final Product product;
  final bool isFavorite;
  final Function showCartItems;

  const ProductCard(
      {Key? key,
      required this.productId,
      required this.product,
      required this.isFavorite,
      required this.showCartItems})
      : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Future addToCart() async {
    await FirestoreService().addToCart(widget.productId,
        color: widget.product.colors![0], size: widget.product.sizes![0]);
  }

  Future toggleFavorite() async {
    await FirestoreService().toggleFavorite(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 6,
        color: const Color(0xFFF4F5FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(8),
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
                            ? const Icon(Icons.favorite, color: Colors.red)
                            : const Icon(Icons.favorite_outline)),
                    IconButton(
                        onPressed: () async {
                          await addToCart();
                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          await widget.showCartItems();
                        },
                        icon: const Icon(Icons.add, color: Color(0xFFF68A0A)))
                  ],
                ),
              ),
              Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Hero(
                      tag: widget.productId,
                      child: FadeInImage.assetNetwork(
                          fit: BoxFit.contain,
                          placeholder: "assets/loading.gif",
                          image: widget.product.images![0]),
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(widget.product.brand),
                      Text(widget.product.name),
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: Text("\$${widget.product.price}",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFF68A0A),
                          fontWeight: FontWeight.bold)))
            ],
          ),
        ));
  }
}
