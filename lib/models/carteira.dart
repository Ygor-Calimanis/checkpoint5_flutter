class Carteira {
  int id;
  double saldo;
  String userId;

  Carteira({
    required this.id,
    required this.saldo,
    required this.userId,
  });

  factory Carteira.fromMap(Map<String, dynamic> map) {
    return Carteira(id: map['id'], userId: map['user_id'], saldo: map['saldo']);
  }
}
