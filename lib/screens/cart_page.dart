import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/models/product_model.dart';
import 'package:sneakerx/services/firestore_service.dart';
import 'package:sneakerx/widgets/cart_list_tile.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _firebaseInstance = FirestoreService();
  final _controller = StreamController<int>();
  Stream<int> get _totalStream => _controller.stream;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "Cart",
      )),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseInstance.cartStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A191C)));
          }
          List<DocumentSnapshot> cartItemsSnapshot = snapshot.data!.docs;
          List<Map<String, dynamic>> cartItems = [];
          int noOfItems = cartItemsSnapshot.length;
          if (noOfItems == 0) _controller.sink.add(0);
          int total = 0;
          for (int i = 0; i < cartItemsSnapshot.length; i++) {
            DocumentSnapshot cartItemSnapshot = cartItemsSnapshot[i];
            Map<String, dynamic> cartItem =
                cartItemSnapshot.data() as Map<String, dynamic>;
            //product processing
            String productId = cartItemSnapshot.id; //unique productId
            int splitPos = productId.indexOf("0"); //split Value
            String chosenColor = productId.substring(0, splitPos); //color
            int chosenSize = 0; //chosenSize int
            String sizeText = productId[splitPos + 1];
            if (double.tryParse(productId[splitPos + 2]) != null) {
              sizeText += productId[splitPos + 2];
              chosenSize = int.parse(sizeText);
              productId = productId.substring(splitPos + 3);
            } else {
              chosenSize = int.parse(sizeText);
              productId = productId.substring(splitPos + 2);
            }
            //productId now has it's original un-processed id
            cartItem.addAll({
              'chosenColor': chosenColor,
              'chosenSize': chosenSize,
              'productId': productId
            });
            cartItems.add(cartItem);
          }
          return Column(
            children: [
              Expanded(
                flex: 2,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 20),
                  children: cartItems.map((cartItem) {
                    return FutureBuilder<Product>(
                        future: _firebaseInstance
                            .getProductDetails(cartItem['productId']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              )),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text("${snapshot.error}"));
                          }
                          Product? product = snapshot.data;
                          total +=
                              (product!.price * cartItem['quantity']) as int;
                          _controller.sink.add(total);
                          return CartListTile(
                            productId: cartItem['productId'],
                            chosenSize: cartItem['chosenSize'],
                            chosenColor: cartItem['chosenColor'],
                            quantity: cartItem['quantity'],
                            imageUrl: product.images![0],
                            brand: product.brand,
                            name: product.name,
                            price: product.price,
                          );
                        });
                  }).toList(), //sizedBox(h-20)
                ),
              ),
              const SizedBox(height: 20),
              Container(
                color: Colors.transparent,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                child: Column(
                  children: [
                    StreamBuilder<int>(
                        stream: _totalStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.black));
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                (noOfItems == 0)
                                    ? const Text("\$0",
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold))
                                    : (noOfItems == 1)
                                        ? Text(
                                            "(${noOfItems}item) \$${snapshot.data}",
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold))
                                        : Text(
                                            "(${noOfItems}items) \$${snapshot.data}",
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold))
                              ],
                            ),
                          );
                        }),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40))),
                          onPressed: (noOfItems == 0)
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Payment feature currently not available")));
                                },
                          child: const Text("Proceed To Checkout",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold))),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
