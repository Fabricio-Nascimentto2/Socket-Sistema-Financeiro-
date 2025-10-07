import 'dart:io';
import 'dart:convert';

final Map<String, double> contas = {};
final File bancoFile = File('banco.json');
final File logFile = File('log.txt');

Future<void> main() async {
  // Carrega dados existentes, se houver
  await carregarBanco();
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 4000);
  print('Servidor ativo em ${server.address.address}:${server.port}');

  await for (final socket in server) {
    handleClient(socket);
  }
}

void handleClient(Socket socket) {
  print('Cliente conectado: ${socket.remoteAddress.address}');
  socket.writeln('Bem-vindo ao banco distribuído!');

  socket.listen((data) async {
    final comando = utf8.decode(data).trim();
    final resposta = await processarComando(comando);
    socket.writeln(resposta);
    await registrarLog('Cliente ${socket.remoteAddress.address} → $comando → $resposta');

    if (comando.toUpperCase() == 'SAIR') {
      socket.writeln('Conexão encerrada.');
      await socket.close();
    }
  });
}

Future<String> processarComando(String comando) async {
  final partes = comando.split(' ');
  if (partes.isEmpty) return 'Comando inválido.';

  final acao = partes[0].toUpperCase();

  switch (acao) {
    case 'CRIAR':
      if (partes.length < 2) return 'Uso: CRIAR <id>';
      final id = partes[1];
      if (contas.containsKey(id)) return 'Conta $id já existe.';
      contas[id] = 0.0;
      await salvarBanco();
      return 'Conta $id criada com saldo 0.';

    case 'DEPOSITAR':
      if (partes.length < 3) return 'Uso: DEPOSITAR <id> <valor>';
      final id = partes[1];
      final valor = double.tryParse(partes[2]) ?? 0.0;
      if (!contas.containsKey(id)) return 'Conta $id não encontrada.';
      contas[id] = contas[id]! + valor;
      await salvarBanco();
      return 'Depósito de $valor realizado na conta $id.';

    case 'SACAR':
      if (partes.length < 3) return 'Uso: SACAR <id> <valor>';
      final id = partes[1];
      final valor = double.tryParse(partes[2]) ?? 0.0;
      if (!contas.containsKey(id)) return 'Conta $id não encontrada.';
      if (contas[id]! < valor) return 'Saldo insuficiente.';
      contas[id] = contas[id]! - valor;
      await salvarBanco();
      return 'Saque de $valor realizado na conta $id.';

    case 'SALDO':
      if (partes.length < 2) return 'Uso: SALDO <id>';
      final id = partes[1];
      if (!contas.containsKey(id)) return 'Conta $id não encontrada.';
      return 'Saldo da conta $id: ${contas[id]}';

    case 'SAIR':
      return 'Saindo...';

    default:
      return 'Comando desconhecido: $acao';
  }
}

Future<void> carregarBanco() async {
  if (await bancoFile.exists()) {
    final conteudo = await bancoFile.readAsString();
    final dados = jsonDecode(conteudo);
    contas.clear();
    dados.forEach((k, v) => contas[k] = (v as num).toDouble());
    print('Banco de dados carregado: ${contas.length} contas.');
  } else {
    await bancoFile.writeAsString(jsonEncode(contas));
    print('Novo arquivo de banco criado.');
  }
}

Future<void> salvarBanco() async {
  final dados = jsonEncode(contas);
  await bancoFile.writeAsString(dados);
}

Future<void> registrarLog(String mensagem) async {
  final data = DateTime.now().toIso8601String();
  await logFile.writeAsString('[$data] $mensagem\n', mode: FileMode.append);
}

