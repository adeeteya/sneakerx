import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/services/FirestoreService.dart';

class CartListTile extends StatefulWidget {
  final String productId;
  final int chosenSize;
  final String chosenColor;
  final int quantity;
  CartListTile({
    this.productId = "",
    this.chosenSize = 6,
    this.chosenColor = "white",
    this.quantity = 1,
  });
  @override
  _CartListTileState createState() => _CartListTileState();
}

class _CartListTileState extends State<CartListTile> {
  final _fireStoreInstance = FirestoreService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: _fireStoreInstance.getProductDetails(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.black,
            ));
          }
          if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          Map<String, dynamic>? data = snapshot.data;
          //data!['price'] * widget.quantity;
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: Card(
                  color: Color(0xFFF4F5FC),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    width: 40,
                    height: 120,
                    child: FadeInImage.assetNetwork(
                        fit: BoxFit.fitWidth,
                        placeholder: "assets/loading.gif",
                        image: data!['images'][0]),
                  ),
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['brand'] + " " + data['name'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    SizedBox(height: 2),
                    Text(
                        "Size:${widget.chosenSize} Color:${widget.chosenColor}",
                        style: TextStyle(
                            fontSize: 16, color: ThemeData.light().hintColor)),
                    SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("\$${data['price']}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 18)),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  _fireStoreInstance.decrementQuantity(
                                      widget.productId,
                                      color: widget.chosenColor,
                                      size: widget.chosenSize,
                                      price: data['price']);
                                },
                                icon:
                                    Icon(Icons.remove_circle_outline_outlined)),
                            Text(
                              "${widget.quantity}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () {
                                _fireStoreInstance.addToCart(widget.productId,
                                    color: widget.chosenColor,
                                    size: widget.chosenSize,
                                    price: data['price']);
                              },
                              icon: Icon(Icons.add_circle),
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
        });
  }
}
