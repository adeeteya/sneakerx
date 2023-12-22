import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class Verification extends StatefulWidget {
  final Function toggleView;

  const Verification({super.key, required this.toggleView});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  User? user;
  late Timer timer;
  Future<void> checkEmailVerified() async {
    await user!.reload();
    if (user!.emailVerified) {
      timer.cancel();
      widget.toggleView();
    }
  }

  @override
  void initState() {
    user = Provider.of<User?>(context, listen: false);
    user!.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Confirm your Email Address",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
          ),
          Center(child: Lottie.asset("assets/lottie/email_verification.json")),
          const Text(
            "Check your inbox and your spam folder",
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}
