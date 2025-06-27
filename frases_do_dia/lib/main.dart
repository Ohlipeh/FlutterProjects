// Importa o pacote principal do Flutter (interface visual)
import 'package:flutter/material.dart';

// Importa o pacote de matemática, usado para gerar números aleatórios
import 'dart:math';

void main() {
  // Função principal que executa o app Flutter
  runApp(MaterialApp(
    home: Home(), // Define o widget inicial (tela Home)
    debugShowCheckedModeBanner: false, // Remove a faixa "DEBUG"
  ));
}

// Declaração de um widget com estado (pode mudar dinamicamente)
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState(); // Cria o estado interno
}

// Classe que armazena o estado da tela (dados e interface)
class _HomeState extends State<Home> {
  // Lista de frases que serão sorteadas
  var _frases = [
    "Não se esqueça: você é a razão do sorriso de muitas pessoas 😊✨",
    "Descubra-se. Há tantas coisas que não sabe sobre você.",
    "Seja gentil com a sua mente e o seu coração ❤️",
    "Valorize as coisas simples que estão perto de você.",
    "Sorria. Com os dentes. Com os lábios. Com a alma.",
    "A felicidade é algo que começa lá dentro da alma.",
    "As plantas também precisam de chuva para crescer🌱",
    "Depois de um temporal, sempre aparece um arco-íris🌈",
    "Escolha algo que te faz feliz para fazer hoje.",
    "Valorize-se sempre.",
    "Há tanta gente querendo te ver bem.",
    "Cada desafio leva a uma nova aprendizagem.",
    "Não tenha medo de ser feliz.",
  ];

  // Frase exibida na tela (valor inicial)
  var _fraseGerada = "Clique abaixo para gerar uma frase!";

  // Função que gera uma nova frase aleatória
  void _gerarFrase() {
    // Sorteia um número de 0 até o tamanho da lista de frases
    var numeroSorteado = Random().nextInt(_frases.length);

    // Atualiza o estado da tela com a nova frase
    setState(() {
      _fraseGerada = _frases[numeroSorteado];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Método que constrói a interface visual da tela
    return Scaffold(
      appBar: AppBar(
        title: Text("Frases do dia",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ), // Título na barra superior
        backgroundColor: Colors.green, // Cor da barra
      ),
      body: Container(
        padding: EdgeInsets.all(16), // Margem interna de todos os lados
        width: double.infinity, // Ocupa toda a largura possível
        decoration: BoxDecoration(
          border: Border.all(width: 3, color: Colors.amber), // Borda decorativa
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Espaço igual entre elementos
          crossAxisAlignment: CrossAxisAlignment.center, // Alinha ao centro horizontal
          children: <Widget>[
            // Exibe uma imagem local
            Image.asset("images/frase-dia.jpg"),

            // Exibe o texto da frase gerada
            Text(
              _fraseGerada,
              textAlign: TextAlign.justify, // Alinha o texto nas bordas
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold, // Texto em negrito
                fontStyle: FontStyle.italic, // Texto em itálico
                color: Colors.black,
              ),
            ),

            // Botão que chama a função _gerarFrase
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: _gerarFrase, // <-- Aqui está a correção!
              child: Text(
                "Nova Frase",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

