import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/services/FirestoreService.dart';

class CartBottomBar extends StatefulWidget {
  final int noOfItems;
  CartBottomBar({this.noOfItems = 0});
  @override
  _CartBottomBarState createState() => _CartBottomBarState();
}

class _CartBottomBarState extends State<CartBottomBar> {
  final _firestoreInstance = FirestoreService();
  int _total = 0;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _firestoreInstance.userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            Map<String, dynamic> userFavoritesData =
                snapshot.data!.data() as Map<String, dynamic>;
            _total = userFavoritesData['total'];
            return Container(
              color: Colors.transparent,
              padding: EdgeInsets.fromLTRB(16, 10, 16, 30),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        (widget.noOfItems == 0 || snapshot.hasError)
                            ? Text("\$0",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold))
                            : (widget.noOfItems == 1)
                                ? Text("(${widget.noOfItems}item) \$$_total",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold))
                                : Text("(${widget.noOfItems}items) \$$_total",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
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
                        onPressed: (widget.noOfItems == 0)
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Payment feature currently not available")));
                              },
                        child: Text("Proceed To Checkout",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold))),
                  )
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator(color: Colors.black));
        });
  }
}
