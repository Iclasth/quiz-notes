# Especificações do Projeto: Quiz Notes

## Visão Geral
* **Nome do Sistema:** O projeto é denominado Quiz Notes.
* **Público-Alvo:** A aplicação é destinada a estudantes e professores.
* **Plataforma:** O sistema é uma aplicação mobile focada primariamente na plataforma Android.
* **Objetivo Principal:** O objetivo é facilitar o processo de aprendizagem e revisão através da criação de flashcards em formato de pequenos quizzes de frente e verso.

## Arquitetura e Tecnologias
* **Padrão Arquitetural:** O sistema utiliza o padrão arquitetural MVC (Model-View-Controller) para garantir a separação de responsabilidades.
* **Frontend Mobile:** O desenvolvimento da interface e do aplicativo é feito utilizando o framework multiplataforma Flutter.
* **Backend e Banco de Dados:** O projeto utiliza o Supabase como Backend as a Service (BaaS), suportado por um banco de dados relacional PostgreSQL.
* **Armazenamento de Mídias:** A gestão de arquivos e mídias é realizada através do Supabase Storage.
* **API:** Existe uma API intermediária desenvolvida em Node.js com o framework Express, que atua como um gateway de segurança para o aplicativo.
* **Versionamento:** O código-fonte é versionado usando Git e armazenado no GitHub, seguindo o fluxo de trabalho GitFlow.

## Requisitos Funcionais (RF)
* **RF01 - Gerenciamento de Baralhos:** O sistema deve permitir que o usuário crie, modifique, liste e delete baralhos para a organização de seus estudos.
* **RF02 - Gerenciamento de Cards:** O usuário deve ser capaz de adicionar, modificar e deletar cards de frente e verso dentro de um baralho específico.
* **RF03 - Revisão Espaçada:** O sistema deve incorporar um algoritmo que calcule e apresente os cards em intervalos de tempo baseados na performance anterior do estudante.
* **RF04 - Revisão Livre:** Deve ser possível realizar revisões de um baralho a qualquer momento de forma livre, ignorando o algoritmo de repetição espaçada.
* **RF05 - Relatório de Desempenho:** O aplicativo deve calcular e mostrar o desempenho do usuário com base no histórico de revisões dos cartões.

## Requisitos Não Funcionais (RNF)
* **RNF01 - Usabilidade:** A interface deve ser de fácil navegação e intuitiva para que possa ser utilizada sem a necessidade de treinamento.
* **RNF02 - Segurança:** O sistema precisa assegurar a persistência e a integridade dos dados de maneira segura.
* **RNF03 - Performance:** O aplicativo deve garantir baixo consumo de bateria e memória, além de apresentar respostas rápidas em dispositivos de entrada.
* **RNF04 - Compatibilidade:** A aplicação precisa ser otimizada prioritariamente para o sistema operacional Android.

## Modelagem de Dados
* **Entidade Usuário:** Responsável por manter as credenciais e informações do perfil, possuindo os campos `id_usuario`, `nome`, `email` e `senha`.
* **Entidade Baralho:** Agrupamento temático de cards vinculado ao usuário, composto pelos atributos `id_baralho`, `nome` e `id_usuario`.
* **Entidade Card:** Estrutura fundamental do flashcard contendo os campos `id`, `frente`, `verso`, `desempenho` e `id_baralho`.
* **Relacionamentos:**
  * Um usuário pode possuir múltiplos baralhos (relação 1:N).
  * Cada baralho é capaz de agrupar múltiplos cards (relação 1:N).
  * Um card gera diversas entradas de histórico à medida que é revisado pelo algoritmo (relação 1:N).

## Segurança da Informação
* **Autenticação:** O controle de acesso e autenticação dos estudantes é feito por meio do Supabase Auth utilizando o padrão de tokens JWT (JSON Web Token).
* **Validação:** A API em Node.js intercepta as requisições mobile para validar os tokens JWT e possui middlewares dedicados à sanitização de entradas.
* **Segurança de Banco de Dados:** O acesso direto aos dados é restringido pelo uso das políticas de Row Level Security (RLS) oferecidas pelo Supabase.
* **Criptografia:** Todas as comunicações do sistema ocorrem sob a proteção do protocolo HTTPS para garantir a segurança dos dados em trânsito.