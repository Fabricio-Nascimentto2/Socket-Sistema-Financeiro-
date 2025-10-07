import 'conta_model.dart';

class BancoService {
  final Map<String, Conta> _contas = {};

  String criarConta(String id) {
    if (_contas.containsKey(id)) {
      return '[FALHA] Conta já existe.';
    }
    _contas[id] = Conta(id);
    return '[SUCESSO] Conta $id criada com saldo 0.';
  }

  String depositar(String id, double valor) {
    final conta = _contas[id];
    if (conta == null) return '[FALHA] Conta não encontrada.';
    conta.saldo += valor;
    return '[SUCESSO] Depósito de $valor realizado na conta $id.';
  }

  String sacar(String id, double valor) {
    final conta = _contas[id];
    if (conta == null) return '[FALHA] Conta não encontrada.';
    if (conta.saldo < valor) return '[FALHA] Saldo insuficiente.';
    conta.saldo -= valor;
    return '[SUCESSO] Saque de $valor realizado na conta $id.';
  }

  String saldo(String id) {
    final conta = _contas[id];
    if (conta == null) return '[FALHA] Conta não encontrada.';
    return 'Saldo da conta $id: ${conta.saldo}';
  }
}
