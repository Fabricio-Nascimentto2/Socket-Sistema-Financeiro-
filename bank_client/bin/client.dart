import 'dart:io';

void main() async {
  final socket = await Socket.connect('127.0.0.1', 4000);
  print('Conectado ao servidor do banco.');

  socket.listen((data) {
    print(String.fromCharCodes(data));
  });

  while (true) {
    stdout.write('> ');
    final input = stdin.readLineSync();
    if (input == null || input.toUpperCase() == 'SAIR') {
      socket.write('SAIR\n');
      await socket.close();
      print('Desconectado.');
      break;
    }
    socket.write('$input\n');
  }
}

