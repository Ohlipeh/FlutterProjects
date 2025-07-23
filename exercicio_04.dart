import 'dart:io';

void main() {
  List<double> notas = [];

  // Loop para ler as 3 notas
  for (int i = 1; i <= 3; i++) {
    double? nota;
    bool notaValida = false;

    // Loop para validar a nota
    while (!notaValida) {
      stdout.write("Digite a nota da disciplina $i (0 a 10): ");
      String? input = stdin.readLineSync();

      if (input != null) {
        nota = double.tryParse(input);

        if (nota != null && nota >= 0 && nota <= 10) {
          notas.add(nota);
          notaValida = true;
        } else {
          print("Entrada vazia. Tente novamente");
        }
      }
    }

    // Cálculo da média
    double media = notas.reduce((a, b) => a + b) / notas.length;
    print("\nMédia final: ${media.toStringAsFixed(1)}");

    // Verificação da situação do aluno
    if (media >= 7.0) {
      print("Situação: Aprovado ✅");
    } else if (media >= 5.0) {
      print("Situação: Recuperação ⚠️");
    } else {
      print('Situação: Reprovado ❌');
    }
  }
}
