import 'package:flutter/material.dart';

class ReceberNotificacao extends StatefulWidget {
  const ReceberNotificacao({super.key});

  @override
  State<ReceberNotificacao> createState() => _ReceberNotificacaoState();
}

class _ReceberNotificacaoState extends State<ReceberNotificacao> {
  bool _notificacaoAtiva = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔔 Receber Notificações"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchListTile(
              title: const Text("Ativar notificações"),
              subtitle: const Text("Receber alertas importantes"),
              value: _notificacaoAtiva,
              onChanged: (bool valor) {
                setState(() {
                  _notificacaoAtiva = valor;
                });
              },
              activeColor: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Salvar Preferência"),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _notificacaoAtiva
                          ? "Você receberá notificações!"
                          : "Notificações desativadas.",
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