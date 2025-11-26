# Caronapp - Fluxos de telas e jornadas do usuário

Este documento descreve os fluxos principais do aplicativo, a ordem das telas e os estados esperados durante as jornadas mais importantes (MVP): criar carona, ver caronas, solicitar vaga e gerenciar pedidos.

## Visão geral das telas existentes

- `IntroScreen` (`lib/features/intro/intro_screen.dart`) — tela inicial de boas-vindas / onboarding.
- `LoginSheet` (`lib/features/auth/login_sheet.dart`) — sheet modal para login / cadastro (AuthService).
- `HomeScreen` (`lib/features/home/home_screen.dart`) — lista de caronas (usa `TripRepository.watchUpcomingTrips`).
- `TripDetailScreen` (`lib/features/trip/trip_detail.dart`) — detalhes de uma carona; ação principal: Solicitar vaga / Compartilhar.
- `TripCreateScreen` (`lib/features/trip/trip_create.dart`) — formulário para criar carona (agora com `TripViewModel`).

## Jornada A: Entrar no app

1. Usuário abre o app -> `IntroScreen`.
2. Se não autenticado, chamar `LoginSheet` (modal) para signIn/signUp.
3. Ao autenticar com sucesso, navegar para `HomeScreen` (substitui a stack atual).

Estados importantes:

- Se usuário autenticado, `HomeScreen` exibe saudação com `user.name`.
- Se não autenticado, `HomeScreen` ainda pode exibir caronas públicas, mas ações restritas (criar carona, solicitar vaga) devem abrir o `LoginSheet`.

## Jornada B: Ver lista de caronas (Home)

1. `HomeScreen` (stream) mostra caronas ordenadas por `when` (próximas primeiras).
2. Estado: loading -> mostra `CircularProgressIndicator` até receber dados.
3. Se lista vazia -> mostrar tela/placeholder "Nenhuma carona disponível" com CTA para criar carona (se autenticado).
4. Ao tocar num `TripCard`, navegar para `TripDetailScreen(trip)`.

## Jornada C: Criar uma carona (TripCreate)

Entrada: a partir do FAB em `HomeScreen` ou outro CTA.

1. Abrir `TripCreateScreen`.
2. Preencher origem, destino, escolher data/hora e vagas, observação opcional.
3. Ao submeter:
   - Validar campos (origin/destination não vazios, when presente e futuro, seats >= 1).
   - Desabilitar o botão e mostrar loading (via `TripViewModel` estado `loading`).
   - Criar documento em `trips/` com `driverId = currentUser.uid` e `driverName`.
   - Em sucesso: fechar tela e mostrar `SnackBar` de confirmação.
   - Em erro: reabilitar botão e mostrar erro legível.

Critérios de aceite:

- A trip aparece no `HomeScreen` automaticamente (stream) após criação.

## Jornada D: Solicitar vaga (Rider)

Entrada: `TripDetailScreen` (usuário autenticado que não é o motorista).

1. Usuário toca em "Solicitar vaga" -> abrir `RequestSheet` (modal) com campo mensagem opcional.
2. Ao submeter:
   - Validar autenticação (se não, abrir `LoginSheet`).
   - Verificar se já existe request pending do mesmo `riderId` (opcional: bloquear duplicata).
   - Criar documento em `trips/{tripId}/requests` com `riderId`, `riderName`, `message`, `status: 'pending'`, `createdAt`.
   - Em sucesso: fechar modal e mostrar snackbar "Pedido enviado".

Estados/erros:

- Se não houver vagas (seats <= 0): bloquear envio e mostrar mensagem.
- Se erro de permissão, mostrar mensagem específica e sugerir login/contato.

## Jornada E: Gerenciar pedidos (Driver)

Entrada: `TripDetailScreen` quando `currentUser.uid == trip.driverId`.

1. Driver vê seção "Pedidos" com `StreamBuilder` em `TripRepository.watchRequests(trip.id)`.
2. Cada request mostra `riderName`, `message`, `createdAt` e ações: Aceitar / Rejeitar.
3. Ao aceitar:
   - Chamar `TripRepository.acceptRequest(tripId, requestId)` que executa transação:
     - Verificar seats > 0
     - Atualizar request.status = 'accepted'
     - Decrementar trips.seats
     - Se seats vira 0, set trips.active = false
   - Em sucesso: atualizar UI (request.status == 'accepted') e mostrar snackbar.
4. Ao rejeitar: `rejectRequest` atualiza request.status = 'rejected'.

Estados / edge cases:

- Se duas accepts concorrentes ocorrerem, apenas uma deve suceder (transação).
- Se seats já é 0, aceitar deve falhar e mostrar mensagem.

## Navegação e UX — sumário rápido

- Navegação principal: Intro -> (Login) -> Home
- Home -> TripDetail
- Home -> TripCreate (FAB)
- TripDetail (não-owner) -> RequestSheet
- TripDetail (owner) -> Requests list (aceitar/rejeitar)

UX notes:

- Usar snackbars para confirmação rápida (envio/aceitação/rejeição).
- Bloquear botão durante requisições de rede.
- Exibir estados loading/empty/error em todas as listas.

## Próximos passos recomendados (implementação)

1. Implementar `RequestSheet` modal para Rider.
2. Adicionar seção de Requests no `TripDetailScreen` para Driver.
3. Testar concorrência para aceitar (usar Emulator ou dois dispositivos).
4. Polir mensagens e estados.

Se quiser, eu já implemento o `RequestSheet` e a seção de Requests no `TripDetailScreen` agora — confirme que devo prosseguir e eu aplico as mudanças.
