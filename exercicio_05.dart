import 'dart:io';

void main() {
  stdout.write("Digite uma frase: ");
  String? frase = stdin.readLineSync();

  if (frase == null || frase.isEmpty) {
    print("nenhuma frase foi digitada");
    return;
  }

  // Converter para minúsculas para facilitar a comparação
  String texto = frase.toLowerCase();

  // Definir vogais para comparação
  Set<String> vogais = {"a", "e", "i", "o", "u"};

  int contadorVogais = 0;
  int contadorConsoantes = 0;

  for (int i = 0; i < texto.length; i++) {
    String char = texto[i];

    // Ignorar caracteres não alfabéticos
    if (char.contains(RegExp(r"[a-z]"))) {
      if (vogais.contains(char)) {
        contadorVogais++;
      } else {
        contadorConsoantes++;
      }
    }
  }
  print("Número de vogais: $contadorVogais");
  print("Número de consoantes: $contadorConsoantes");
}
