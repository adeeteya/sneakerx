import 'package:flutter/material.dart';

class ColorRow extends StatefulWidget {
  final List? colors;
  final Function(int)? onSelected;

  const ColorRow({super.key, this.colors, this.onSelected});
  @override
  State<ColorRow> createState() => _ColorRowState();
}

class _ColorRowState extends State<ColorRow> {
  int _selectedColorPos = 0;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Color",
          style: TextStyle(color: ThemeData.light().hintColor, fontSize: 16),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 58,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                for (int i = 0; i < widget.colors!.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: GestureDetector(
                      onTap: () {
                        widget.onSelected!(i);
                        setState(() {
                          _selectedColorPos = i;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        width: (i == _selectedColorPos) ? 58 : 50,
                        height: (i == _selectedColorPos) ? 58 : 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: getColorFromString(widget.colors![i]),
                          border: Border.all(
                            width: 4,
                            color: (i == _selectedColorPos)
                                ? const Color(0xFFF68A0A)
                                : const Color(0xFFF4F5FC),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
