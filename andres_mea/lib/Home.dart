import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Navegações separadas
  void _abrirEmpresa() {
    Navigator.pushNamed(context, '/empresa');
  }

  void _abrirServico() {
    Navigator.pushNamed(context, '/servico');
  }

  void _abrirCliente() {
    Navigator.pushNamed(context, '/cliente');
  }

  void _abrirContato() {
    Navigator.pushNamed(context, '/contato');
  }

  // Widget reutilizável
  Widget _criarBotaoMenu(String caminhoImagem, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        caminhoImagem,
        width: 100,
        height: 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
            "André's M&A",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.yellow,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset("images/logo.png", width: 160),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _criarBotaoMenu("images/menu_empresa.png", _abrirEmpresa),
                _criarBotaoMenu("images/menu_servico.png", _abrirServico),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _criarBotaoMenu("images/menu_cliente.png", _abrirCliente),
                _criarBotaoMenu("images/menu_contato.png", _abrirContato),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
