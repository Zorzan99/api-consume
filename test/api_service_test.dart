// Importa as bibliotecas necessárias
import 'dart:async';
import 'package:test/test.dart';
import 'package:uno/uno.dart'; // Importa a classe Uno do pacote uno
import 'package:api_consume/api_service.dart'; // Importa a classe ApiService
import 'package:api_consume/product.dart'; // Importa a classe Product

// Classe UnoMock que implementa a interface Uno
class UnoMock implements Uno {
  final bool withError; // Flag para indicar se deve simular um erro
  UnoMock([this.withError = false]);

  // Implementação do método get da interface Uno
  @override
  Future<Response> get(String url,
      {Duration? timeout,
      Map<String, String> params = const {},
      Map<String, String> headers = const {},
      ResponseType responseType = ResponseType.json,
      DownloadCallback? onDownloadProgress,
      ValidateCallback? validateStatus}) async {
    // Simula um erro se withError for true
    if (withError) {
      throw UnoError("error");
    }

    // Retorna uma resposta simulada bem-sucedida
    return Response(
      headers: headers,
      request: Request(
        uri: Uri.base,
        method: '',
        headers: {},
        timeout: Duration.zero,
      ),
      status: 200,
      data: productListJson, // Simula dados de uma lista de produtos
    );
  }

  // Implementação do método noSuchMethod para evitar erros em testes
  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

// Função principal de testes
void main() {
  // Teste: Deve retornar uma lista de produtos
  test('Deve retornar uma lista de product', () {
    final uno = UnoMock(); // Cria uma instância de UnoMock
    final service =
        ApiService(uno); // Cria uma instância de ApiService com UnoMock

    // Verifica se a chamada de getProducts retorna a lista esperada de produtos
    expect(
      service.getProducts(),
      completion(
        [
          Product(id: 1, title: 'title', price: 12.0),
          Product(id: 2, title: 'title2', price: 13.0),
        ],
      ),
    );
  });

  // Teste: Deve retornar uma lista vazia em caso de erro
  test(
      "Deve retornar uma lista de Product "
      'vazia quando houver uma falha', () {
    final uno = UnoMock(true); // Cria uma instância de UnoMock com erro
    final service = ApiService(
        uno); // Cria uma instância de ApiService com UnoMock com erro

    // Verifica se a chamada de getProducts retorna uma lista vazia em caso de erro
    expect(
      service.getProducts(),
      completion([]),
    );
  });
}

// Lista simulada de produtos em formato JSON
final productListJson = [
  {
    'id': 1,
    'title': 'title',
    'price': 12.0,
  },
  {
    'id': 2,
    'title': 'title2',
    'price': 13.0,
  },
];
