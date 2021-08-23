import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/loading.dart';
import 'package:sneakerx/services/AuthenticationService.dart';

import '../constants.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({required this.toggleView});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final _authInstance = AuthenticationService();
  String _email = '';
  String _password = '';
  bool _hiddenPassword = true;
  bool isLoading = false;

  void showSnackBar(String? message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message ?? "")));
  }

  void _errorDialog(String? message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Registration Failed"),
            content: Text(message ?? ""),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
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
    if (isLoading) {
      return Loading();
    } else {
      return Scaffold(
        body: SafeArea(
            child: Padding(
          padding: EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFFF68A0A),
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 5),
                Text(
                  "We are happy to see you back,Please sign in to continue",
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w100),
                ),
                SizedBox(height: 30),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  onChanged: (val) {
                    _email = val;
                  },
                  validator: (val) =>
                      val!.isEmpty ? "Please Enter your email" : null,
                  autofocus: true,
                  decoration: textInputDecoration.copyWith(hintText: "Email"),
                ),
                SizedBox(height: 10),
                TextFormField(
                  obscureText: _hiddenPassword,
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
                SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(primary: Color(0xFFF68A0A)),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          dynamic result =
                              await _authInstance.signInWithEmailAndPassword(
                                  email: _email, password: _password);
                          setState(() {
                            isLoading = false;
                          });
                          if (result.runtimeType == FirebaseAuthException) {
                            FirebaseAuthException e =
                                result as FirebaseAuthException;
                            _errorDialog(e.message);
                          }
                        }
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          widget.toggleView();
                        },
                        child: Text("New User?")),
                    TextButton(
                        onPressed: () async {
                          if (_email.isEmpty) {
                            showSnackBar("Please enter an email");
                            return;
                          }
                          dynamic result =
                              await _authInstance.resetPassword(email: _email);
                          if (result.runtimeType == FirebaseAuthException) {
                            FirebaseAuthException e =
                                result as FirebaseAuthException;
                            showSnackBar(e.message);
                          } else {
                            showSnackBar(
                                "Password Reset Request Sent Successfully");
                          }
                        },
                        child: Text("Forgot Password?")),
                  ],
                )
              ],
            ),
          ),
        )),
      );
    }
  }
}
