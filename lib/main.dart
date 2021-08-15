import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/services/AuthenticationService.dart';
import 'package:sneakerx/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      catchError: (_, __) => null,
      initialData: null,
      value: AuthenticationService().onAuthStateChanged,
      child: MaterialApp(
        title: "Sneaker Store",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Color(0xFFF4F5FC),
          primaryColor: Color(0xFFF68A0A),
          fontFamily: "Futura",
        ),
        home: Wrapper(),
      ),
    );
  }
}
