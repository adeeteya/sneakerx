import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/screens/product_page.dart';
import 'package:sneakerx/screens/profile_page.dart';
import 'package:sneakerx/services/FirestoreService.dart';
import 'package:sneakerx/widgets/ProductCard.dart';
import 'add_item_page.dart';
import 'cart_page.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _firestoreInstance = FirestoreService();
  Future showCartItems() async {
    List<String> imageUrls = await _firestoreInstance.getLastTwoCartImages();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Cart', style: TextStyle(fontSize: 18)),
          Row(
            children: [
              (imageUrls.isNotEmpty)
                  ? CircleAvatar(backgroundImage: NetworkImage(imageUrls[0]))
                  : SizedBox(),
              SizedBox(width: 8),
              (imageUrls.length == 2)
                  ? CircleAvatar(backgroundImage: NetworkImage(imageUrls[1]))
                  : SizedBox(),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFF68A0A)),
                    shape: BoxShape.circle),
                child: IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CartPage()));
                  },
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFFAF5FC),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      duration: Duration(seconds: 3),
      backgroundColor: Color(0xFF1A191C),
    ));
  }

  bool _showFavorites = false;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestoreInstance.productStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text(snapshot.error.toString())),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.black,
            ));
          }
          List<DocumentSnapshot> productsSnapshot = snapshot.data!.docs;
          return StreamBuilder<DocumentSnapshot>(
              stream: _firestoreInstance.userData,
              builder: (context, snapshot2) {
                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: Colors.black));
                }
                Map<String, dynamic> userData =
                    snapshot2.data!.data() as Map<String, dynamic>;
                List favoritesList = userData['favorites'];
                return Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          backgroundColor: Color(0xFFF4F5FC),
                          elevation: 0,
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage()));
                            },
                            child: FutureBuilder(
                                future: _firestoreInstance.getProfilePicture(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.data != null) {
                                      return Hero(
                                        tag: 'User Profile Image',
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              snapshot.data as String),
                                        ),
                                      );
                                    }
                                  }
                                  return Hero(
                                    tag: 'User Avatar Image',
                                    child: CircleAvatar(
                                      backgroundImage:
                                          AssetImage("assets/user.png"),
                                    ),
                                  );
                                }),
                          ),
                          expandedHeight: 120,
                          pinned: true,
                          flexibleSpace: FlexibleSpaceBar(
                            title: (_showFavorites)
                                ? Text("Favorites")
                                : Text("Catalog"),
                            centerTitle: true,
                          ),
                          actions: [
                            IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.search_rounded))
                          ],
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20))),
                                      icon: Icon(
                                        Icons.add_rounded,
                                        color: Colors.black,
                                      ),
                                      label: Text(
                                        "Add Item",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddItemPage()));
                                      }),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _showFavorites = !_showFavorites;
                                      });
                                    },
                                    child: (_showFavorites)
                                        ? Icon(
                                            Icons.favorite_rounded,
                                            color: Colors.white,
                                          )
                                        : Icon(
                                            Icons.favorite_rounded,
                                            color: Colors.black,
                                          ),
                                    style: ElevatedButton.styleFrom(
                                        primary: (_showFavorites)
                                            ? Color(0xFFF68A0A)
                                            : Color(0xFFF4F5FC),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 20),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CartPage()));
                                    },
                                    child: Icon(
                                      Icons.shopping_cart_rounded,
                                      color: Colors.black,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 20),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        (_showFavorites)
                            ? (favoritesList.isEmpty)
                                ? SliverFillRemaining(
                                    child: Center(child: Text("No Favorites")))
                                : SliverGrid(
                                    delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                      String docId = favoritesList[index];
                                      Map<String, dynamic>? data =
                                          productsSnapshot
                                              .firstWhere((element) {
                                        return element.id == docId;
                                      }).data() as Map<String, dynamic>;
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductPage(
                                                          productId: docId)));
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
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 0.6,
                                            mainAxisSpacing: 10),
                                  )
                            : SliverGrid(
                                delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  DocumentSnapshot productSnapshot =
                                      productsSnapshot.elementAt(index);
                                  Map<String, dynamic> data = productSnapshot
                                      .data()! as Map<String, dynamic>;
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ProductPage(
                                                  productId:
                                                      productSnapshot.id)));
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
                                      isFavorite: favoritesList
                                          .contains(productSnapshot.id),
                                    ),
                                  );
                                }, childCount: productsSnapshot.length),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.6,
                                  mainAxisSpacing: 10,
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              });
        });
  }
}
