import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a191c),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset("assets/lottie/loading.json"),
          const Text(
            'Loading',
            style: TextStyle(
                color: Color(0xFFF4F5FC), letterSpacing: 2, fontSize: 32),
          ),
        ],
      ),
    );
  }
}
