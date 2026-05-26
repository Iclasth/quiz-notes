# Quiz Notes

Aplicativo de revisão espaçada (Flashcards) integrado com backend em Node.js/TypeScript e banco de dados relacional.

---

## Como Rodar o Projeto

O projeto é composto por duas partes: o **Backend (API)** e o **Frontend (App Flutter)**.

---

### 1. Backend (API)

A API gerencia os usuários, baralhos, cartões e o histórico de revisões com o algoritmo SM-2.

#### Pré-requisitos
* Node.js (v16 ou superior)
* npm ou yarn

#### Passos para rodar
1. Acesse o diretório da API:
   ```bash
   cd api
   ```
2. Instale as dependências:
   ```bash
   npm install
   ```
3. Configure o arquivo `.env` com as credenciais do banco de dados (se houver).
4. Inicie o servidor em modo de desenvolvimento:
   ```bash
   npm run dev
   ```
   *A API estará disponível por padrão em `http://localhost:3000/api`.*

#### Executar testes (Jest)
```bash
npm test
```

---

### 2. Frontend (App Flutter)

O aplicativo móvel desenvolvido em Flutter consome a API do backend.

#### Pré-requisitos
* Flutter SDK (instalado e configurado no PATH)
* Um emulador ou dispositivo físico conectado

#### Passos para rodar
1. Acesse o diretório do app:
   ```bash
   cd quiz_notes
   ```
2. Restaure as dependências do pub:
   ```bash
   flutter pub get
   ```
3. Execute o aplicativo:
   ```bash
   flutter run
   ```

#### Executar testes e análise estática
```bash
flutter analyze
flutter test
```
