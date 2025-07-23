import 'dart:io';

void main() {
  // ignore: unused_local_variable
  int? idade;

  // Loop até o usuário fornecer uma idade válida
  while (true) {
    stdout.write("Digite sua idade: ");
    String? entrada = stdin.readLineSync();

    // Tenta converter para inteiro
    idade = int.tryParse(entrada!);

    // Verifica se a idade é válida (não nula e positiva)
    if (idade != null && idade > 0 && idade <= 100) {
      break; // Sai do loop se a idade for válida
    } else {
      print("Por favor, digite uma idade válida (Entre 1 e 100).");
    }
  }

  // Verifica se o acesso é permitido ou negado
  if (idade < 18) {
    print("Acesso negado");
  } else {
    print("Acesso permitido");
  }
}
