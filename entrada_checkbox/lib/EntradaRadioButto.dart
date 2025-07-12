import 'package:flutter/material.dart';

class EntradaRadioButto extends StatefulWidget {
  const EntradaRadioButto({super.key});

  @override
  State<EntradaRadioButto> createState() => _EntradaRadioButtoState();
}

class _EntradaRadioButtoState extends State<EntradaRadioButto> {
  String? _escolhaUsuario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🙋 Sexo do Usuário"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RadioListTile(
              title: const Text("Masculino"),
              value: "Masculino",
              groupValue: _escolhaUsuario,
              onChanged: (valor) {
                setState(() {
                  _escolhaUsuario = valor!;
                });
              },
            ),
            RadioListTile(
              title: const Text("Feminino"),
              value: "Feminino",
              groupValue: _escolhaUsuario,
              onChanged: (valor) {
                setState(() {
                  _escolhaUsuario = valor!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final msg = _escolhaUsuario != null
                    ? "Você escolheu: $_escolhaUsuario"
                    : "Nenhuma opção selecionada!";
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text("Confirmar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}