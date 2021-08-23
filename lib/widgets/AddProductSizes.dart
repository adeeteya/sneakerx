import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class AddProductSizes extends StatefulWidget {
  final Function(int) addSize;
  final Function(int) removeSize;
  AddProductSizes({required this.addSize, required this.removeSize});
  @override
  _AddProductSizesState createState() => _AddProductSizesState();
}

class _AddProductSizesState extends State<AddProductSizes> {
  List _productSizes = [];
  int? _pickedNumber = 3;
  Future<int?> showMyNumberPicker() async {
    return showDialog<int>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Choose a size"),
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
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  child: Text("Cancel"),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(_pickedNumber);
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
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
        itemCount: _productSizes.length + 1,
        itemBuilder: (context, index) {
          _productSizes.sort();
          if (index < _productSizes.length) {
            return Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(right: 5),
                  height: 100,
                  width: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white),
                  child: Center(
                    child: Text(
                      "US ${_productSizes[index]}",
                      style: TextStyle(
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
                          _productSizes.removeAt(index);
                        });
                      },
                      icon: Icon(
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
                    _productSizes.contains(_pickedNumber) == false) {
                  widget.addSize(_pickedNumber!);
                  setState(() {
                    _productSizes.add(_pickedNumber);
                  });
                }
              },
              icon: Icon(Icons.add));
        });
  }
}
