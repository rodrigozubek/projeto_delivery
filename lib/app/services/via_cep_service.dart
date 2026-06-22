import 'dart:convert';
import 'dart:io';

class EnderecoViaCep {
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;

  EnderecoViaCep({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
  });

  factory EnderecoViaCep.fromJson(Map<String, Object?> json) {
    return EnderecoViaCep(
      cep: json['cep'] as String? ?? '',
      logradouro: json['logradouro'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      localidade: json['localidade'] as String? ?? '',
      uf: json['uf'] as String? ?? '',
    );
  }
}

class ViaCepService {
  final HttpClient _client;

  ViaCepService({HttpClient? client}) : _client = client ?? HttpClient();

  Future<EnderecoViaCep> buscarEndereco(String cep) async {
    final normalizedCep = cep.replaceAll(RegExp(r'\D'), '');
    if (normalizedCep.length != 8) {
      throw Exception('CEP invalido.');
    }

    final uri = Uri.https('viacep.com.br', '/ws/$normalizedCep/json/');
    final request = await _client.getUrl(uri);
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Nao foi possivel consultar o CEP.');
    }

    final body = await response.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, Object?>;

    if (json['erro'] == true) {
      throw Exception('CEP nao encontrado.');
    }

    return EnderecoViaCep.fromJson(json);
  }
}
