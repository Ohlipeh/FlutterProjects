class ShoppingList {
  final int id;
  final String name;
  final DateTime createdAt;
  final String status;

  ShoppingList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.status,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id_lista'],
      name: json['nome_lista'],
      createdAt: DateTime.parse(json['data_criacao']),
      status: json['status'],
    );
  }
}