import 'package:flutter/material.dart';

class Entradaslider extends StatefulWidget {
  const Entradaslider({super.key});

  @override
  State<Entradaslider> createState() => _EntradasliderState();
}

class _EntradasliderState extends State<Entradaslider> {

  double valor = 0;
  String label = "0";
  bool _salvouNota = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎚 Dê sua nota"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                "Nota: ${valor.round()}",
              style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20),
            Slider(
                value: valor,
                min: 0,
                max: 10,
                divisions: 10,
                label: label,
                activeColor: Colors.blue,
                inactiveColor: Colors.black26,
                onChanged: ( novoValor) {
                  setState(() {
                    valor = novoValor;
                    label = novoValor.toString();
                  });
                },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Salvar Nota"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                setState(() {
                  _salvouNota = true;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _salvouNota
                          ? "Sua nota foi salva com sucesso!"
                          : "Erro ao salvar a nota.",
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
