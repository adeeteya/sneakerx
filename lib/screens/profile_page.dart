import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/models/menu_item.dart';
import 'package:sneakerx/services/authentication_service.dart';
import 'package:sneakerx/services/firestore_service.dart';
import 'package:sneakerx/widgets/uploaded_product_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firestoreInstance = FirestoreService();
  final _user = AuthenticationService().getUser();
  void _signOutDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Sign Out'),
              content: const Text("Do you really want to sign out?"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await AuthenticationService()
                          .signOut()
                          .then((value) => Navigator.pop(context));
                    },
                    child: const Text("Yes"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<MenuItem>(
            color: const Color(0xFFF4F5FC),
            onSelected: (item) => onMenuItemSelected(context, item),
            itemBuilder: (context) => [
              ...MenuItems.itemsList.map(buildItem),
            ],
          ),
        ],
      ),
      body: Column(children: [
        (_user?.photoURL != null)
            ? Hero(
                tag: 'User Profile Image',
                child: CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage(_user?.photoURL ?? "")),
              )
            : const Hero(
                tag: 'User Profile Image',
                child: CircleAvatar(
                    radius: 64, backgroundImage: AssetImage("assets/user.png")),
              ),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            "${_user?.email}",
            style: const TextStyle(
                fontSize: 16, letterSpacing: 1.5, color: Colors.grey),
          ),
        ),
        const Divider(
          height: 20,
          indent: 20,
          endIndent: 20,
          thickness: 1.5,
        ),
        const Text(
          "Uploaded Sneakers",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
              stream: _firestoreInstance.userData,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.active) {
                  try {
                    List createdItems = snapshot.data!.get('products');
                    if (createdItems.isEmpty) {
                      return const Center(
                          child: Text('No Sneakers Uploaded',
                              style: TextStyle(color: Colors.grey)));
                    }
                    return ListView(
                        children: createdItems
                            .map((createdItem) =>
                                UploadedProductTile(productId: createdItem))
                            .toList());
                  } catch (e) {
                    return const Center(
                        child: Text('No Sneakers Uploaded',
                            style: TextStyle(color: Colors.grey)));
                  }
                }
                return const Center(
                    child: CircularProgressIndicator(color: Colors.black));
              }),
        ),
      ]),
    );
  }

  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem<MenuItem>(
        value: item,
        child: Row(
          children: [
            Icon(item.icon),
            const SizedBox(width: 12),
            Text(item.text)
          ],
        ),
      );
  void onMenuItemSelected(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.itemChangePfp:
        break;
      case MenuItems.itemSignOut:
        _signOutDialog();
        break;
    }
  }
}
