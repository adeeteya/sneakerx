import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/services/FirestoreService.dart';

class UploadedProductTile extends StatefulWidget {
  final String productId;
  UploadedProductTile({required this.productId});
  @override
  _UploadedProductTileState createState() => _UploadedProductTileState();
}

class _UploadedProductTileState extends State<UploadedProductTile> {
  final _firestoreInstance = FirestoreService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: _firestoreInstance.getProductDetails(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Product may have been removed"));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic>? data = snapshot.data;
            if (data == null) {
              return Center(child: Text("Product may have been removed"));
            }
            return Card(
              color: Color(0xFFF4F5FC),
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ListTile(
                leading: AspectRatio(
                  aspectRatio: 1.5,
                  child: FadeInImage.assetNetwork(
                      fit: BoxFit.fitWidth,
                      placeholder: 'assets/loading.gif',
                      image: data['images'][0]),
                ),
                title: Text(data['brand'], style: TextStyle(fontSize: 18)),
                subtitle: Text(
                  data['name'],
                  style: TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[300]),
                    onPressed: () {
                      _firestoreInstance.deleteProduct(widget.productId);
                    }),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        });
  }
}
