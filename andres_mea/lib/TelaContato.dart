import 'package:flutter/material.dart';

class TelaContato extends StatefulWidget {
  const TelaContato({super.key});

  @override
  State<TelaContato> createState() => _TelaContatoState();
}

class _TelaContatoState extends State<TelaContato> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contato',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            ContatoCard(
              icon: Icons.phone,
              titulo: 'Telefone',
              descricao: '(47) 99177-7385',
            ),
            SizedBox(height: 12),
            ContatoCard(
              icon: Icons.email,
              titulo: 'E-mail',
              descricao: 'felipe_santofortee@hotmail.com',
            ),
            SizedBox(height: 12),
            ContatoCard(
              icon: Icons.location_on,
              titulo: 'Endereço',
              descricao: 'Rua João Sabino de Souza, 177 - Blumenau, SC',
            ),
            SizedBox(height: 12),
            ContatoCard(
              icon: Icons.access_time,
              titulo: 'Horário de atendimento',
              descricao: 'Seg a Sex - 08h às 18h',
            ),
          ],
        ),
      ),
    );
  }
}

class ContatoCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descricao;

  const ContatoCard({
    super.key,
    required this.icon,
    required this.titulo,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Color(0xFF00B8D4)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    descricao,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
