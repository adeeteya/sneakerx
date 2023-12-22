import 'package:flutter/material.dart';

class SizeRow extends StatefulWidget {
  final List<int>? sizes;
  final Function(int)? onSelected;

  const SizeRow({super.key, required this.sizes, required this.onSelected});
  @override
  State<SizeRow> createState() => _SizeRowState();
}

class _SizeRowState extends State<SizeRow> {
  int _selectedSizePos = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Size",
          style: TextStyle(color: ThemeData.light().hintColor, fontSize: 16),
        ),
        const SizedBox(height: 5),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (int i = 0; i < widget.sizes!.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSelected!(i);
                      setState(() {
                        _selectedSizePos = i;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: (i == _selectedSizePos)
                            ? const Color(0xFFF68A0A)
                            : const Color(0xFFF4F5FC),
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    child: Text(
                      "US ${widget.sizes![i]}",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: (i == _selectedSizePos)
                              ? const Color(0xFFF4F5FC)
                              : const Color(0xFF1A191C)),
                    ),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
