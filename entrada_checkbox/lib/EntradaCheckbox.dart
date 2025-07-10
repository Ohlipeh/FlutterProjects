import 'package:flutter/material.dart';

class EntradaCheckbox extends StatefulWidget {
  const EntradaCheckbox({super.key});

  @override
  State<EntradaCheckbox> createState() => _EntradaCheckboxState();
}

class _EntradaCheckboxState extends State<EntradaCheckbox> {

  bool _comidaBrasileira = false;
  bool _comidaMexicana = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entrada de dados"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            CheckboxListTile(
              title: Text("Comida Brasileira",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
                subtitle: Text("A melhor do mundo!!"),
                activeColor: Colors.green,
                secondary: Icon(Icons.add_business),
                value: _comidaBrasileira,
                onChanged: (valor){
                  setState(() {
                    _comidaBrasileira = valor!;
                   });
                 }
                ),

            CheckboxListTile(
                title: Text("Comida Mexicana",
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                subtitle: Text("A melhor do mundo!!"),
                activeColor: Colors.green,
                secondary: Icon(Icons.add_business),
                value: _comidaMexicana,
                onChanged: (valor){
                  setState(() {
                    _comidaMexicana = valor!;
                  });
                }
            ),
            ElevatedButton(
                onPressed: () {
                  print(
                      "Comida Brasileira: " + _comidaBrasileira.toString() +
                      "Comida Mexicana " + _comidaMexicana.toString()
                  );
                },
                child: Text(
                  "Salvar",
                  style: TextStyle(
                    fontSize: 20
                  ),
                )
            )

            /*
            Text("Comida Brasileira"),
            Checkbox(
              value: _estaSelecionado,
              onChanged: (valor){
                setState(() {
                  _estaSelecionado = valor!;
                });
                print("Checkbox:$valor");
              },
            )
             */
          ],
        ),
      ),
    );
  }
}