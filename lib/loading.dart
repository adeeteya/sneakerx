import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF1a191c),
      child: Center(child: Lottie.asset("assets/lottie/loading.json")),
    );
  }
}
