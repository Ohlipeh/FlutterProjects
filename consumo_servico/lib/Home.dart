import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controllerCep = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _dadosCep;

  void _recuperarCep() async {
    final cepDigitado = _controllerCep.text.trim();

    if (cepDigitado.isEmpty || cepDigitado.length != 8) {
      _showDialog("CEP inválido", "Digite um CEP válido com 8 dígitos.");
      return;
    }

    setState(() {
      _loading = true;
      _dadosCep = null;
    });

    final url = Uri.parse("https://viacep.com.br/ws/$cepDigitado/json/");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final retorno = jsonDecode(response.body);
        if (retorno.containsKey("erro")) {
          _showDialog("CEP não encontrado", "Verifique o número e tente novamente.");
        } else {
          setState(() {
            _dadosCep = retorno;
          });
        }
      } else {
        _showDialog("Erro", "Falha ao consultar o CEP.");
      }
    } catch (e) {
      _showDialog("Erro", "Erro ao consultar o CEP: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showDialog(String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  Widget _buildResultado() {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_dadosCep == null) {
      return SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.only(top: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLinha(Icons.location_on, "Logradouro", _dadosCep!["logradouro"]),
            _buildLinha(Icons.apartment, "Bairro", _dadosCep!["bairro"]),
            _buildLinha(Icons.location_city, "Cidade", _dadosCep!["localidade"]),
            _buildLinha(Icons.map, "Estado", _dadosCep!["uf"]),
            _buildLinha(Icons.code, "IBGE", _dadosCep!["ibge"]),
            _buildLinha(Icons.phone_android, "DDD", _dadosCep!["ddd"]),
          ],
        ),
      ),
    );
  }

  Widget _buildLinha(IconData icone, String label, String? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icone, size: 20),
          SizedBox(width: 10),
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(valor ?? "-")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Consulta de CEP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controllerCep,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: InputDecoration(
                labelText: "Digite o CEP",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _recuperarCep,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text("Consultar CEP"),
            ),
            _buildResultado(),
          ],
        ),
      ),
    );
  }
}
