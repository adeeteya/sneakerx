import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/services/firestore_service.dart';

class CustomAppBar extends StatefulWidget {
  final String productId;

  const CustomAppBar({super.key, required this.productId});
  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final _firebaseInstance = FirestoreService();
  bool _isFavorite = false;
  Future toggleFavorite() async {
    await FirestoreService().toggleFavorite(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _firebaseInstance.userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          Map<String, dynamic> userFavoritesData =
              snapshot.data!.data() as Map<String, dynamic>;
          List favoritesList = userFavoritesData['favorites'];
          _isFavorite = favoritesList.contains(widget.productId);
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Color(0xFFF4F5FC)),
                ),
                IconButton(
                  onPressed: () {
                    toggleFavorite();
                  },
                  icon: (_isFavorite)
                      ? const Icon(Icons.favorite, color: Colors.red)
                      : const Icon(
                          Icons.favorite_outline,
                          color: Color(0xFFF4F5FC),
                        ),
                )
              ],
            ),
          );
        });
  }
}
