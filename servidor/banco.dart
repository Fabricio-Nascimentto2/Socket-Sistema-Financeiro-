import 'dart:io';
import 'dart:convert';

class Banco {
  final Map<String, double> _contas = {};
  final Directory _diretorioDados = Directory('dados');

  Banco() {
    if (!_diretorioDados.existsSync()) {
      _diretorioDados.createSync(recursive: true);
    }
    _carregarContas();
  }

  // Criar nova conta
  String criarConta(String id) {
    if (_contas.containsKey(id)) {
      return 'Conta $id já existe.';
    }
    _contas[id] = 0.0;
    _salvarConta(id);
    return 'Conta $id criada com saldo 0.';
  }

  // Depositar
  String depositar(String id, double valor) {
    if (!_contas.containsKey(id)) return 'Conta não encontrada.';
    _contas[id] = _contas[id]! + valor;
    _salvarConta(id);
    return 'Depósito de $valor realizado na conta $id.';
  }

  // Sacar
  String sacar(String id, double valor) {
    if (!_contas.containsKey(id)) return 'Conta não encontrada.';
    if (_contas[id]! < valor) return 'Saldo insuficiente.';
    _contas[id] = _contas[id]! - valor;
    _salvarConta(id);
    return 'Saque de $valor realizado na conta $id.';
  }

  // Consultar saldo
  String saldo(String id) {
    if (!_contas.containsKey(id)) return 'Conta não encontrada.';
    return 'Saldo da conta $id: ${_contas[id]}';
  }

  // ========================
  // 🔽 Persistência dos dados
  // ========================

  void _salvarConta(String id) {
    final arquivo = File('${_diretorioDados.path}/conta_$id.json');
    final dados = {'id': id, 'saldo': _contas[id]};
    arquivo.writeAsStringSync(jsonEncode(dados));
  }

  void _carregarContas() {
    for (var arquivo in _diretorioDados.listSync()) {
      if (arquivo is File && arquivo.path.endsWith('.json')) {
        final conteudo = arquivo.readAsStringSync();
        final dados = jsonDecode(conteudo);
        _contas[dados['id']] = (dados['saldo'] as num).toDouble();
      }
    }
  }
}
