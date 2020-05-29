import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/states/app_state.dart';
import 'screens/homepage.dart';

import 'package:uber_clone/screens/homepage.dart';
import 'package:uber_clone/screens/loginpage.dart';

import 'screens/signup.dart';

//void main() => runApp(new MyApp());



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  return runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: AppState(),)
  ],
    child: MyApp(),));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
      title: 'trip planner',
      routes: <String, WidgetBuilder>{
        '/landingpage': (BuildContext context) => new MyApp(),
        '/signup': (BuildContext context) => new SignupPage(),
        '/homepage': (BuildContext context) => new HomePage()
      },

    );
  }
}

















//void main() {
//  WidgetsFlutterBinding.ensureInitialized();
//  return runApp(MultiProvider(providers: [
//    ChangeNotifierProvider.value(value: AppState(),)
//  ],
//    child: MyApp(),));
//}
//
//class MyApp extends StatelessWidget {
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      debugShowCheckedModeBanner: false,
//      title: 'trip planner',
//      theme: ThemeData(
//        primarySwatch: Colors.blue,
//      ),
//      home: MyHomePage(title: 'Trip Planner'),
//    );
//  }
//}
//
//


