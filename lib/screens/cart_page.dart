import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/services/FirestoreService.dart';
import 'package:sneakerx/widgets/CartListTile.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _firebaseInstance = FirestoreService();
  final _controller = StreamController<int>();
  Stream<int> get _totalStream => _controller.stream;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cart")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseInstance.cartStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFF1A191C)));
          }
          List<DocumentSnapshot> cartItemsSnapshot = snapshot.data!.docs;
          List<Map<String, dynamic>> cartItems = [];
          int _noOfItems = cartItemsSnapshot.length;
          if (_noOfItems == 0) _controller.sink.add(0);
          int _total = 0;
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
                  padding: EdgeInsets.fromLTRB(8, 10, 8, 20),
                  children: cartItems.map((cartItem) {
                    return FutureBuilder<Map<String, dynamic>>(
                        future: _firebaseInstance
                            .getProductDetails(cartItem['productId']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: Colors.black,
                            ));
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text("${snapshot.error}"));
                          }
                          Map<String, dynamic>? data = snapshot.data;
                          _total +=
                              (data!['price'] * cartItem['quantity']) as int;
                          _controller.sink.add(_total);
                          return CartListTile(
                            productId: cartItem['productId'],
                            chosenSize: cartItem['chosenSize'],
                            chosenColor: cartItem['chosenColor'],
                            quantity: cartItem['quantity'],
                            imageUrl: data['images'][0],
                            brand: data['brand'],
                            name: data['name'],
                            price: data['price'],
                          );
                        });
                  }).toList(), //sizedBox(h-20)
                ),
              ),
              SizedBox(height: 20),
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(16, 10, 16, 30),
                child: Column(
                  children: [
                    StreamBuilder<int>(
                        stream: _totalStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                                    color: Colors.black));
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                (_noOfItems == 0)
                                    ? Text("\$0",
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold))
                                    : (_noOfItems == 1)
                                        ? Text(
                                            "(${_noOfItems}item) \$${snapshot.data}",
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold))
                                        : Text(
                                            "(${_noOfItems}items) \$${snapshot.data}",
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold))
                              ],
                            ),
                          );
                        }),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40))),
                          onPressed: (_noOfItems == 0)
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Payment feature currently not available")));
                                },
                          child: Text("Proceed To Checkout",
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
