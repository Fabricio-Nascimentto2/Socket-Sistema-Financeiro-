class Conta {
  final String id;
  double saldo;

  Conta(this.id, {this.saldo = 0.0});

  @override
  String toString() => 'Conta(id: $id, saldo: $saldo)';
}
