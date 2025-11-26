# Caronapp — Resumo do Projeto

Este documento resume a arquitetura atual do projeto Caronapp (Flutter), os modelos de dados, o mapeamento para Firestore, telas a implementar (Trip Detail, Trip Create) e passos sugeridos para integração com Firebase Authentication (email/senha) e Firestore.

> Gerado automaticamente para facilitar as próximas modificações e a migração dos dados mockados para Firestore.

---

## 1. Visão geral do repositório

Estrutura relevante:

- `lib/core/theme/` — `app_colors.dart`, `app_theme.dart` (theming global)
- `lib/shared/widgets/` — `app_button.dart`, `app_input.dart`, `trip_card.dart` (componentes)
- `lib/shared/models/` — modelos Dart (ainda a padronizar)
- `lib/shared/mocks/` — `mock_trips.dart`, `mock_user.dart` (dados de desenvolvimento)
- `lib/features/intro/intro_screen.dart` — tela inicial
- `lib/features/auth/login_sheet.dart` — modal de login/signup
- `lib/features/home/home_screen.dart` — tela Home (mock)
- `lib/features/home/` — local sugerido para `trip_detail.dart` e `trip_create.dart`

## 2. Objetivos do próximo trabalho

- Substituir os mocks por uma integração com Firebase (Auth + Firestore).
- Criar telas de detalhe de carona e criação de carona.
- Definir modelos Dart com `fromMap`/`toMap` e tipos claros.
- Fornecer regras de segurança Firestore iniciais.

## 3. Modelos propostos (Dart)

### 3.1 `User` — `lib/shared/models/user.dart`

```dart
class User {
  final String id; // uid do Firebase
  final String name;
  final String email;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory User.fromMap(String id, Map<String, dynamic> map) => User(
    id: id,
    name: map['name'] as String? ?? '',
    email: map['email'] as String? ?? '',
    avatarUrl: map['avatarUrl'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
  };
}
```

> Nota: incluir `id` (Firebase uid) é importante para autorizações e queries.

### 3.2 `Trip` — `lib/shared/models/trip.dart`

```dart
class Trip {
  final String id; // doc id no Firestore
  final String driverId; // uid do motorista
  final String driverName;
  final String? driverAvatarUrl;
  final String origin;
  final String destination;
  final String whenLabel; // ex: 'Hoje • 19:00' (string legível)
  final DateTime when; // data/hora canônica para ordenação
  final int seats;
  final String? note;
  final bool active; // se ainda está ativa

  const Trip({
    required this.id,
    required this.driverId,
    required this.driverName,
    this.driverAvatarUrl,
    required this.origin,
    required this.destination,
    required this.whenLabel,
    required this.when,
    required this.seats,
    this.note,
    this.active = true,
  });

  factory Trip.fromMap(String id, Map<String, dynamic> map) => Trip(
    id: id,
    driverId: map['driverId'] as String,
    driverName: map['driverName'] as String,
    driverAvatarUrl: map['driverAvatarUrl'] as String?,
    origin: map['origin'] as String,
    destination: map['destination'] as String,
    whenLabel: map['whenLabel'] as String,
    when: (map['when'] as Timestamp).toDate(),
    seats: map['seats'] as int,
    note: map['note'] as String?,
    active: map['active'] as bool? ?? true,
  );

  Map<String, dynamic> toMap() => {
    'driverId': driverId,
    'driverName': driverName,
    'driverAvatarUrl': driverAvatarUrl,
    'origin': origin,
    'destination': destination,
    'whenLabel': whenLabel,
    'when': Timestamp.fromDate(when),
    'seats': seats,
    'note': note,
    'active': active,
  };
}
```

> Observação: `Timestamp` vem de `cloud_firestore`. Para os mocks locais, mantenha `whenLabel` e `when` compatíveis.

### 3.3 (Opcional) `RideRequest` ou `Booking` — para futuros pedidos

- `id`, `tripId`, `riderId`, `status` (pending/accepted/rejected), `createdAt`.

## 4. Firestore — Coleções e documentos

Sugestão de modelagem simples:

- `users/{userId}`

  - name, email, avatarUrl, createdAt

- `trips/{tripId}`

  - driverId, driverName, driverAvatarUrl, origin, destination, when (timestamp), whenLabel, seats, note, active

- `trips/{tripId}/requests/{requestId}` (opcional)
  - riderId, message, status, createdAt

Índices sugeridos:

- Order by `when` (asc) para lista de próximas caronas.
- Queries por `origin`, `destination` podem exigir índices compostos se for filtrado.

## 5. Autenticação (Firebase Auth) — fluxo mínimo

- Login com email/senha.
- Cadastro: ao criar na Auth, também gravar um `users/{uid}` com `name` e `email`.
- Após login bem-sucedido: navegar para `HomeScreen(user: mockUser)` substituído por `HomeScreen(user: fetchedUser)`.

Exemplo de inicialização (Flutter):

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Caronapp());
}
```

Exemplo de helper (AuthService):

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    // buscar user doc em users/{uid}
  }

  Future<User?> signUp(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = cred.user!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // retornar objeto User
  }
}
```

## 6. Segurança (exemplo básico de regras Firestore)

```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    match /trips/{tripId} {
      allow read: if true; // leitura pública
      allow create: if request.auth != null && request.resource.data.driverId == request.auth.uid;
      allow update: if request.auth != null && resource.data.driverId == request.auth.uid;
      allow delete: if request.auth != null && resource.data.driverId == request.auth.uid;
    }
  }
}
```

Ajuste conforme as regras de negócio (por exemplo, permitir que passageiros criem requests, etc.).

## 7. Telas a implementar / modificar

- `TripDetailScreen` (`lib/features/trip/trip_detail.dart`)

  - Mostra informações da carona (driver, origem, destino, whenLabel, seats, note)
  - Botões: Solicitar vaga (abre modal), Compartilhar, Fechar

- `TripCreateScreen` (`lib/features/trip/trip_create.dart`)

  - Formulário com campos: origem, destino, when (DateTime picker), seats (int), note (opcional)
  - Validações (campos obrigatórios, seats > 0)
  - Ao salvar: criar documento em `trips/` com `driverId = currentUser.uid` e `driverName`

- Ajustes no `LoginSheet`: ao criar usuário, pedir `name` (se desejar) e salvar `users/{uid}`.

## 8. Migração do mock para Firestore (passos)

1. Criar as models com `fromMap`/`toMap` (ver seção 3).
2. Criar um `TripRepository` que fornece:
   - `Stream<List<Trip>> watchUpcomingTrips()` — usa `FirebaseFirestore.instance.collection('trips')...snapshots()`.
   - `Future<void> createTrip(Trip t)` — cria documento.
3. Substituir o uso de `mock_trips.dart` por `TripRepository.watchUpcomingTrips()` usando `StreamBuilder` ou `FutureBuilder` com estados de loading/empty/error.
4. Testar localmente com emulador Firestore ou projeto de dev no Firebase.

Exemplo de stream:

```dart
Stream<List<Trip>> watchTrips() {
  return FirebaseFirestore.instance
    .collection('trips')
    .where('active', isEqualTo: true)
    .orderBy('when')
    .snapshots()
    .map((snap) => snap.docs.map((d) => Trip.fromMap(d.id, d.data())).toList());
}
```

## 9. UX / validações importantes

- Inputs com validação (email, senha >= 6).
- Em criação de carona: validar `when` no futuro, `seats` >= 1.
- Mostrar loading indicando operações com Firestore.
- Tratamento de erros do Firebase (e.g. email já em uso).

## 10. Testes e verificação local

- Usar Firebase Emulator Suite para testes offline (Auth + Firestore).
- Fluxo manual de verificação:
  1. `flutter run` com emulador; `firebase emulators:start` em outro terminal.
  2. Criar usuário via app (signup), verificar `users/{uid}` no emulator UI.
  3. Criar carona e verificar `trips/`.
  4. Abrir detalhe da carona.

## 11. Arquivos a adicionar (resumo)

- `lib/shared/models/user.dart` (com `id`)
- `lib/shared/models/trip.dart` (com `id` e Timestamp mapping)
- `lib/shared/repos/trip_repository.dart` (Firestore access)
- `lib/features/trip/trip_detail.dart`
- `lib/features/trip/trip_create.dart`
- `lib/services/auth_service.dart` (Auth helpers)
- `docs/PROJECT_SUMMARY.md` (este arquivo)

## 12. Próximos passos sugeridos (prioridade)

1. Implementar os modelos (`User`, `Trip`) com `fromMap`/`toMap`.
2. Implementar `AuthService` e inicialização do Firebase no `main.dart`.
3. Implementar `TripRepository` (watch/create).
4. Substituir `mock_trips` pelo stream do repositório (usar `StreamBuilder`).
5. Criar `TripDetailScreen` e `TripCreateScreen` básicos.
6. Adotar Firebase Emulator para testes.

---

Se quiser, já implemento os próximos passos 1 e 2 (modelos + inicialização Firebase + AuthService mínima) — quer que eu siga com isso agora? Caso sim, informe se deseja usar o Firebase Emulator (recomendado) ou conectar direto ao projeto Firebase existente (entregar credenciais/configos manualmente).

## Processo de implementação (registro)

Execução solicitada: A -> B -> C (modelos, integração Firebase/Auth, telas TripDetail/TripCreate). Abaixo o que eu implementei neste commit local:

- Modelos atualizados/criados:

  - `lib/shared/models/user.dart` — agora com `id`, `fromMap`/`toMap` (usa `Timestamp`/`cloud_firestore`).
  - `lib/shared/models/trip.dart` — agora com `id`, `driverId`, `when` (`DateTime`), `fromMap`/`toMap`.

- Repositório:

  - `lib/shared/repos/trip_repository.dart` — `watchUpcomingTrips()`, `createTrip()` e `getTrip()` (Firestore).

- Serviços:

  - `lib/services/auth_service.dart` — helpers `signIn`, `signUp`, `signOut`, `currentUserFromAuth` (Firebase Auth + Firestore user doc).

- Inicialização Firebase:

  - `lib/main.dart` atualizado para `WidgetsFlutterBinding.ensureInitialized()` e `await Firebase.initializeApp()`.
  - `pubspec.yaml` atualizado com dependências: `firebase_core`, `firebase_auth`, `cloud_firestore`.

- Telas adicionadas (esboço):
  - `lib/features/trip/trip_detail.dart` — UI de detalhes da carona (botão solicitar/compartilhar).
  - `lib/features/trip/trip_create.dart` — formulário de criação de carona (origem/destino/data/hora/vagas).

Notas importantes:

# Caronapp — Resumo do projeto (estado atual)

Este documento descreve o estado atual do projeto Caronapp (Flutter), o mapeamento de dados, o que já está implementado e as pendências recomendadas para desenvolvimento. Removi a seção de testes conforme solicitado.

---

## 1. Visão geral do repositório

Principais arquivos/pastas relevantes (implementados):

- `lib/main.dart` — inicializa o Firebase (usa `lib/firebase_options.dart`).
- `lib/core/theme/` — `app_colors.dart`, `app_theme.dart` (theming global).
- `lib/shared/widgets/` — componentes reutilizáveis (ex.: `app_button.dart`, `app_input.dart`, `trip_card.dart`).
- `lib/shared/models/` — `user.dart`, `trip.dart` (modelos com `fromMap`/`toMap`).
- `lib/shared/mocks/` — `mock_trips.dart`, `mock_user.dart` (dados de desenvolvimento ainda disponíveis).
- `lib/shared/repos/trip_repository.dart` — acesso ao Firestore (`watchUpcomingTrips`, `createTrip`, `getTrip`).
- `lib/services/auth_service.dart` — helpers de autenticação (signIn/signUp/signOut, leitura de `users/{uid}`).
- `lib/features/auth/login_sheet.dart` — sheet de login/cadastro que usa `AuthService`.
- `lib/features/home/home_screen.dart` — lista caronas; consome `TripRepository.watchUpcomingTrips()` via `StreamBuilder`.
- `lib/features/trip/trip_create.dart` — tela de criação de carona (formulário e criação via `TripRepository`).
- `lib/features/trip/trip_detail.dart` — tela de detalhes da carona.

## 2. O que já está implementado

- Firebase inicializado em `main.dart` com `DefaultFirebaseOptions` (gerado): `firebase_options.dart` existe.
- Modelos `User` e `Trip` existem em `lib/shared/models/` e possuem `fromMap`/`toMap`.
- `AuthService` conecta com `firebase_auth` e grava/recupera documentos em `users/{uid}`.
- `TripRepository` já expõe um stream ordenado por `when` e métodos de criação/consulta.
- `HomeScreen` apresenta dados vindos do Firestore (ou do emulator) via stream.
- Telas de criação e detalhe de carona estão implementadas e integradas ao repositório/auth quando aplicável.

## 3. Firestore — coleções e documentos (modelo atual)

Estrutura usada pelo app:

- `users/{userId}` — name, email, avatarUrl, createdAt.
- `trips/{tripId}` — driverId, driverName, driverAvatarUrl, origin, destination, when (timestamp), whenLabel, seats, note, active.
- (Opcional) `trips/{tripId}/requests/{requestId}` — para pedidos/solicitações (não implementado no backend ainda).

Índices / consultas importantes:

- O app ordena por `when` (asc) para listar próximas caronas.
- Filtragens por origem/destino podem exigir índices compostos dependendo das queries futuras.

## 4. Autenticação (estado atual)

- Login com email/senha implementado na UI (`LoginSheet`) usando `AuthService`.
- Ao cadastrar (signUp) o `AuthService` cria um documento em `users/{uid}` com `name`, `email` e `createdAt`.
- O app usa o `FirebaseAuth.instance.currentUser` em pontos como `TripCreateScreen` para atribuir `driverId`.

## 5. Segurança e regras Firestore

O sumário continha um exemplo de regras Firestore — ele é um bom ponto de partida. Porém, **não há um arquivo `firestore.rules` versionado no repositório**. Recomendo adicionar as regras de exemplo como um arquivo `firestore.rules` (exemplo abaixo) e depois ajustá-las conforme as regras de negócio:

Exemplo mínimo sugerido (colocar em `firestore.rules`):

```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    match /trips/{tripId} {
      allow read: if true;
      allow create: if request.auth != null && request.resource.data.driverId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.driverId == request.auth.uid;
    }
  }
}
```

Coloque as regras no repositório e depois use `firebase deploy --only firestore:rules` quando estiver pronto.

## 6. Arquivos de configuração do Firebase (existentes / ação recomendada)

- `firebase.json` está presente e contém configurações geradas para o projeto `caronapp-48e5c`.
- `android/app/google-services.json` já existe no repositório (verifique se é o arquivo correto para o ambiente que você quer usar).
- `lib/firebase_options.dart` existe e foi gerado pela CLI do Firebase para as plataformas configuradas.
- Para iOS: ainda é necessário adicionar `GoogleService-Info.plist` manualmente em `ios/Runner/` quando for conectar ao projeto real (não versionar credenciais sensíveis no repo se for público).

## 7. Pendências recomendadas (prioridade prática)

1. Adicionar `firestore.rules` com o exemplo acima e versioná-lo no repo.
2. Criar (opcional) um `docs/EMULATOR.md` com passos rápidos de como rodar o Firebase Emulator Suite localmente (Auth + Firestore). Exemplo de comandos:

```bash
flutter pub get
firebase emulators:start --only auth,firestore
flutter run
```

3. Revisar `android/app/google-services.json` para garantir que é o arquivo apropriado para desenvolvimento; adicionar instrução clara no README sobre credenciais e quando/como adicionar `GoogleService-Info.plist` para iOS.
4. (Opcional) Adicionar um workflow CI simples para builds em PRs (ex.: `.github/workflows/flutter-ci.yml`) se desejar verificação automática em commits.
5. Implementar fluxo de requests/pedidos (`trips/{tripId}/requests`) e ajustar regras Firestore para suportar esse caso quando necessário.

## 8. Telas / UX — o que já existe e próximos ajustes

- `TripDetailScreen` (`lib/features/trip/trip_detail.dart`) — implementada, inclui botão "Solicitar vaga" (fluxo de request ainda por implementar).
- `TripCreateScreen` (`lib/features/trip/trip_create.dart`) — implementada; valida origin/destination, permite seleção de data/hora, número de vagas e cria documento em `trips/` usando `TripRepository`.
- `LoginSheet` — implementado e integrado ao `AuthService`.

## 9. Observações operacionais

- A aplicação usa `firebase_core`, `firebase_auth` e `cloud_firestore` — rode `flutter pub get` antes de executar.
- Recomendo usar o Firebase Emulator Suite para desenvolvimento local (evita custos e facilita testes de regras e auth).

---

Se quiser, eu aplico também os itens da seção "Pendências" automaticamente:

- A: adicionar `firestore.rules` com o snippet acima;
- B: criar `docs/EMULATOR.md` com instruções passo-a-passo;
- C: criar um esqueleto `.github/workflows/flutter-ci.yml` (build básico sem emulator).

Diga qual (A/B/C) você quer que eu faça agora. Se preferir só atualizar o sumário, já terminei essa parte.
