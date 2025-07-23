import 'dart:io';

void main() {
  // Solicita o primeiro número
  stdout.write("Digite o primeiro número inteiro: ");
  int? num1 = int.tryParse(stdin.readLineSync()!);

  // Solicita o segundo número
  stdout.write("Digite o segundo número inteiro: ");
  int? num2 = int.tryParse(stdin.readLineSync()!);

  // Solicita a operação
  stdout.write("Digite a operação desejada (+, -, *, /):");
  String? operacao = stdin.readLineSync();

  // Verifica se os numeros são válidos
  if (num1 == null || num2 == null) {
    print("Erro: Você deve digitar números inteiros válidos.");
    return;
  }

  // Executa a operação com validações
  switch (operacao) {
    case "+":
      print("Resultado: ${num1 + num2}");
      break;

    case "-":
      print("Resultado: ${num1 - num2}");
      break;

    case "*":
      print("Resultado: ${num1 * num2}");
      break;

    case "/":
      if (num2 == 0) {
        print("A divisão por zero não é permitida");
      } else {
        print("Resultado: ${num1 / num2}");
      }
      break;
    default:
      print("Erro: Operação inválida. Use apenas +, -, *, ou /.");
  }
}
