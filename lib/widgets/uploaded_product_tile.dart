import 'package:flutter/material.dart';
import 'package:sneakerx/models/product_model.dart';
import 'package:sneakerx/services/firestore_service.dart';

class UploadedProductTile extends StatefulWidget {
  final String productId;

  const UploadedProductTile({super.key, required this.productId});
  @override
  State<UploadedProductTile> createState() => _UploadedProductTileState();
}

class _UploadedProductTileState extends State<UploadedProductTile> {
  final _firestoreInstance = FirestoreService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
        future: _firestoreInstance.getProductDetails(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Product may have been removed"));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Product? product = snapshot.data;
            if (product == null) {
              return const Center(child: Text("Product may have been removed"));
            }
            return Card(
              color: const Color(0xFFF4F5FC),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ListTile(
                leading: AspectRatio(
                  aspectRatio: 1.5,
                  child: FadeInImage.assetNetwork(
                      fit: BoxFit.fitWidth,
                      placeholder: 'assets/loading.gif',
                      image: product.images![0]),
                ),
                title:
                    Text(product.brand, style: const TextStyle(fontSize: 18)),
                subtitle: Text(
                  product.name,
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[300]),
                    onPressed: () {
                      _firestoreInstance.deleteProduct(widget.productId);
                    }),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        });
  }
}
