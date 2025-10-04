import 'dart:io';

void main() async {
  final server = await ServerSocket.bind('127.0.0.1', 4000);
  print('Servidor ativo em ${server.address.address}:${server.port}');

  final contas = <String, double>{};

  await for (final socket in server) {
    socket.listen((data) {
      final mensagem = String.fromCharCodes(data).trim();
      final partes = mensagem.split(' ');
      final comando = partes[0].toUpperCase();

      String resposta = '[ERRO] Comando inválido.';

      switch (comando) {
        case 'CRIAR':
          if (partes.length == 2) {
            final id = partes[1];
            if (contas.containsKey(id)) {
              resposta = '[FALHA] Conta já existe.';
            } else {
              contas[id] = 0.0;
              resposta = '[SUCESSO] Conta $id criada.';
            }
          }
          break;

        case 'DEPOSITAR':
          if (partes.length == 3) {
            final id = partes[1];
            final valor = double.tryParse(partes[2]) ?? 0;
            if (contas.containsKey(id)) {
              contas[id] = contas[id]! + valor;
              resposta = '[SUCESSO] Depósito de $valor realizado.';
            } else {
              resposta = '[FALHA] Conta inexistente.';
            }
          }
          break;

        case 'SACAR':
          if (partes.length == 3) {
            final id = partes[1];
            final valor = double.tryParse(partes[2]) ?? 0;
            if (contas.containsKey(id)) {
              if (contas[id]! >= valor) {
                contas[id] = contas[id]! - valor;
                resposta = '[SUCESSO] Saque de $valor realizado.';
              } else {
                resposta = '[FALHA] Saldo insuficiente.';
              }
            } else {
              resposta = '[FALHA] Conta inexistente.';
            }
          }
          break;

        case 'SALDO':
          if (partes.length == 2) {
            final id = partes[1];
            if (contas.containsKey(id)) {
              resposta = '[SUCESSO] Saldo atual: ${contas[id]}';
            } else {
              resposta = '[FALHA] Conta inexistente.';
            }
          }
          break;

        case 'SAIR':
          socket.write('[INFO] Conexão encerrada.\n');
          socket.close();
          return;
      }

      socket.write('$resposta\n');
    });
  }
}
