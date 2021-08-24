import 'package:flutter/material.dart';

class ImageSwipeView extends StatefulWidget {
  final List imagesList;
  final String productId;
  ImageSwipeView({required this.imagesList, required this.productId});
  @override
  _ImageSwipeViewState createState() => _ImageSwipeViewState();
}

class _ImageSwipeViewState extends State<ImageSwipeView> {
  int _selectedPage = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Stack(
        children: [
          PageView(
            onPageChanged: (pageNum) {
              setState(() {
                _selectedPage = pageNum;
              });
            },
            children: [
              for (int i = 0; i < widget.imagesList.length; i++)
                Hero(
                  tag: widget.productId,
                  child: FadeInImage.assetNetwork(
                      fit: BoxFit.contain,
                      placeholder: "assets/loading_2.gif",
                      image: widget.imagesList[i]),
                ),
            ],
          ),
          Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (int i = 0; i < widget.imagesList.length; i++)
                AnimatedContainer(
                  curve: Curves.easeOutCubic,
                  width: (i == _selectedPage) ? 30 : 10,
                  height: 10,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.5),
                  ),
                  duration: Duration(milliseconds: 300),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}