# Projeto Mobile - Delivery de Bebidas

Aplicativo Flutter desenvolvido para a disciplina de Desenvolvimento Móvel. O projeto simula um app de delivery de bebidas com autenticação, catálogo, sacola, pagamento simulado, histórico de pedidos e separação de permissões entre comprador e administrador.

## Integrantes

- Rodrigo: configuração inicial do projeto, organização da estrutura do app, catálogo de bebidas, navegação, autenticação, controle de perfis, formulário de cadastro de bebidas e ajustes gerais da interface.
- Denner: implementação e ajustes da tela de sacola.
- Renato: implementação da tela de pagamento e seus formulários.

## Objetivo do aplicativo

O aplicativo foi criado para demonstrar conceitos vistos em aula, incluindo:

- interface para dispositivos móveis
- navegação entre telas
- gerenciamento de estado com Provider e ChangeNotifier
- autenticação de usuários
- controle de permissões por perfil
- persistência local com SQLite
- formulários com validações
- feedback visual ao usuário
- organização em camadas

## Perfis de usuário

O sistema possui dois perfis:

- `comprador`: pode visualizar o catálogo, adicionar itens à sacola, finalizar pedidos e consultar seus pedidos.
- `admin`: pode acessar o catálogo e cadastrar novas bebidas.

O cadastro feito pela tela do aplicativo cria usuários com perfil `comprador`.

Usuários de teste:

```text
Comprador
Email: usuario@bebidas.com
Senha: 123456

Administrador
Email: admin@bebidas.com
Senha: 123456
```

## Funcionalidades

- login de usuário
- cadastro de comprador
- proteção de rotas
- botão de sair
- exibição do catálogo de bebidas
- cadastro de novas bebidas para administradores
- validação de formulários
- feedback com SnackBar
- adição de itens na sacola
- alteração de quantidade e remoção de itens
- pagamento simulado
- gravação de pedidos no SQLite
- listagem de pedidos do usuário logado

## Estrutura do projeto

O projeto está organizado em um padrão próximo de MVVM:

- `models`: estruturas de dados e estados do app
- `repositories`: camada de acesso aos dados
- `features`: telas e viewmodels por funcionalidade
- `routing`: configuração de navegação com GoRouter
- `database`: configuração do banco SQLite

Principais arquivos:

- `lib/main.dart`: ponto de entrada do app
- `lib/app/app.dart`: configuração geral da aplicação e providers
- `lib/routing/routes.dart`: rotas e proteção de navegação
- `lib/app/database/app_database.dart`: criação, migração e seed do banco SQLite
- `lib/app/models/auth_model.dart`: controle de autenticação e sessão
- `lib/app/models/app_user.dart`: modelo de usuário e perfil
- `lib/app/repositories/users_repository.dart`: cadastro e validação de usuários
- `lib/app/repositories/bebidas_repository.dart`: acesso aos dados das bebidas
- `lib/app/repositories/cart_repository.dart`: persistência da sacola
- `lib/app/repositories/pedidos_repository.dart`: cadastro e consulta de pedidos
- `lib/app/features/auth/login_screen.dart`: tela de login
- `lib/app/features/auth/cadastro_screen.dart`: tela de cadastro de usuário
- `lib/app/features/catalogo/catalogo_screen.dart`: tela principal do catálogo
- `lib/app/features/catalogo/cadastrar_bebida_screen.dart`: formulário de cadastro de bebida
- `lib/app/features/catalogo/pagamento_screen.dart`: tela de pagamento simulado
- `lib/app/features/catalogo/pedidos_screen.dart`: tela de pedidos
- `lib/app/features/sacola/cart_view.dart`: tela da sacola
- `lib/app/models/cart_model.dart`: controle da sacola

## Banco de dados

O projeto usa SQLite local com `sqflite` e `sqflite_common_ffi`.

Tabelas principais:

- `users`: usuários do sistema, com perfil `admin` ou `comprador`
- `bebidas`: produtos exibidos no catálogo
- `cart_items`: itens salvos na sacola
- `pedidos`: pedidos realizados
- `pedido_items`: itens de cada pedido

O arquivo do banco é criado automaticamente pelo app com o nome:

```text
bebidas_delivery.db
```

## Tecnologias utilizadas

- Dart
- Flutter
- Provider
- GoRouter
- SQLite
- sqflite
- sqflite_common_ffi
- crypto
- brasil_fields

## Instalação e execução

1. Ter o Flutter instalado e configurado no computador.
2. Clonar este repositório.
3. Abrir a pasta do projeto no terminal.
4. Executar:

```bash
flutter pub get
flutter run
```

## Observações

- O projeto usa dados locais para simular o catálogo.
- O checkout é simulado, sem integração com pagamento real.
- As senhas são salvas como hash SHA-256.
- O botão de cadastro de bebidas aparece apenas para administradores.
- O comprador não consegue acessar diretamente a rota de cadastro de bebidas.
- O repositório deve permanecer público no GitHub para avaliação.
