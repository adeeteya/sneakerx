import 'package:flutter/material.dart';

class MenuItem {
  final String text;
  final IconData icon;
  const MenuItem({required this.text, required this.icon});
}

class MenuItems {
  static const itemsList = [itemChangePfp, itemSignOut];
  static const itemChangePfp =
      MenuItem(text: "Change Profile Picture", icon: Icons.add_a_photo);
  static const itemSignOut = MenuItem(text: "Sign Out", icon: Icons.logout);
}
