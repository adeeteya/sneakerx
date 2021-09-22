import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/screens/cart_page.dart';
import 'package:sneakerx/services/firestore_service.dart';
import 'package:sneakerx/widgets/color_row.dart';
import 'package:sneakerx/widgets/custom_app_bar.dart';
import 'package:sneakerx/widgets/image_swipe_view.dart';
import 'package:sneakerx/widgets/size_row.dart';

class ProductPage extends StatefulWidget {
  final String productId;

  const ProductPage({Key? key, required this.productId}) : super(key: key);
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _firestoreInstance = FirestoreService();
  int _selectedSize = 0;
  String _selectedColor = "";
  Future showCartItems() async {
    List<String> imageUrls = await _firestoreInstance.getLastTwoCartImages();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Cart', style: TextStyle(fontSize: 18)),
          Row(
            children: [
              if (imageUrls.isNotEmpty)
                CircleAvatar(backgroundImage: NetworkImage(imageUrls[0])),
              const SizedBox(width: 8),
              if (imageUrls.length == 2)
                CircleAvatar(backgroundImage: NetworkImage(imageUrls[1])),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFF68A0A)),
                    shape: BoxShape.circle),
                child: IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartPage()));
                  },
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFFAF5FC),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      duration: const Duration(seconds: 3),
      backgroundColor: const Color(0xFF1A191C),
    ));
  }

  void addToCart() async {
    await _firestoreInstance.addToCart(widget.productId,
        size: _selectedSize, color: _selectedColor);
    await Future.delayed(const Duration(milliseconds: 200));
    showCartItems();
  }

  Future toggleFavorite() async {
    await FirestoreService().toggleFavorite(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAAA6D6),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _firestoreInstance.getProductDetails(widget.productId),
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
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
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
                                style: const TextStyle(
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
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF68A0A),
                                borderRadius: BorderRadius.circular(35)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "\$${documentData['price']}",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFFF4F5FC),
                                      fontWeight: FontWeight.w600),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.shopping_cart_outlined,
                                      color: Color(0xFF1A191C)),
                                  onPressed: addToCart,
                                  label: const Text("Add to Cart",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF1A191C),
                                        fontWeight: FontWeight.bold,
                                      )),
                                  style: ElevatedButton.styleFrom(
                                      primary: const Color(0xFFF4F5FC),
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
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF4F5FC)));
        },
      ),
    );
  }
}
