import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.black12,
  filled: true,
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFF68A0A),
      width: 2,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFf5f6f8),
      width: 2,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
);
