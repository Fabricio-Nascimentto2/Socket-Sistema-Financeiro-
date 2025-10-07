import 'dart:io';
import 'dart:convert';

void main() async {
  final socket = await Socket.connect('127.0.0.1', 4000);
  print('Bem-vindo ao banco distribuído!\n');
  print('Conectado ao servidor do banco.\n');

  // Escuta as respostas do servidor continuamente
  utf8.decoder.bind(socket).listen((resposta) {
    print('→ Resposta do servidor: $resposta');
    print('');
    mostrarMenu(socket);
  });

  // Mostra o primeiro menu
  mostrarMenu(socket);
}

void mostrarMenu(Socket socket) async {
  print('==============================');
  print('       MENU DO CLIENTE        ');
  print('==============================');
  print('1. Criar conta');
  print('2. Depositar');
  print('3. Sacar');
  print('4. Consultar saldo');
  print('5. Sair');
  stdout.write('Escolha uma opção: ');

  final opcao = stdin.readLineSync();

  switch (opcao) {
    case '1':
      stdout.write('Informe o ID da conta: ');
      final id = stdin.readLineSync();
      socket.writeln('CRIAR $id');
      break;

    case '2':
      stdout.write('Informe o ID da conta: ');
      final id = stdin.readLineSync();
      stdout.write('Informe o valor a depositar: ');
      final valor = stdin.readLineSync();
      socket.writeln('DEPOSITAR $id $valor');
      break;

    case '3':
      stdout.write('Informe o ID da conta: ');
      final id = stdin.readLineSync();
      stdout.write('Informe o valor a sacar: ');
      final valor = stdin.readLineSync();
      socket.writeln('SACAR $id $valor');
      break;

    case '4':
      stdout.write('Informe o ID da conta: ');
      final id = stdin.readLineSync();
      socket.writeln('SALDO $id');
      break;

    case '5':
      socket.writeln('SAIR');
      await socket.close();
      print('Desconectado.');
      exit(0);

    default:
      print('Opção inválida!');
      mostrarMenu(socket);
  }
}

