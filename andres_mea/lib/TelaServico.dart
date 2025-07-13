import 'package:flutter/material.dart';

class TelaServico extends StatefulWidget {
  const TelaServico({super.key});

  @override
  State<TelaServico> createState() => _TelaServicoState();
}

class _TelaServicoState extends State<TelaServico> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Serviços",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Image.asset("images/detalhe_servico.png"),
                  const SizedBox(width: 10),
                  const Text(
                    "Nossos serviços",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '''Oferecemos:
                • Criação de Móveis Sob Medida – Desenvolvemos soluções exclusivas para sua casa ou empresa, respeitando cada centímetro do seu espaço e o seu estilo de vida.

                • Montagem Profissional – Montamos com precisão qualquer tipo de móvel sob medida, garantindo segurança, estética e durabilidade.

                • Reformas e Restaurações – Damos nova vida a móveis antigos ou desgastados, preservando suas características ou modernizando conforme sua necessidade.

                • Acompanhamento Personalizado – Desde a ideia inicial até a finalização, nossa equipe cuida de cada detalhe para entregar resultados impecáveis.''',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
