import 'dart:io';
import 'dart:math';

void main() {
  int numeroSecreto = Random().nextInt(100) + 1;
  int tentativas = 0;
  bool acertou = false;

  print('🎯 Jogo de Adivinhação');
  print('Tente adivinhar o número entre 1 e 100.\n');

  while (!acertou) {
    stdout.write('Digite seu palpite: ');
    String? input = stdin.readLineSync();

    if (input == null) {
      print('❗ Nenhuma entrada fornecida. Tente novamente.\n');
      continue;
    }

    int? palpite = int.tryParse(input);

    if (palpite == null || palpite < 1 || palpite > 100) {
      print('❗ Entrada inválida. Digite um número entre 1 e 100.\n');
      continue;
    }

    tentativas++;

    int diferenca = (palpite - numeroSecreto).abs();

    if (palpite < numeroSecreto) {
      print('🔽 Muito baixo!');
      if (diferenca <= 5) {
        print('💡 Você está perto!\n');
      } else {
        print('');
      }
    } else if (palpite > numeroSecreto) {
      print('🔼 Muito alto!');
      if (diferenca <= 5) {
        print('💡 Você está perto!\n');
      } else {
        print('');
      }
    } else {
      print('\n🎉 Parabéns! Você acertou o número $numeroSecreto.');
      print('📊 Número de tentativas: $tentativas');
      acertou = true;
    }
  }
}
