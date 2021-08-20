import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/loading.dart';
import 'package:sneakerx/services/FirestoreService.dart';
import 'package:sneakerx/widgets/CartBottomBar.dart';
import 'package:sneakerx/widgets/CartListTile.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _firebaseInstance = FirestoreService();
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
            return Loading();
          }
          List<DocumentSnapshot> cartItemsSnapshot = snapshot.data!.docs;
          List<Map<String, dynamic>> cartItems = [];
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
            if (productId[splitPos + 2] == '0' ||
                productId[splitPos + 2] == '1' ||
                productId[splitPos + 2] == '2' ||
                productId[splitPos + 2] == '3' ||
                productId[splitPos + 2] == '4' ||
                productId[splitPos + 2] == '5' ||
                productId[splitPos + 2] == '6' ||
                productId[splitPos + 2] == '7' ||
                productId[splitPos + 2] == '8' ||
                productId[splitPos + 2] == '9') {
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
                    return CartListTile(
                      productId: cartItem['productId'],
                      chosenSize: cartItem['chosenSize'],
                      chosenColor: cartItem['chosenColor'],
                      quantity: cartItem['quantity'],
                    );
                  }).toList(), //sizedBox(h-20)
                ),
              ),
              SizedBox(height: 20),
              CartBottomBar(noOfItems: cartItems.length)
            ],
          );
        },
      ),
    );
  }
}
