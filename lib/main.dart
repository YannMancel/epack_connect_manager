import 'package:epack_connect_manager/bluetooth/_bluetooth.dart';
import 'package:flutter/material.dart';

const kAppName = 'Epack Connect Manager';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: kAppName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BluetoothDiscoveryPage(title: kAppName),
    );
  }
}
