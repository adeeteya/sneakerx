import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/services/FirestoreService.dart';
import 'package:sneakerx/widgets/ColorRow.dart';
import 'package:sneakerx/widgets/CustomAppBar.dart';
import 'package:sneakerx/widgets/ImageSwipeView.dart';
import 'package:sneakerx/widgets/SizeRow.dart';

class ProductPage extends StatefulWidget {
  final String productId;
  ProductPage({required this.productId});
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _instance = FirestoreService();
  int _selectedSize = 0;
  String _selectedColor = "";
  void addToCart() async {
    await _instance.addToCart(widget.productId,
        size: _selectedSize, color: _selectedColor);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Product Added To Cart")));
  }

  Future toggleFavorite() async {
    await FirestoreService().toggleFavorite(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFAAA6D6),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _instance.getProductDetails(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text("$snapshot.error"),
              );
            } else if (snapshot.hasData) {
              Map<String, dynamic>? documentData = snapshot.data;
              _selectedColor = documentData!['colors'][0];
              _selectedSize = documentData['sizes'][0];
              return Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Stack(
                      children: [
                        ImageSwipeView(
                            imagesList: documentData['images'],
                            productId: widget.productId),
                        CustomAppBar(productId: widget.productId),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFFF4F5FC),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                documentData['brand'],
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                documentData['name'],
                                style: TextStyle(
                                    color: ThemeData.light().hintColor,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          SizeRow(
                              sizes: documentData['sizes'],
                              onSelected: (selected) {
                                _selectedSize = documentData['sizes'][selected];
                              }),
                          ColorRow(
                              colors: documentData['colors'],
                              onSelected: (selected) {
                                _selectedColor =
                                    documentData['colors'][selected];
                              }),
                          Container(
                            height: 70,
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Color(0xFFF68A0A),
                                borderRadius: BorderRadius.circular(35)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "\$${documentData['price']}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFFF4F5FC),
                                      fontWeight: FontWeight.w600),
                                ),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.shopping_cart_outlined,
                                      color: Color(0xFF1A191C)),
                                  onPressed: addToCart,
                                  label: Text("Add to Cart",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF1A191C),
                                        fontWeight: FontWeight.bold,
                                      )),
                                  style: ElevatedButton.styleFrom(
                                      primary: Color(0xFFF4F5FC),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }
          }
          return Center(
              child: CircularProgressIndicator(color: Color(0xFFF4F5FC)));
        },
      ),
    );
  }
}
