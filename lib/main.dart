import 'package:flutter/material.dart';
import './myImagePicker.dart';
import './introduction_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // Ketika route '/' itu menavigasikan ke dalam introduction page.
        '/': (context) => MySwiperApp(),
        '/imagePicker': (context) => MyImagePicker(),
      },
    );
  }
}
