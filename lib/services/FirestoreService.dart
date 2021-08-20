import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sneakerx/services/AuthenticationService.dart';

class FirestoreService {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;
  final String userId = AuthenticationService().getUser()!.uid;

  Future<Map<String, dynamic>?> getProduct(String productId) async {
    DocumentSnapshot<Map<String, dynamic>> documentData =
        await _instance.collection("products").doc(productId).get();
    if (documentData.exists) {
      return documentData.data();
    } else {
      return null;
    }
  }

  Future addToCart(String productId,
      {String color = '', int size = 0, int price = 0}) async {
    CollectionReference _cartReference =
        _instance.collection("users").doc(userId).collection("cart");
    DocumentSnapshot _documentSnapshot =
        await _instance.collection("users").doc(userId).get();
    Map<String, dynamic> totalData =
        _documentSnapshot.data() as Map<String, dynamic>;
    totalData['total'] =
        (totalData.keys.contains('total') ? totalData['total'] : 0) + price;
    await _instance
        .collection('users')
        .doc(userId)
        .update({'total': totalData['total']});
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
        await _cartReference.doc(newProductId).update({'quantity': quantity});
      } else {
        await _cartReference.doc(newProductId).set({'quantity': 1});
      }
    });
  }

  Future decrementQuantity(String productId,
      {String color = '', int size = 0, int price = 0}) async {
    CollectionReference _cartReference =
        _instance.collection("users").doc(userId).collection("cart");
    DocumentSnapshot _documentSnapshot =
        await _instance.collection("users").doc(userId).get();
    Map<String, dynamic> totalData =
        _documentSnapshot.data() as Map<String, dynamic>;
    totalData['total'] = totalData['total'] - price;
    await _instance
        .collection('users')
        .doc(userId)
        .update({'total': totalData['total']});

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

  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    DocumentSnapshot documentSnapshot =
        await _instance.collection("products").doc(productId).get();
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    return data;
  }

  Future createUserDetails() async {
    await _instance
        .collection('users')
        .doc(userId)
        .set({'total': 0, 'favorites': []});
  }

  Stream<QuerySnapshot> get productStream =>
      _instance.collection('products').snapshots();
  Stream<DocumentSnapshot> get userData =>
      _instance.collection('users').doc(userId).snapshots();
  Stream<QuerySnapshot> get cartStream =>
      _instance.collection('users').doc(userId).collection('cart').snapshots();
/*Used for updating data in case of image change
  void updateData() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _instance.collection("products").get();
    CollectionReference productsRef = _instance.collection('products');
    querySnapshot.docs.forEach((doc) {
      productsRef.doc(doc.id).update({
        'images': [
          'https://firebasestorage.googleapis.com/v0/b/sneakerx-28e9d.appspot.com/o/adidas%20human%20race-yellow.png?alt=media&token=9e483ca9-8831-4cbe-b465-57efe815ace6',
          'https://firebasestorage.googleapis.com/v0/b/sneakerx-28e9d.appspot.com/o/adidas%20human%20race-teal.png?alt=media&token=f5174839-d270-4b1e-b50f-d24e7b1bd4e4',
          'https://firebasestorage.googleapis.com/v0/b/sneakerx-28e9d.appspot.com/o/adidas%20human%20race-red.png?alt=media&token=0311e596-e456-4e9b-868d-a0fad871e586'
        ]
      });
    });
  }
 */
}
