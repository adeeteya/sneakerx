import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sneakerx/models/product_model.dart';
import 'package:sneakerx/services/authentication_service.dart';

class FirestoreService {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;
  final CollectionReference<Product> _productsRef =
      FirebaseFirestore.instance.collection('products').withConverter<Product>(
            fromFirestore: (snapshot, _) => Product.fromJson(snapshot.data()!),
            toFirestore: (product, _) => product.toJson(),
          );
  final String userId = AuthenticationService().getUser()!.uid;

  Future createUserDetails() async {
    await _instance
        .collection('users')
        .doc(userId)
        .set({'favorites': [], 'products': []});
  }

  Future<Product> getProductDetails(String productId) async {
    DocumentSnapshot documentSnapshot = await _productsRef.doc(productId).get();
    return documentSnapshot.data() as Product;
  }

  Future addToCart(String productId, {String color = '', int size = 0}) async {
    CollectionReference cartReference =
        _instance.collection("users").doc(userId).collection("cart");
    String newProductId = "${color}0$size$productId";
    DocumentReference documentReference = _instance
        .collection("users")
        .doc(userId)
        .collection("cart")
        .doc(newProductId);
    documentReference.get().then((documentSnapshot) async {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        int quantity = data['quantity'] + 1;
        await cartReference.doc(newProductId).update(
            {'quantity': quantity, 'timeStamp': FieldValue.serverTimestamp()});
      } else {
        await cartReference
            .doc(newProductId)
            .set({'quantity': 1, 'timeStamp': FieldValue.serverTimestamp()});
      }
    });
  }

  Future decrementQuantity(String productId,
      {String color = '', int size = 0}) async {
    CollectionReference cartReference =
        _instance.collection("users").doc(userId).collection("cart");
    String newProductId = "${color}0$size$productId";
    DocumentReference documentReference = _instance
        .collection("users")
        .doc(userId)
        .collection("cart")
        .doc(newProductId);
    documentReference.get().then((documentSnapshot) async {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        int quantity = data['quantity'] - 1;
        if (quantity == 0) {
          await cartReference.doc(newProductId).delete();
        } else {
          await cartReference.doc(newProductId).update({'quantity': quantity});
        }
      }
    });
  }

  Future toggleFavorite(String productId) async {
    DocumentSnapshot documentSnapshot =
        await _instance.collection("users").doc(userId).get();
    Map<String, dynamic> userFavoritesData =
        documentSnapshot.data() as Map<String, dynamic>;
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
    QuerySnapshot querySnapshot = await _instance
        .collection("users")
        .doc(userId)
        .collection('cart')
        .orderBy('timeStamp', descending: true)
        .limit(2)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      String productId = querySnapshot.docs.elementAt(i).id;
      productId = productId.substring(productId.indexOf('0') + 2);
      if (double.tryParse(productId[0]) != null) {
        productId = productId.substring(1);
      }
      Product productData = await getProductDetails(productId);
      imageUrls.add(productData.images![0]);
    }
    return imageUrls;
  }

  Future addProduct(Product data, List<File> images) async {
    DocumentReference productReference = await _productsRef.add(data);
    for (int i = 0; i < images.length; i++) {
      Reference ref =
          FirebaseStorage.instance.ref('products/${productReference.id}/$i');
      await ref.putFile(images[i]);
      String url = await ref.getDownloadURL();
      data.images!.add(url);
    }
    DocumentSnapshot documentSnapshot =
        await _instance.collection("users").doc(userId).get();
    Map<String, dynamic> userCreatedData =
        documentSnapshot.data() as Map<String, dynamic>;
    List productsList = userCreatedData['products'] ?? [];
    productsList.add(productReference.id);
    await _instance
        .collection('users')
        .doc(userId)
        .update({'products': productsList});
    await productReference.update({'images': data.images});
  }

  Future deleteProduct(String productId) async {
    //delete images from storage
    final firebaseStorage = FirebaseStorage.instance;
    Product productData = await getProductDetails(productId);
    List imagesUrl = productData.images!;
    for (int i = 0; i < imagesUrl.length; i++) {
      await firebaseStorage.refFromURL(imagesUrl[i]).delete();
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
