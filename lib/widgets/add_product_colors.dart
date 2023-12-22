import 'package:flutter/material.dart';

class AddProductColors extends StatefulWidget {
  final Function(String) addColor;
  final Function(int) removeColor;

  const AddProductColors(
      {super.key, required this.addColor, required this.removeColor});

  @override
  State<AddProductColors> createState() => _AddProductColorsState();
}

class _AddProductColorsState extends State<AddProductColors> {
  List<String> productColors = [];
  List<String> availableColors = [
    'red',
    'black',
    'teal',
    'blue',
    'yellow',
    'green',
    'orange',
    'grey',
    'brown',
    'white'
  ];
  Color getColorFromString(String text) {
    if (text == "red") {
      return Colors.red;
    } else if (text == "black") {
      return Colors.black;
    } else if (text == "teal") {
      return Colors.teal;
    } else if (text == "blue") {
      return Colors.blue;
    } else if (text == "yellow") {
      return Colors.yellow;
    } else if (text == "green") {
      return Colors.green;
    } else if (text == "orange") {
      return Colors.orange;
    } else if (text == "grey") {
      return Colors.grey;
    } else if (text == "brown") {
      return Colors.brown;
    }
    return Colors.white;
  }

  void _chooseColorDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: const Color(0xFFF4F5FC),
            title: const Text("Choose a Color"),
            children: availableColors.map((availableColor) {
              return SimpleDialogOption(
                onPressed: () {
                  productColors.add(availableColor);
                  Navigator.pop(context);
                  setState(() {
                    widget.addColor(availableColor);
                    availableColors.remove(availableColor);
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          height: 50,
                          width: 50,
                          color: getColorFromString(availableColor)),
                    ),
                    Text(
                      availableColor,
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),
              );
            }).toList(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: productColors.length + 1,
        itemBuilder: (context, index) {
          if (index < productColors.length) {
            return Stack(
              children: [
                Container(
                  height: 100,
                  width: 80,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: getColorFromString(productColors[index])),
                ),
                Positioned(
                    right: -8,
                    top: -10,
                    child: IconButton(
                      onPressed: () {
                        widget.removeColor(index);
                        setState(() {
                          availableColors.add(productColors.removeAt(index));
                        });
                      },
                      icon: const Icon(
                        Icons.cancel,
                        size: 16,
                      ),
                    ))
              ],
            );
          }
          return IconButton(
              onPressed: () {
                _chooseColorDialog();
              },
              icon: const Icon(Icons.add));
        });
  }
}
