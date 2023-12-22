import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sneakerx/constants.dart';
import 'package:sneakerx/models/product_model.dart';
import 'package:sneakerx/services/firestore_service.dart';
import 'package:sneakerx/widgets/add_product_colors.dart';
import 'package:sneakerx/widgets/add_product_images.dart';
import 'package:sneakerx/widgets/add_product_sizes.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _firestoreInstance = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<File> imagesList = [];
  Product product = Product(colors: [], sizes: [], images: []);
  void _errorDialog(String? message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Product Upload Failed"),
            content: Text(message ?? ""),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Ok",
                    style: TextStyle(
                        color: Color(0xFFAAA6D6), fontWeight: FontWeight.bold),
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text("Add Item")),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Product Pictures",
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                flex: 2,
                child: AddProductImages(addImage: (image) {
                  imagesList.add(image);
                }, removeImage: (index) {
                  imagesList.removeAt(index);
                }),
              ),
              const SizedBox(height: 20),
              const Text(
                "Product Details",
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                flex: 3,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        onChanged: (val) {
                          product.brand = val;
                        },
                        validator: (val) =>
                            val!.isEmpty ? "Please Enter a brand name" : null,
                        decoration:
                            textInputDecoration.copyWith(hintText: "Brand"),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        onChanged: (val) {
                          product.name = val;
                        },
                        validator: (val) => val!.isEmpty
                            ? "Please Enter the product name"
                            : null,
                        decoration:
                            textInputDecoration.copyWith(hintText: "Name"),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          product.price = int.parse(val);
                        },
                        validator: (val) =>
                            val!.isEmpty ? "Please Enter the price" : null,
                        decoration: textInputDecoration.copyWith(
                            prefixIcon: const Icon(
                              Icons.attach_money,
                            ),
                            hintText: "Price"),
                      ),
                    ],
                  ),
                ),
              ),
              const Text(
                "Product Sizes",
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                flex: 1,
                child: AddProductSizes(addSize: (size) {
                  product.sizes!.add(size);
                }, removeSize: (index) {
                  product.sizes!.removeAt(index);
                }),
              ),
              const SizedBox(height: 5),
              const Text(
                "Product Colors",
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                flex: 1,
                child: AddProductColors(
                  addColor: (colorString) => product.colors!.add(colorString),
                  removeColor: (index) => product.colors!.removeAt(index),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF68A0A)),
                      onPressed: () async {
                        if (imagesList.isEmpty) {
                          _errorDialog("Please Insert Product Images");
                        } else if (product.sizes!.isEmpty) {
                          _errorDialog("Please Add Shoe Sizes");
                        } else if (product.colors!.isEmpty) {
                          _errorDialog("Please Add Product Colors");
                        } else if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          product.sizes?.sort();
                          await _firestoreInstance
                              .addProduct(product, imagesList)
                              .then((value) {
                            _isLoading = false;
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Product Added to the Catalog')));
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: (_isLoading)
                          ? const CircularProgressIndicator(
                              color: Color(0xFFF4F5FC))
                          : const Text(
                              "Add Item",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
//Todo:better scrollable design,custom user model,user page,search
