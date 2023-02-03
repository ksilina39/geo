import 'package:flutter/material.dart';
import 'package:geo/yandex_map_page.dart';
import 'first_page.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/first_page',
        routes: {
          '/first_page':(context) => const PlacemarksPage(),
          '/yandex_map_page':(context) => const YandexMapPage()
        },
    );
  }
}