class Bebida {
  final String id;
  final String nome;
  final String descricao;
  final double preco;
  final String imagemUrl;
  final bool isAlcoolica;

  Bebida({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.imagemUrl,
    this.isAlcoolica = false,
  });

  factory Bebida.fromMap(Map<String, Object?> map) {
    return Bebida(
      id: map['id'] as String,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String,
      preco: (map['preco'] as num).toDouble(),
      imagemUrl: map['imagem_url'] as String,
      isAlcoolica: (map['is_alcoolica'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'imagem_url': imagemUrl,
      'is_alcoolica': isAlcoolica ? 1 : 0,
    };
  }
}
