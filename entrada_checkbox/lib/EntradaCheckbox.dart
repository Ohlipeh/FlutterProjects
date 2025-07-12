import 'package:flutter/material.dart';

class EntradaCheckbox extends StatefulWidget {
  const EntradaCheckbox({super.key});

  @override
  State<EntradaCheckbox> createState() => _EntradaCheckboxState();
}

class _EntradaCheckboxState extends State<EntradaCheckbox> {
  bool _comidaBrasileira = false;
  bool _comidaMexicana = false;
  bool _comidaAlema = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🍛 Preferências Culinárias"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CheckboxListTile(
              title: const Text(
                "Comida Brasileira",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Feijoada, churrasco, etc."),
              activeColor: Colors.green,
              secondary: const Icon(Icons.restaurant),
              value: _comidaBrasileira,
              onChanged: (valor) {
                setState(() {
                  _comidaBrasileira = valor!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text(
                "Comida Mexicana",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Tacos, burritos, etc."),
              activeColor: Colors.green,
              secondary: const Icon(Icons.local_dining),
              value: _comidaMexicana,
              onChanged: (valor) {
                setState(() {
                  _comidaMexicana = valor!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text(
                "Comida Alemã",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Chucruti, Linguiça, etc."),
              activeColor: Colors.green,
              secondary: const Icon(Icons.local_dining),
              value: _comidaAlema,
              onChanged: (valor) {
                setState(() {
                  _comidaAlema = valor!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final msg = "Brasileira: $_comidaBrasileira, "
                    "Mexicana: $_comidaMexicana, "
                    "Alema: $_comidaAlema";
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text("Salvar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}