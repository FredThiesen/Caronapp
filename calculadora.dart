import 'dart:io';

void main() {
  List<String> historico = [];
  bool continuar = true;

  print('=== CALCULADORA BÁSICA ===');

  while (continuar) {
    try {
      stdout.write('\nDigite o primeiro número: ');
      double num1 = double.parse(stdin.readLineSync()!);

      stdout.write('Digite o segundo número: ');
      double num2 = double.parse(stdin.readLineSync()!);

      print('\nEscolha a operação:');
      print('1 - Soma (+)');
      print('2 - Subtração (-)');
      print('3 - Multiplicação (*)');
      print('4 - Divisão (/)');
      stdout.write('Opção: ');
      int opcao = int.parse(stdin.readLineSync()!);

      double resultado;

      switch (opcao) {
        case 1:
          resultado = num1 + num2;
          print('Resultado: $resultado');
          historico.add('$num1 + $num2 = $resultado');
          break;
        case 2:
          resultado = num1 - num2;
          print('Resultado: $resultado');
          historico.add('$num1 - $num2 = $resultado');
          break;
        case 3:
          resultado = num1 * num2;
          print('Resultado: $resultado');
          historico.add('$num1 * $num2 = $resultado');
          break;
        case 4:
          if (num2 == 0) {
            throw Exception('Erro: Divisão por zero não é permitida!');
          }
          resultado = num1 / num2;
          print('Resultado: $resultado');
          historico.add('$num1 / $num2 = $resultado');
          break;
        default:
          print('Opção inválida.');
      }
    } on FormatException {
      print('Erro: valor digitado não é um número válido.');
    } catch (e) {
      print(e);
    }

    stdout.write('\nDeseja fazer outra operação? (s/n): ');
    String? resposta = stdin.readLineSync();
    if (resposta == null || resposta.toLowerCase() != 's') {
      continuar = false;
    }
  }

  print('\n=== HISTÓRICO DE OPERAÇÕES ===');
  if (historico.isEmpty) {
    print('Nenhuma operação realizada.');
  } else {
    for (var operacao in historico) {
      print(operacao);
    }
  }

  print('\nObrigado por usar a calculadora!');
}