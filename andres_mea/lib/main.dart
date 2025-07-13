import 'package:flutter/material.dart';
import 'Home.dart';
import 'TelaCliente.dart';
import 'TelaContato.dart';
import 'TelaEmpresa.dart';
import 'TelaServico.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "André's M&A",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/empresa': (context) => const TelaEmpresa(),
        '/servico': (context) => const TelaServico(),
        '/cliente': (context) => const TelaCliente(),
        '/contato': (context) => const TelaContato(),
      },
    );
  }
}