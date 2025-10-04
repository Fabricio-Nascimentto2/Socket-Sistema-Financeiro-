import 'dart:io';

final contas = <String, double>{};

void main() async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 4000);
  print('Servidor ativo em ${server.address.address}:${server.port}');

  await for (final socket in server) {
    handleClient(socket);
  }
}

void handleClient(Socket client) {
  print('Cliente conectado: ${client.remoteAddress.address}');
  client.write('Bem-vindo ao banco distribuído!\n');

  client.listen((data) {
    final mensagem = String.fromCharCodes(data).trim();
    final partes = mensagem.split(' ');
    final comando = partes.first.toUpperCase();

    switch (comando) {
      case 'CRIAR':
        if (partes.length < 2) {
          client.write('Uso: CRIAR <id>\n');
        } else {
          final id = partes[1];
          if (contas.containsKey(id)) {
            client.write('Conta $id já existe.\n');
          } else {
            contas[id] = 0;
            client.write('Conta $id criada com saldo 0.\n');
          }
        }
        break;

      case 'DEPOSITAR':
        if (partes.length < 3) {
          client.write('Uso: DEPOSITAR <id> <valor>\n');
        } else {
          final id = partes[1];
          final valor = double.tryParse(partes[2]) ?? 0;
          if (contas.containsKey(id)) {
            contas[id] = contas[id]! + valor;
            client.write('Depósito de $valor realizado na conta $id.\n');
          } else {
            client.write('Conta $id não encontrada.\n');
          }
        }
        break;

      case 'SACAR':
        if (partes.length < 3) {
          client.write('Uso: SACAR <id> <valor>\n');
        } else {
          final id = partes[1];
          final valor = double.tryParse(partes[2]) ?? 0;
          if (contas.containsKey(id) && contas[id]! >= valor) {
            contas[id] = contas[id]! - valor;
            client.write('Saque de $valor realizado na conta $id.\n');
          } else {
            client.write('Saldo insuficiente ou conta inexistente.\n');
          }
        }
        break;

      case 'SALDO':
        if (partes.length < 2) {
          client.write('Uso: SALDO <id>\n');
        } else {
          final id = partes[1];
          if (contas.containsKey(id)) {
            client.write('Saldo da conta $id: ${contas[id]}\n');
          } else {
            client.write('Conta $id não encontrada.\n');
          }
        }
        break;

      case 'SAIR':
        client.write('Conexão encerrada.\n');
        client.close();
        break;

      default:
        client.write('Comando inválido.\n');
    }
  });
}
