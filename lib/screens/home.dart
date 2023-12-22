import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/screens/add_item_page.dart';
import 'package:sneakerx/screens/cart_page.dart';
import 'package:sneakerx/screens/profile_page.dart';
import 'package:sneakerx/services/authentication_service.dart';
import 'package:sneakerx/services/firestore_service.dart';
import 'package:sneakerx/widgets/products_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _firestoreInstance = FirestoreService();
  final _user = AuthenticationService().getUser();

  bool showFavorites = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFFF4F5FC),
              elevation: 0,
              leading: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()));
                },
                child: (_user?.photoURL != null)
                    ? Hero(
                        tag: 'User Profile Image',
                        child: CircleAvatar(
                            radius: 64,
                            backgroundImage:
                                NetworkImage(_user?.photoURL ?? "")),
                      )
                    : const Hero(
                        tag: 'User Profile Image',
                        child: CircleAvatar(
                            radius: 64,
                            backgroundImage: AssetImage("assets/user.png")),
                      ),
              ),
              expandedHeight: 120,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                title: (showFavorites)
                    ? const Text("Favorites")
                    : const Text("Catalog"),
                centerTitle: true,
              ),
              actions: [
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.search_rounded))
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
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Colors.black,
                          ),
                          label: const Text(
                            "Add Item",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddItemPage()));
                          }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showFavorites = !showFavorites;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: (showFavorites)
                                ? const Color(0xFFF68A0A)
                                : const Color(0xFFF4F5FC),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        child: (showFavorites)
                            ? const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.favorite_rounded,
                                color: Colors.black,
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CartPage()));
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        child: const Icon(
                          Icons.shopping_cart_rounded,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: _firestoreInstance.productStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(child: Text(snapshot.error.toString())),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                          child: CircularProgressIndicator(
                        color: Colors.black,
                      )),
                    );
                  }
                  List<DocumentSnapshot> productsSnapshot = snapshot.data!.docs;
                  return ProductsView(
                      productsSnapshot: productsSnapshot,
                      showFavorites: showFavorites);
                }),
          ],
        ),
      ),
    );
  }
}
