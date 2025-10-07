import 'dart:io';
import 'dart:convert';
import 'banco_service.dart';

void main() async {
  final banco = BancoService();
  final server = await ServerSocket.bind('127.0.0.1', 4000);
  print('Servidor ativo em ${server.address.address}:${server.port}');

  await for (final socket in server) {
    print('Cliente conectado: ${socket.remoteAddress.address}');
    socket.writeln('Bem-vindo ao banco distribuído!');
    utf8.decoder.bind(socket).listen((data) {
      final comando = data.trim().split(' ');
      final acao = comando[0].toUpperCase();

      String resposta;
      switch (acao) {
        case 'CRIAR':
          resposta = banco.criarConta(comando[1]);
          break;
        case 'DEPOSITAR':
          resposta = banco.depositar(comando[1], double.parse(comando[2]));
          break;
        case 'SACAR':
          resposta = banco.sacar(comando[1], double.parse(comando[2]));
          break;
        case 'SALDO':
          resposta = banco.saldo(comando[1]);
          break;
        case 'SAIR':
          resposta = 'Conexão encerrada.';
          socket.writeln(resposta);
          socket.destroy();
          return;
        default:
          resposta = 'Comando inválido.';
      }
      socket.writeln(resposta);
    });
  }
}

