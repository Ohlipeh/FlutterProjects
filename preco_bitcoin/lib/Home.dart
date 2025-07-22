import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _preco = "0,00";
  bool _carregando = false;
  double? _precoAnterior;
  String _tendencia = "";

  Future<void> _recuperarPreco() async {
    setState(() {
      _carregando = true;
    });

    Uri url = Uri.parse("https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=brl");

    try {
      http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        double precoDouble = (data["bitcoin"]["brl"] as num).toDouble();

        final formatador = NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

        setState(() {
          _preco = formatador.format(precoDouble);
          _tendencia = _calcularTendencia(precoDouble);
          _precoAnterior = precoDouble;
          _carregando = false;
        });
      } else {
        throw Exception("Erro ao carregar dados");
      }
    } catch (e) {
      setState(() {
        _preco = "Erro!";
        _tendencia = "Falha na conexão.";
        _carregando = false;
      });
      print("Erro capturado: $e");
    }
  }

  String _calcularTendencia(double novoPreco) {
    if (_precoAnterior == null) return "";
    if (novoPreco > _precoAnterior!) return "↑ Subiu";
    if (novoPreco < _precoAnterior!) return "↓ Caiu";
    return "→ Estável";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/bitcoin.png", height: 100),
              const SizedBox(height: 30),
              Text(
                _preco,
                style: const TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _tendencia,
                style: TextStyle(
                  fontSize: 18,
                  color: _tendencia.contains("↑")
                      ? Colors.green
                      : _tendencia.contains("↓")
                      ? Colors.red
                      : Colors.orange,
                ),
              ),
              const SizedBox(height: 30),
              _carregando
                  ? const CircularProgressIndicator(color: Colors.orange)
                  : ElevatedButton(
                onPressed: _recuperarPreco,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Atualizar",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
