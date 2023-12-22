import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class AddProductSizes extends StatefulWidget {
  final Function(int) addSize;
  final Function(int) removeSize;

  const AddProductSizes(
      {super.key, required this.addSize, required this.removeSize});
  @override
  State<AddProductSizes> createState() => _AddProductSizesState();
}

class _AddProductSizesState extends State<AddProductSizes> {
  List productSizes = [];
  int? _pickedNumber = 3;
  Future<int?> showMyNumberPicker() async {
    return showDialog<int>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Choose a size"),
            content: NumberPicker(
              minValue: 2,
              maxValue: 37,
              value: _pickedNumber ?? 3,
              onChanged: (value) {
                setState(() {
                  _pickedNumber = value;
                });
              },
            ),
            actions: <Widget>[
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  child: Text("Cancel"),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(_pickedNumber);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  child: Text("Ok"),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: productSizes.length + 1,
        itemBuilder: (context, index) {
          productSizes.sort();
          if (index < productSizes.length) {
            return Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 5),
                  height: 100,
                  width: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white),
                  child: Center(
                    child: Text(
                      "US ${productSizes[index]}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A191C)),
                    ),
                  ),
                ),
                Positioned(
                    right: -5,
                    top: -10,
                    child: IconButton(
                      onPressed: () {
                        widget.removeSize(index);
                        setState(() {
                          productSizes.removeAt(index);
                        });
                      },
                      icon: const Icon(
                        Icons.cancel,
                        size: 16,
                      ),
                    )),
              ],
            );
          }
          return IconButton(
              onPressed: () async {
                _pickedNumber = (await showMyNumberPicker());
                if (_pickedNumber != null &&
                    productSizes.contains(_pickedNumber) == false) {
                  widget.addSize(_pickedNumber!);
                  setState(() {
                    productSizes.add(_pickedNumber);
                  });
                }
              },
              icon: const Icon(Icons.add));
        });
  }
}
