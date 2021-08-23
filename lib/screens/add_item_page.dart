import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:sneakerx/models/ProductModel.dart';
import 'package:sneakerx/services/FirestoreService.dart';
import 'package:sneakerx/widgets/AddProductColors.dart';
import 'package:sneakerx/widgets/AddProductImages.dart';
import 'package:sneakerx/widgets/AddProductSizes.dart';
import '../constants.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _firestoreInstance = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<File> _imagesList = [];
  Product _product = Product(colors: [], sizes: [], images: []);
  void _errorDialog(String? message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Registration Failed"),
            content: Text(message ?? ""),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
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
        appBar: AppBar(title: Text("Add Item"), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Product Pictures",
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                flex: 2,
                child: AddProductImages(addImage: (image) {
                  _imagesList.add(image);
                }, removeImage: (index) {
                  _imagesList.removeAt(index);
                }),
              ),
              SizedBox(height: 20),
              Text(
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
                          _product.brand = val;
                        },
                        validator: (val) =>
                            val!.isEmpty ? "Please Enter a brand name" : null,
                        decoration:
                            textInputDecoration.copyWith(hintText: "Brand"),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        onChanged: (val) {
                          _product.name = val;
                        },
                        validator: (val) => val!.isEmpty
                            ? "Please Enter the product name"
                            : null,
                        decoration:
                            textInputDecoration.copyWith(hintText: "Name"),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          _product.price = int.parse(val);
                        },
                        validator: (val) =>
                            val!.isEmpty ? "Please Enter the price" : null,
                        decoration: textInputDecoration.copyWith(
                            prefixIcon: Icon(
                              Icons.attach_money,
                            ),
                            hintText: "Price"),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                "Product Sizes",
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                flex: 1,
                child: AddProductSizes(addSize: (size) {
                  _product.sizes!.add(size);
                }, removeSize: (index) {
                  _product.sizes!.removeAt(index);
                }),
              ),
              SizedBox(height: 5),
              Text(
                "Product Colors",
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                flex: 1,
                child: AddProductColors(
                  addColor: (colorString) => _product.colors!.add(colorString),
                  removeColor: (index) => _product.colors!.removeAt(index),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    height: 50,
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(primary: Color(0xFFF68A0A)),
                      onPressed: () async {
                        if (_imagesList.isEmpty) {
                          _errorDialog("Please Insert Product Images");
                        } else if (_product.sizes!.isEmpty) {
                          _errorDialog("Please Add Shoe Sizes");
                        } else if (_product.colors!.isEmpty) {
                          _errorDialog("Please Add Product Colors");
                        } else if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          await _firestoreInstance.addProduct(
                              _product, _imagesList);
                          _isLoading = false;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Product Added to the Catalog')));
                          Navigator.pop(context);
                        }
                      },
                      child: (_isLoading)
                          ? CircularProgressIndicator(color: Color(0xFFF4F5FC))
                          : Text(
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
