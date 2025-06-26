import 'package:flutter/material.dart';

void main () => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Frases do dia",
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Frases do dia"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                  'assets/ChatGPT Image 25 de abr. de 2025, 13_35_52.png',
                fit: BoxFit.cover,),
            TextButton(
              onPressed: () {
                print("Botão pressionado");
            },
            child: const Text(
              "Clique aqui",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ),
              ]
        ),
      ),
      ),
    );
  }
}