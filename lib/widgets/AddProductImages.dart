import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductImages extends StatefulWidget {
  final Function(File) addImage;
  final Function(int) removeImage;
  AddProductImages({required this.addImage, required this.removeImage});
  @override
  _AddProductImagesState createState() => _AddProductImagesState();
}

class _AddProductImagesState extends State<AddProductImages> {
  final ImagePicker _picker = ImagePicker();
  List<File> _imagesList = [];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imagesList.length + 1,
        itemBuilder: (context, index) {
          if (index < _imagesList.length) {
            return Stack(
              children: [
                ClipRRect(
                  child: Image.file(_imagesList[index]),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      onPressed: () {
                        widget.removeImage(index);
                        setState(() {
                          _imagesList.removeAt(index);
                        });
                      },
                      icon: Icon(Icons.cancel_outlined)),
                )
              ],
            );
          }
          return Container(
            width: 150,
            color: Colors.black12,
            child: IconButton(
                onPressed: () async {
                  final image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    final imageTemporary = File(image.path);
                    widget.addImage(imageTemporary);
                    setState(() {
                      _imagesList.add(imageTemporary);
                    });
                  }
                },
                icon: Icon(Icons.add_a_photo)),
          );
        });
  }
}
