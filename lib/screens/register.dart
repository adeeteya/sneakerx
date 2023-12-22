import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/constants.dart';
import 'package:sneakerx/loading.dart';
import 'package:sneakerx/services/authentication_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _authInstance = AuthenticationService();
  String _email = '';
  String _password = '';
  bool _hiddenPassword = true;
  bool _agree = false;
  bool isLoading = false;

  void _errorDialog(String? message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Registration Failed"),
            content: Text(message ?? ""),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Ok",
                    style: TextStyle(
                        color: Color(0xFFAAA6D6), fontWeight: FontWeight.bold),
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Loading()
        : Scaffold(
            body: SafeArea(
                minimum: const EdgeInsets.only(top: 50, left: 20, right: 20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const Text(
                        "Create a New Account",
                        style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFFF68A0A),
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Create a new account so you could save and order sneakers",
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w100),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        onChanged: (val) {
                          _email = val;
                        },
                        validator: (val) =>
                            val!.isEmpty ? "Please Enter your email" : null,
                        autofocus: true,
                        decoration:
                            textInputDecoration.copyWith(hintText: "Email"),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        obscureText: _hiddenPassword,
                        textInputAction: TextInputAction.next,
                        onChanged: (val) {
                          _password = val;
                        },
                        validator: (val) => val!.length < 6
                            ? "Password must be more than 6 characters"
                            : null,
                        decoration: textInputDecoration.copyWith(
                            hintText: "Password",
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _hiddenPassword = !_hiddenPassword;
                                });
                              },
                              icon: Icon(
                                (_hiddenPassword)
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            )),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                          obscureText: _hiddenPassword,
                          validator: (val) => val!.compareTo(_password) != 0
                              ? "Passwords don't match"
                              : null,
                          decoration: textInputDecoration.copyWith(
                            hintText: "Re-enter Password",
                          )),
                      const SizedBox(height: 5),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _agree,
                              activeColor: const Color(0xFFF68A0A),
                              onChanged: (val) {
                                setState(() {
                                  _agree = !_agree;
                                });
                              },
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                    text: "I agree to the ",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontFamily: 'Futura'),
                                    children: [
                                      TextSpan(
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              launchUrl(Uri.parse(
                                                  "https://www.youtube.com/watch?v=dQw4w9WgXcQ"));
                                            },
                                          text: "Terms of service",
                                          style: const TextStyle(
                                              color: Colors.blueAccent)),
                                      const TextSpan(text: " and the "),
                                      TextSpan(
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              launchUrl(Uri.parse(
                                                  "https://www.youtube.com/watch?v=dQw4w9WgXcQ"));
                                            },
                                          text: "Privacy policy",
                                          style: const TextStyle(
                                              color: Colors.blueAccent))
                                    ]),
                              ),
                            ),
                          ]),
                      const SizedBox(height: 60),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF68A0A)),
                            onPressed: !_agree
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      dynamic result = await _authInstance
                                          .createUserWithEmailAndPassword(
                                              email: _email,
                                              password: _password);
                                      setState(() {
                                        isLoading = false;
                                      });
                                      if (result.runtimeType ==
                                          FirebaseAuthException) {
                                        FirebaseAuthException e =
                                            result as FirebaseAuthException;
                                        _errorDialog(e.message);
                                      }
                                    }
                                  },
                            child: const Text(
                              "Create Account",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            widget.toggleView();
                          },
                          child: const Text("Already have a account?")),
                    ],
                  ),
                )),
          );
  }
}
