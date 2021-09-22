import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/screens/cart_page.dart';
import 'package:sneakerx/screens/product_page.dart';
import 'package:sneakerx/services/firestore_service.dart';
import 'package:sneakerx/widgets/product_card.dart';

class ProductsView extends StatefulWidget {
  final List<DocumentSnapshot> productsSnapshot;
  final bool showFavorites;
  const ProductsView(
      {Key? key, required this.productsSnapshot, required this.showFavorites})
      : super(key: key);

  @override
  _ProductsViewState createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final _firestoreInstance = FirestoreService();
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _firestoreInstance.userData,
        builder: (context, snapshot2) {
          if (snapshot2.connectionState == ConnectionState.waiting) {
            return const SliverFillRemaining(
              child:
                  Center(child: CircularProgressIndicator(color: Colors.black)),
            );
          }
          Map<String, dynamic> userData =
              snapshot2.data!.data() as Map<String, dynamic>;
          List favoritesList = userData['favorites'];
          if (widget.showFavorites) {
            if (favoritesList.isEmpty) {
              return const SliverFillRemaining(
                  child: Center(child: Text("No Favorites")));
            } else {
              return SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  String docId = favoritesList[index];
                  Map<String, dynamic>? data =
                      widget.productsSnapshot.firstWhere((element) {
                    return element.id == docId;
                  }).data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProductPage(productId: docId)));
                    },
                    child: ProductCard(
                      productId: docId,
                      brand: data['brand'],
                      name: data['name'],
                      price: data['price'],
                      imageUrl: data['images'][0],
                      defaultSize: data['sizes'][0],
                      defaultColor: data['colors'][0],
                      showCartItems: showCartItems,
                      isFavorite: true,
                    ),
                  );
                }, childCount: favoritesList.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    mainAxisSpacing: 10),
              );
            }
          } else {
            return SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                DocumentSnapshot productSnapshot =
                    widget.productsSnapshot.elementAt(index);
                Map<String, dynamic> data =
                    productSnapshot.data()! as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProductPage(productId: productSnapshot.id)));
                  },
                  child: ProductCard(
                    productId: productSnapshot.id,
                    brand: data['brand'],
                    name: data['name'],
                    price: data['price'],
                    imageUrl: data['images'][0],
                    defaultSize: data['sizes'][0],
                    defaultColor: data['colors'][0],
                    showCartItems: showCartItems,
                    isFavorite: favoritesList.contains(productSnapshot.id),
                  ),
                );
              }, childCount: widget.productsSnapshot.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                mainAxisSpacing: 10,
              ),
            );
          }
        });
  }
}
