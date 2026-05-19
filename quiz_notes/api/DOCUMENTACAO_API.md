# Quiz Notes API — Documentação Técnica

> Versão: 1.0.0 | Stack: Node.js · TypeScript · Express · TypeORM · PostgreSQL

---

## Sumário

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Banco de Dados](#banco-de-dados)
4. [Regras de Negócio](#regras-de-negócio)
5. [Endpoints](#endpoints)
6. [Tratamento de Erros](#tratamento-de-erros)
7. [Testes](#testes)

---

## Visão Geral

A **Quiz Notes API** é o backend do aplicativo de flashcards de mesmo nome. Ela gerencia usuários, baralhos e cartões de estudo, e implementa o **Algoritmo SM-2** (SuperMemo 2) para agendamento inteligente de revisões por repetição espaçada.

---

## Arquitetura

O projeto segue o padrão **MVC** com separação em camadas:

```
src/
├── config/
│   └── data-source.ts       # Configuração do TypeORM / PostgreSQL
├── controllers/             # Camada HTTP: recebe req, chama service, retorna res
├── services/                # Regras de negócio
├── model/                   # Entidades TypeORM (mapeamento do banco)
├── routes/                  # Mapeamento de rotas
├── middlewares/
│   └── errorHandler.ts      # Middleware global de erros
└── errors/
    ├── AppError.ts          # Classe base de erros
    ├── NotFoundError.ts     # HTTP 404
    └── BadRequestError.ts   # HTTP 400
```

**Fluxo de uma requisição:**
```
Request → Route → Controller → Service → Repository (TypeORM) → PostgreSQL
                                       ↓
Response ← Controller ←────────────── Service (ou lança AppError)
                ↓
          errorHandler (middleware global, captura qualquer AppError)
```

---

## Banco de Dados

### Diagrama de Entidades

```
┌─────────────────┐       ┌────────────────────────────────────┐       ┌──────────────────┐
│    usuarios     │       │              cards                 │       │historico_revisoes│
├─────────────────┤       ├────────────────────────────────────┤       ├──────────────────┤
│ id_usuario (PK) │──┐    │ id_card (PK)                       │──┐    │ id_historico (PK)│
│ nome            │  │    │ frente          (text)             │  │    │ id_card (FK)     │
│ email           │  │    │ verso           (text)             │  └───>│ resultado        │
│ senha           │  │    │ desempenho      (int4)  ← SM-2     │       │ data_revisao     │
│ criado_em       │  │    │ acertos         (int4)             │       └──────────────────┘
└─────────────────┘  │    │ erros           (int4)             │
                     │    │ intervalo       (int4)  ← SM-2     │
      ┌──────────────┘    │ proxima_revisao (timestamptz) ←SM-2│
      │                   │ imagem_url      (text, nullable)   │
      │  ┌────────────┐   │ id_baralho (FK)                    │
      └─>│  baralhos  │   │ criado_em                          │
         ├────────────┤   └────────────────────────────────────┘
         │id_baralho  │<──── id_baralho (FK em cards)
         │nome        │
         │id_usuario  │
         │criado_em   │
         └────────────┘
```

### Descrição das Colunas SM-2 (tabela `cards`)

| Coluna | Tipo | Descrição |
|---|---|---|
| `desempenho` | int4 | Fator de facilidade × 100 (ex: 250 = 2.5). Mínimo: 130 (1.3). |
| `acertos` | int4 | Número de revisões consecutivas corretas. Reseta para 0 em erro. |
| `erros` | int4 | Total acumulado de erros. |
| `intervalo` | int4 | Número de dias até a próxima revisão. |
| `proxima_revisao` | timestamptz | Data calculada pelo SM-2 para a próxima sessão. |

---

## Regras de Negócio

### RN-01 — Criação de Usuário

- Os campos `nome`, `email` e `senha` são **obrigatórios**.
- A ausência de qualquer campo lança `BadRequestError` com mensagem: *"Nome, email e senha são obrigatórios"*.

### RN-02 — Criação de Baralho

- O campo `nome` é **obrigatório**. Ausência lança `BadRequestError`.
- O `id_usuario` referenciado deve existir no banco. Caso contrário, lança `NotFoundError`: *"Usuário não encontrado"*.

### RN-03 — Criação de Card

- Os campos `frente` e `verso` são **obrigatórios**. Ausência lança `BadRequestError`: *"Frente e verso são obrigatórios"*.
- O `id_baralho` referenciado deve existir. Caso contrário, lança `NotFoundError`: *"Baralho não encontrado"*.
- Um card é criado com os valores padrão do SM-2: `desempenho=0`, `acertos=0`, `erros=0`, `intervalo=0`.

### RN-04 — Revisão Agendada (SM-2)

- Retorna apenas cards cujo `proxima_revisao` seja **menor ou igual a hoje**, ou que ainda não foram revisados (`proxima_revisao IS NULL`).

### RN-05 — Submissão de Revisão (Algoritmo SM-2)

A `qualidade` é um inteiro entre **0 e 5** (obrigatório). Fora desse intervalo, lança `BadRequestError`.

| Qualidade | Significado |
|---|---|
| 5 | Resposta perfeita |
| 4 | Correta com hesitação leve |
| 3 | Correta com dificuldade |
| 2 | Errada, mas a resposta era familiar |
| 1 | Errada, resposta lembrada ao ver |
| 0 | Blackout total |

**Lógica de cálculo:**

```
SE qualidade >= 3 (acerto):
  SE acertos == 0 → intervalo = 1 dia
  SE acertos == 1 → intervalo = 6 dias
  SENÃO           → intervalo = round(intervalo_atual × (desempenho / 100))
  acertos++

SE qualidade < 3 (erro):
  acertos = 0   (reseta sequência)
  intervalo = 1 (retorna para o início)
  erros++

desempenho = desempenho + (0.1 − (5 − qualidade) × (0.08 + (5 − qualidade) × 0.02)) × 100
SE desempenho < 130 → desempenho = 130  (fator mínimo: 1.3)

proxima_revisao = hoje + intervalo (dias)
```

- Cada revisão gera um registro em `historico_revisoes` com `resultado = 'ACERTO'` ou `'ERRO'`.
- O card retornado já contém os valores atualizados.

### RN-06 — Tratamento de Erros

- Erros mapeados (`AppError` e subclasses) retornam o `statusCode` correto e o campo `message` no body.
- Erros não mapeados (ex: falha de conexão) retornam `500 Internal Server Error` com mensagem genérica, sem expor detalhes internos.

---

## Endpoints

> **Base URL:** `http://localhost:3000/api`
> Todos os requests e responses utilizam `Content-Type: application/json`.

---

### Usuários

#### `POST /users`
Cria um novo usuário.

**Request Body:**
```json
{
  "nome": "João Silva",
  "email": "joao@example.com",
  "senha": "senha123"
}
```

**Responses:**

| Status | Descrição |
|---|---|
| `201 Created` | Usuário criado com sucesso. Retorna o objeto do usuário. |
| `400 Bad Request` | Campo obrigatório ausente. |

---

#### `GET /users/:id`
Busca um usuário pelo seu UUID.

**Responses:**

| Status | Descrição |
|---|---|
| `200 OK` | Retorna o objeto do usuário. |
| `404 Not Found` | Usuário não encontrado. |

---

### Baralhos

#### `POST /users/:userId/decks`
Cria um baralho vinculado a um usuário.

**Request Body:**
```json
{
  "nome": "Matemática Básica"
}
```

**Responses:**

| Status | Descrição |
|---|---|
| `201 Created` | Baralho criado com sucesso. |
| `400 Bad Request` | Nome do baralho ausente. |
| `404 Not Found` | Usuário não encontrado. |

---

#### `GET /users/:userId/decks`
Lista todos os baralhos de um usuário.

**Responses:**

| Status | Descrição |
|---|---|
| `200 OK` | Array com os baralhos do usuário (pode ser vazio `[]`). |

---

### Cards

#### `POST /decks/:deckId/cards`
Cria um card dentro de um baralho.

**Request Body:**
```json
{
  "frente": "Qual é a capital do Brasil?",
  "verso": "Brasília"
}
```

**Responses:**

| Status | Descrição |
|---|---|
| `201 Created` | Card criado com valores SM-2 padrão. |
| `400 Bad Request` | `frente` ou `verso` ausentes. |
| `404 Not Found` | Baralho não encontrado. |

---

### Revisões

#### `GET /decks/:deckId/revisao`
Retorna os cards do baralho que estão prontos para revisão hoje (SM-2).

> Cards com `proxima_revisao IS NULL` (nunca revisados) também são incluídos.

**Responses:**

| Status | Descrição |
|---|---|
| `200 OK` | Array de cards pendentes de revisão. |

---

#### `POST /cards/:cardId/revisao`
Submete o resultado de uma revisão e recalcula o agendamento SM-2 do card.

**Request Body:**
```json
{
  "qualidade": 4
}
```

**Responses:**

| Status | Descrição |
|---|---|
| `200 OK` | Card atualizado com novos valores SM-2 e `proxima_revisao`. |
| `400 Bad Request` | `qualidade` fora do intervalo [0–5]. |
| `404 Not Found` | Card não encontrado. |

---

## Tratamento de Erros

Todos os erros retornam o seguinte formato JSON:

```json
{
  "status": "error",
  "message": "Descrição do problema"
}
```

### Hierarquia de Exceções

```
AppError (base)
├── BadRequestError  → HTTP 400
└── NotFoundError    → HTTP 404

Erros não mapeados  → HTTP 500 | mensagem genérica
```

---

## Testes

O projeto utiliza **Jest** + **ts-jest** para testes unitários e **Supertest** para testes de integração HTTP. A abordagem é **TDD** (Test-Driven Development): os testes são escritos antes da implementação.

Para rodar todos os testes:
```bash
npx jest
```

---

### UserService — Testes Unitários

| # | Descrição | Tipo |
|---|---|---|
| 1 | Deve criar um novo usuário com sucesso | Unitário |
| 2 | Deve lançar erro se o e-mail estiver ausente | Unitário |
| 3 | Deve buscar um usuário pelo ID | Unitário |
| 4 | Deve lançar `NotFoundError` se o usuário não existir | Unitário |

### UserController — Testes de Integração

| # | Descrição | Status Esperado |
|---|---|---|
| 1 | `POST /users` com dados válidos retorna 201 | `201` |
| 2 | `POST /users` sem e-mail retorna 400 | `400` |
| 3 | `GET /users/:id` com ID válido retorna 200 | `200` |
| 4 | `GET /users/:id` com ID inválido retorna 404 | `404` |

---

### DeckService — Testes Unitários

| # | Descrição | Tipo |
|---|---|---|
| 1 | Deve criar um baralho com sucesso | Unitário |
| 2 | Deve lançar `NotFoundError` ao criar baralho para usuário inexistente | Unitário |
| 3 | Deve retornar os baralhos de um usuário | Unitário |

### DeckController — Testes de Integração

| # | Descrição | Status Esperado |
|---|---|---|
| 1 | `POST /users/:userId/decks` com nome válido retorna 201 | `201` |
| 2 | `POST /users/:userId/decks` sem nome retorna 400 | `400` |
| 3 | `GET /users/:userId/decks` retorna array de baralhos | `200` |
| 4 | `POST` para usuário inexistente retorna 404 | `404` |

---

### CardService — Testes Unitários

| # | Descrição | Tipo |
|---|---|---|
| 1 | Deve criar card com valores SM-2 padrão (intervalo=0, acertos=0, erros=0) | Unitário |
| 2 | Deve lançar `NotFoundError` se o baralho não existir | Unitário |
| 3 | Deve lançar `BadRequestError` se frente ou verso estiver ausente | Unitário |

### CardController — Testes de Integração

| # | Descrição | Status Esperado |
|---|---|---|
| 1 | `POST /decks/:deckId/cards` com dados válidos retorna 201 | `201` |
| 2 | `POST` sem `verso` retorna 400 | `400` |
| 3 | `POST` para baralho inexistente retorna 404 | `404` |

---

### ReviewService — Testes Unitários (SM-2)

| # | Descrição | Tipo |
|---|---|---|
| 1 | Deve retornar os cards agendados para revisão | Unitário |
| 2 | Revisão com qualidade 5 (perfeita): incrementa acertos, aumenta intervalo e desempenho | Unitário |
| 3 | Revisão com qualidade 0 (blackout): reseta acertos, intervalo volta a 1, desempenho diminui | Unitário |
| 4 | Deve lançar `BadRequestError` para qualidade fora de [0–5] | Unitário |
| 5 | Deve lançar `NotFoundError` se o card não existir | Unitário |

### ReviewController — Testes de Integração

| # | Descrição | Status Esperado |
|---|---|---|
| 1 | `GET /decks/:deckId/revisao` retorna cards pendentes | `200` |
| 2 | `POST /cards/:cardId/revisao` com qualidade válida retorna card atualizado | `200` |
| 3 | `POST` com qualidade 9 (inválida) retorna 400 | `400` |
| 4 | `POST` para card inexistente retorna 404 | `404` |
