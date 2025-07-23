import 'dart:io';
import 'dart:async';

void main() async {
  stdout.write("Digite um número inteiro: ");
  String? input = stdin.readLineSync();

  if (input != null) {
    int? numero = int.tryParse(input);

    if (numero == null) {
      print("Entrada inválida. Por favor, insira um número inteiro.");
    } else if (numero <= 0) {
      print("Número inválido. O programa será encerrado.");
    } else {
      print("Let's go! 🚀");
      for (int i = numero; i > 0; i--) {
        print("Faltam $i segundos");
        await Future.delayed((Duration(seconds: 1)));
      }
      print("Tempo esgotado! ⏰");
    }
  } else {
    print("Nenhuma entrada foi fornecida");
  }
}
