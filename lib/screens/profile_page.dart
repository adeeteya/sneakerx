import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sneakerx/services/AuthenticationService.dart';
import 'package:sneakerx/services/FirestoreService.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firestoreInstance = FirestoreService();
  final _userInstance = AuthenticationService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        FutureBuilder(
            future: _firestoreInstance.getProfilePicture(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  return Hero(
                    tag: 'User Profile Image',
                    child: CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(snapshot.data as String)),
                  );
                }
              }
              return Hero(
                tag: 'User Avatar Image',
                child: CircleAvatar(
                    radius: 64, backgroundImage: AssetImage("assets/user.png")),
              );
            }),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            "${_userInstance.getUser()!.email}",
            style:
                TextStyle(fontSize: 16, letterSpacing: 1.5, color: Colors.grey),
          ),
        ),
        Divider(
          height: 20,
          indent: 20,
          endIndent: 20,
          thickness: 1.5,
        ),
        Text(
          "Uploaded Sneakers",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        Expanded(
            child: StreamBuilder<Object>(
                stream: null,
                builder: (context, snapshot) {
                  return ListView();
                })),
      ]),
    );
  }
}
