import 'package:flutter/material.dart';
import 'package:sneakerx/models/product_model.dart';
import 'package:sneakerx/screens/cart_page.dart';
import 'package:sneakerx/services/firestore_service.dart';
import 'package:sneakerx/widgets/color_row.dart';
import 'package:sneakerx/widgets/custom_app_bar.dart';
import 'package:sneakerx/widgets/image_swipe_view.dart';
import 'package:sneakerx/widgets/size_row.dart';

class ProductPage extends StatefulWidget {
  final String productId;
  final Product product;

  const ProductPage(
      {super.key, required this.productId, required this.product});
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _slideUpAnimation;
  late Animation<double> _fadeAnimation;
  final _firestoreInstance = FirestoreService();
  int selectedSize = 0;
  String selectedColor = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutSine)));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1, curve: Curves.easeIn)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future showCartItems() async {
    await _firestoreInstance.getLastTwoCartImages().then((imageUrls) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF1A191C),
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
      ));
    });
  }

  void addToCart() async {
    await _firestoreInstance.addToCart(widget.productId,
        size: selectedSize, color: selectedColor);
    await Future.delayed(const Duration(milliseconds: 200));
    showCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAAA6D6),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                ImageSwipeView(
                    imagesList: widget.product.images,
                    productId: widget.productId),
                CustomAppBar(productId: widget.productId),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: SlideTransition(
              position: _slideUpAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F5FC),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50)),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.brand,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            widget.product.name,
                            style: TextStyle(
                                color: ThemeData.light().hintColor,
                                fontSize: 16),
                          ),
                        ],
                      ),
                      SizeRow(
                          sizes: widget.product.sizes,
                          onSelected: (selected) {
                            selectedSize = widget.product.sizes![selected];
                          }),
                      ColorRow(
                          colors: widget.product.colors,
                          onSelected: (selected) {
                            selectedColor = widget.product.colors![selected];
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
                              "\$${widget.product.price}",
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
                                  backgroundColor: const Color(0xFFF4F5FC),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
