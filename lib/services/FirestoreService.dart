import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sneakerx/models/ProductModel.dart';
import 'package:sneakerx/services/AuthenticationService.dart';

class FirestoreService {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;
  final String userId = AuthenticationService().getUser()!.uid;

  Future createUserDetails() async {
    await _instance
        .collection('users')
        .doc(userId)
        .set({'favorites': [], 'products': []});
  }

  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    DocumentSnapshot documentSnapshot =
        await _instance.collection("products").doc(productId).get();
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    return data;
  }

  Future addToCart(String productId, {String color = '', int size = 0}) async {
    CollectionReference _cartReference =
        _instance.collection("users").doc(userId).collection("cart");
    String newProductId = color + "0$size" + productId;
    DocumentReference _documentReference = _instance
        .collection("users")
        .doc(userId)
        .collection("cart")
        .doc(newProductId);
    _documentReference.get().then((documentSnapshot) async {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        int quantity = data['quantity'] + 1;
        await _cartReference.doc(newProductId).update(
            {'quantity': quantity, 'timeStamp': FieldValue.serverTimestamp()});
      } else {
        await _cartReference
            .doc(newProductId)
            .set({'quantity': 1, 'timeStamp': FieldValue.serverTimestamp()});
      }
    });
  }

  Future decrementQuantity(String productId,
      {String color = '', int size = 0}) async {
    CollectionReference _cartReference =
        _instance.collection("users").doc(userId).collection("cart");
    String newProductId = color + "0$size" + productId;
    DocumentReference _documentReference = _instance
        .collection("users")
        .doc(userId)
        .collection("cart")
        .doc(newProductId);
    _documentReference.get().then((documentSnapshot) async {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        int quantity = data['quantity'] - 1;
        if (quantity == 0)
          await _cartReference.doc(newProductId).delete();
        else
          await _cartReference.doc(newProductId).update({'quantity': quantity});
      }
    });
  }

  Future toggleFavorite(String productId) async {
    DocumentSnapshot _documentSnapshot =
        await _instance.collection("users").doc(userId).get();
    Map<String, dynamic> userFavoritesData =
        _documentSnapshot.data() as Map<String, dynamic>;
    List favoritesList = userFavoritesData['favorites'];
    (favoritesList.contains(productId))
        ? favoritesList.remove(productId)
        : favoritesList.add(productId);
    await _instance
        .collection('users')
        .doc(userId)
        .set({"favorites": favoritesList}, SetOptions(merge: true));
  }

  Future<List<String>> getLastTwoCartImages() async {
    List<String> imageUrls = [];
    QuerySnapshot _querySnapshot = await _instance
        .collection("users")
        .doc(userId)
        .collection('cart')
        .orderBy('timeStamp', descending: true)
        .limit(2)
        .get();
    for (int i = 0; i < _querySnapshot.docs.length; i++) {
      String productId = _querySnapshot.docs.elementAt(i).id;
      productId = productId.substring(productId.indexOf('0') + 2);
      if (double.tryParse(productId[0]) != null) {
        productId = productId.substring(1);
      }
      Map<String, dynamic> productData = await getProductDetails(productId);
      imageUrls.add(productData['images'][0]);
    }
    return imageUrls;
  }

  Future addProduct(Product data, List<File> images) async {
    DocumentReference _productsReference =
        await _instance.collection('products').add({
      'brand': data.brand,
      'name': data.name,
      'price': data.price,
      'sizes': data.sizes,
      'colors': data.colors
    });
    for (int i = 0; i < images.length; i++) {
      Reference ref =
          FirebaseStorage.instance.ref('products/${_productsReference.id}/$i');
      await ref.putFile(images[i]);
      String url = await ref.getDownloadURL();
      data.images!.add(url);
    }
    DocumentSnapshot _documentSnapshot =
        await _instance.collection("users").doc(userId).get();
    Map<String, dynamic> userCreatedData =
        _documentSnapshot.data() as Map<String, dynamic>;
    List productsList = userCreatedData['products'] ?? [];
    productsList.add(_productsReference.id);
    await _instance
        .collection('users')
        .doc(userId)
        .update({'products': productsList});
    await _productsReference.update({'images': data.images});
  }

  Future deleteProduct(String productId) async {
    //delete images from storage
    final _firebaseStorage = FirebaseStorage.instance;
    Map<String, dynamic> productData = await getProductDetails(productId);
    List imagesUrl = productData['images'];
    print(imagesUrl);
    for (int i = 0; i < imagesUrl.length; i++) {
      await _firebaseStorage.refFromURL(imagesUrl[i]).delete();
    }
    //delete user data
    DocumentSnapshot documentSnapshot =
        await _instance.collection('users').doc(userId).get();
    List productsList = documentSnapshot.get('products');
    productsList.remove(productId);
    _instance
        .collection('users')
        .doc(userId)
        .update({'products': productsList});
    await _instance.collection('products').doc(productId).delete();
  }

  Stream<QuerySnapshot> get productStream =>
      _instance.collection('products').snapshots();
  Stream<DocumentSnapshot> get userData =>
      _instance.collection('users').doc(userId).snapshots();
  Stream<QuerySnapshot> get cartStream =>
      _instance.collection('users').doc(userId).collection('cart').snapshots();
}
