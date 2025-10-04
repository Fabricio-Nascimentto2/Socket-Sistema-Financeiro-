import 'dart:io';

void main() async {
  final socket = await Socket.connect('127.0.0.1', 4000);
  print('Conectado ao servidor.');

  stdin.listen((data) {
    final input = String.fromCharCodes(data).trim();
    socket.write('$input\n');
  });

  socket.listen((data) {
    print(String.fromCharCodes(data));
  });
}
