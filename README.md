# PiramidGame IFPR-Pgua

Aplicativo Flutter de cadastro e ranking de usuários do IFPR – Campus Paranaguá.
As contas, os perfis e as avaliações são locais, armazenados em SQLite no mesmo
aparelho. Não há servidor ou sincronização entre dispositivos.

## Contas e participação

- Crie uma conta com nome, apelido opcional, curso, turma/ano, nascimento, e-mail
  e senha de 8 a 128 caracteres. O e-mail é único, sem distinção de maiúsculas.
- O cadastro cria seu perfil e inicia uma sessão. Após sair ou reiniciar o app,
  é necessário fazer login novamente.
- O ranking, a edição do perfil e as avaliações exigem uma sessão autenticada.
  Splash, login, cadastro e informações sobre o app são públicos.
- Você pode editar e excluir somente seu próprio perfil. A exclusão da conta
  pede confirmação e remove também as avaliações feitas e recebidas.
- Você pode avaliar outras contas em 15 critérios, de 1 a 5 estrelas, mas nunca
  avaliar a si mesmo. Essa restrição existe no domínio e no SQLite.
- Cada par avaliador/avaliado tem uma única avaliação. Ao avaliar novamente,
  as notas anteriores são atualizadas, sem votos adicionais.

## Ranking

Cada avaliação totaliza de 15 a 75 pontos. O Nível Lenda de um perfil é a média
aritmética dos totais recebidos. Os detalhes mostram também a média de cada
critério e a quantidade de avaliações recebidas. O ranking é decrescente por
pontuação; empates são ordenados por nome. Quem ainda não recebeu avaliações
fica sem pontuação, ao final da lista.

## Persistência e segurança

O banco `piramid_game.db` usa a versão 3. A migração preserva a tabela de alunos
existente e adiciona contas e avaliações com chaves estrangeiras e restrições.
Perfis antigos permanecem no banco, mas não viram contas automaticamente porque
não possuem credenciais. Apenas perfis vinculados a contas participam do novo
ranking; as antigas notas não são convertidas em votos atribuídos a usuários.

As senhas não são gravadas em texto puro: usa-se PBKDF2-HMAC-SHA256 com 600.000
iterações, salt aleatório individual de 32 bytes e derivação em um isolate para
não bloquear a interface. A sessão fica somente em memória. A autenticação local
não substitui um servidor caso o projeto passe a precisar de contas compartilhadas
entre aparelhos.

O fluxo ativo segue services → repositories → use cases → facade → ViewModels
(estado, comandos e entrada principal) → UI, com Signals, Command, Result e
go_router. Os arquivos do fluxo antigo de alunos permanecem como código legado,
mas não estão registrados na injeção de dependências nem nas telas atuais.

## Executar e validar

```sh
flutter pub get
flutter run
flutter analyze
```
