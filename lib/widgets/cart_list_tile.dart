import 'package:flutter/material.dart';
import 'package:sneakerx/services/firestore_service.dart';

class CartListTile extends StatefulWidget {
  final String productId;
  final int chosenSize;
  final String chosenColor;
  final int quantity;
  final String imageUrl;
  final String brand;
  final String name;
  final int price;

  const CartListTile({
    super.key,
    required this.productId,
    required this.chosenSize,
    required this.chosenColor,
    required this.quantity,
    required this.imageUrl,
    required this.brand,
    required this.name,
    required this.price,
  });

  @override
  State<CartListTile> createState() => _CartListTileState();
}

class _CartListTileState extends State<CartListTile> {
  final _fireStoreInstance = FirestoreService();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Card(
            color: const Color(0xFFF4F5FC),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(
              width: 40,
              height: 120,
              child: FadeInImage.assetNetwork(
                  fit: BoxFit.fitWidth,
                  placeholder: "assets/loading.gif",
                  image: widget.imageUrl),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${widget.brand} ${widget.name}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 2),
              Text("Size:${widget.chosenSize} Color:${widget.chosenColor}",
                  style: TextStyle(
                      fontSize: 16, color: ThemeData.light().hintColor)),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("\$${widget.price}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18)),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () async {
                            await _fireStoreInstance.decrementQuantity(
                                widget.productId,
                                color: widget.chosenColor,
                                size: widget.chosenSize);
                          },
                          icon:
                              const Icon(Icons.remove_circle_outline_outlined)),
                      Text(
                        "${widget.quantity}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () async {
                          await _fireStoreInstance.addToCart(widget.productId,
                              color: widget.chosenColor,
                              size: widget.chosenSize);
                        },
                        icon: const Icon(Icons.add_circle),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
