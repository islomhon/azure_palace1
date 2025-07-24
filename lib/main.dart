import 'package:flutter/material.dart';
import 'dart:io';
import 'package:zure_palace/screens/HomeScreen.dart';
import 'package:zure_palace/screens/clientScreen.dart';
import 'package:zure_palace/screens/ordersScreen.dart';
import 'package:zure_palace/screens/roomsScreen.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azure Palace',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/rooms': (_) => const RoomsScreen(),
        '/clients': (_) => const ClientsScreen(),
        '/orders': (_) => const OrdersScreen(),
      },
    );
  }
}
