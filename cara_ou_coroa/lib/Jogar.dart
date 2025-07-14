import 'dart:math';
import 'package:flutter/material.dart';

class Jogar extends StatefulWidget {
  const Jogar({super.key});

  @override
  State<Jogar> createState() => _JogarState();
}

class _JogarState extends State<Jogar> {
  String _imagem = "logo.png";
  int _caras = 0;
  int _coroas = 0;

  void _sortear() {
    List<String> opcoes = ["moeda_cara.png", "moeda_coroa.png"];
    int resultado = Random().nextInt(2);

    setState(() {
      _imagem = opcoes[resultado];
      if (_imagem == "moeda_cara.png") {
        _caras++;
      } else {
        _coroas++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade700,
      appBar: AppBar(
        title: const Text("Cara ou Coroa"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            child: Image.asset(
              "images/$_imagem",
              key: ValueKey<String>(_imagem),
              height: 200,
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _sortear,
            child: Image.asset("images/botao_jogar.png", height: 80),
          ),
          const SizedBox(height: 30),
          Text(
            "Caras: $_caras  |  Coroas: $_coroas",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}