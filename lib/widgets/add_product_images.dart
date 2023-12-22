import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductImages extends StatefulWidget {
  final Function(File) addImage;
  final Function(int) removeImage;

  const AddProductImages(
      {super.key, required this.addImage, required this.removeImage});
  @override
  State<AddProductImages> createState() => _AddProductImagesState();
}

class _AddProductImagesState extends State<AddProductImages> {
  final ImagePicker _picker = ImagePicker();
  List<File> imagesList = [];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagesList.length + 1,
        itemBuilder: (context, index) {
          if (index < imagesList.length) {
            return Stack(
              children: [
                ClipRRect(
                  child: Image.file(imagesList[index]),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      onPressed: () {
                        widget.removeImage(index);
                        setState(() {
                          imagesList.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.cancel_outlined)),
                )
              ],
            );
          }
          return Container(
            width: 150,
            margin: EdgeInsets.only(
              left: (imagesList.isEmpty) ? 0 : 5,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: Colors.black12),
            child: IconButton(
                onPressed: () async {
                  final image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    final imageTemporary = File(image.path);
                    widget.addImage(imageTemporary);
                    setState(() {
                      imagesList.add(imageTemporary);
                    });
                  }
                },
                icon: const Icon(Icons.add_a_photo)),
          );
        });
  }
}
