# Projeto Mobile - Delivery de Bebidas

Aplicativo Flutter desenvolvido para a disciplina de Desenvolvimento Movel. O projeto simula um app de delivery de bebidas, permitindo visualizar o catalogo, cadastrar novos produtos e montar a sacola do pedido.

## Integrantes

- Rodrigo: configuracao inicial do projeto, organizacao da estrutura do app, catalogo de bebidas, navegacao, formulario de cadastro e ajustes gerais da interface.
- Denner: implementacao e ajustes da tela de sacola.
- Renato: Implementação da tela de pagamento e seus formularios.

## Objetivo do aplicativo

O aplicativo foi criado para demonstrar conceitos vistos em aula, incluindo:

- interface para dispositivos moveis
- navegacao entre telas
- gerenciamento de estado com Provider e ChangeNotifier
- formulario com validacoes
- feedback visual ao usuario
- organizacao em camadas

## Estrutura do projeto

O projeto esta organizado em um padrao proximo de MVVM:

- `models`: estruturas de dados do app
- `repositories`: camada de dados
- `features`: telas e viewmodel do catalogo
- `routes.dart`: configuracao de navegacao com GoRouter

Principais arquivos:

- `lib/main.dart`: ponto de entrada do app
- `lib/app/app.dart`: configuracao geral da aplicacao e providers
- `lib/app/routes.dart`: rotas do aplicativo
- `lib/app/features/catalogo/catalogo_screen.dart`: tela principal do catalogo
- `lib/app/features/catalogo/cadastrar_bebida_screen.dart`: formulario de cadastro
- `lib/app/features/catalogo/catalogo_viewmodel.dart`: logica do catalogo
- `lib/app/cart_view.dart`: tela da sacola
- `lib/app/models/cart_model.dart`: controle da sacola
- `lib/app/repositories/bebidas_repository.dart`: simulacao da fonte de dados

## Tecnologias utilizadas

- Dart
- Flutter
- Provider
- GoRouter

## Funcionalidades

- exibicao do catalogo de bebidas
- cadastro de novas bebidas
- validacao de formulario
- feedback com SnackBar
- adicao de itens na sacola
- alteracao de quantidade e remocao de itens
- simulacao de checkout

## Instalacao e execucao

1. Ter o Flutter instalado e configurado no computador.
2. Clonar este repositorio.
3. Abrir a pasta do projeto no terminal.
4. Executar:

```bash
flutter pub get
flutter run
```

## Observacoes

- O projeto usa dados locais para simular o catalogo.
- O carregamento das bebidas foi feito com atraso artificial para demonstrar estado de loading.
- O checkout e simulado, sem integracao com pagamento real.
- O repositorio deve permanecer publico no GitHub para avaliacao.
