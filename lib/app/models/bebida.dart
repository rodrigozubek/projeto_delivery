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
}