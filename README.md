# PiramidGame IFPR-Pgua

Aplicativo Flutter para Android e iOS, conforme a especificação com Firebase e
Firestore em `docs/`. A aplicação usa Firebase Authentication para contas e sessão,
Firestore para pessoas e avaliações e SharedPreferences somente para a preferência
de tema. O projeto Firebase informado é `piramidgame-ifpr` (`576112285706`).

## Funcionamento

- Crie uma conta com e-mail e senha ou entre com Google. A autenticação é restaurada
  ao reabrir o aplicativo; logout encerra a sessão Firebase.
- Conta de acesso e pessoa avaliada são registros distintos. Cadastrar uma pessoa
  não cria uma conta, e pessoas sem conta podem ser avaliadas.
- Cadastre nome, apelido opcional, curso, turma/ano entre 1998 e 2026 e nascimento.
  Somente o criador pode editar ou remover esse cadastro, com confirmação na remoção.
- Use **Este é meu perfil** no formulário ou **Este sou eu** nos detalhes para vincular
  sua conta a uma pessoa existente. O vínculo é único e impede a autoavaliação.
  Se já havia uma avaliação sua dessa pessoa, ela é removida na mesma transação.
- Cada conta tem uma avaliação por pessoa, com 15 notas inteiras de 1 a 5. Avaliar
  novamente atualiza as notas, sem adicionar votos. A soma e a data do servidor são
  gravadas junto dos identificadores do avaliador e da pessoa.
- **Ranking Pessoal:** somente as avaliações realizadas pela conta atual, por soma
  decrescente de 15 a 75 pontos.
- **Ranking Global:** média das somas recebidas de todas as contas, por ordem
  decrescente, com quantidade de avaliações. Empates usam o nome; pessoas ainda sem
  avaliações ficam sem pontuação. Detalhes mostram também a média de cada critério.
- Remover uma pessoa não exclui sua conta Firebase. Avaliações históricas de pessoas
  removidas permanecem no Firestore, mas não participam dos rankings nem das listas.

A associação **Este sou eu** é uma declaração do usuário; a especificação não define
um processo externo de verificação de identidade ou deduplicação de pessoas.

## Configuração Android e iOS

A configuração do projeto Firebase precisa conter os aplicativos das duas plataformas.
O ID do projeto e seu número, isoladamente, não fornecem os IDs dos aplicativos.

1. No Firebase, habilite Authentication com **E-mail/senha** e **Google** e crie um
   banco **Cloud Firestore**.
2. Configure os aplicativos utilizando a [CLI FlutterFire](https://firebase.google.com/docs/flutter/setup):

   ```sh
   flutterfire configure --project=piramidgame-ifpr --platforms=android,ios
   ```

   O comando gera `lib/firebase_options.dart` com os valores reais e configura os
   arquivos nativos. Os identificadores atuais do repositório são:
   Android `com.example.piramid_game`; iOS `com.example.piramidGame`.
3. No Android, registre as impressões SHA das chaves de assinatura para o
   [login Google](https://firebase.google.com/docs/auth/flutter/federated-auth).
   Utilize `android/app/google-services.json` atualizado, incluindo o cliente OAuth.
   O plugin Google Services é aplicado quando esse arquivo existe.
4. No iOS, utilize `GoogleService-Info.plist` do aplicativo correto. Copie
   `ios/Flutter/Firebase.xcconfig.example` para `ios/Flutter/Firebase.xcconfig` e
   preencha `GOOGLE_REVERSED_CLIENT_ID` com o `REVERSED_CLIENT_ID` real para o retorno
   do login Google. Os arquivos Debug e Release incluem essa configuração.
5. Publique as regras antes de usar dados reais:

   ```sh
   firebase deploy --only firestore:rules,firestore:indexes --project piramidgame-ifpr
   ```

   Essa publicação altera o projeto remoto e deve ser realizada com acesso autorizado.

Os SDKs selecionados exigem Android API 24 ou superior e iOS 15 ou superior.
O arquivo de opções também aceita `--dart-define-from-file` com `FIREBASE_API_KEY`,
`FIREBASE_ANDROID_APP_ID`, `FIREBASE_IOS_APP_ID`, `FIREBASE_PROJECT_ID` e
`FIREBASE_MESSAGING_SENDER_ID`; `GOOGLE_IOS_CLIENT_ID` e `GOOGLE_WEB_CLIENT_ID` podem
ser passados para o login Google. Sem defines, usa os arquivos nativos. A configuração
nativa do callback Google no iOS continua necessária.

## Dados e segurança

Coleções: `usuarios/{uid}`, `pessoas/{pessoaId}` e
`avaliacoes/{avaliadorUid}_{pessoaId}`. O ID determinístico garante um voto por par.
As regras validam sessão, criador, vínculo recíproco, ausência de autoavaliação,
15 notas inteiras de 1 a 5, soma correta e data do servidor. O cliente não pode
alterar uma avaliação de outra conta nem gravar senhas na coleção de usuários.

Os rankings são calculados a partir das avaliações do Firestore ao carregar ou
atualizar as listas. A implementação evita manter totais globais editáveis pelo
cliente; a leitura integral atende ao escopo didático e poderá precisar de agregação
no servidor se a base crescer.

Os serviços antigos de SQLite e SharedPreferences de alunos permanecem inativos,
para evitar reescrever código fora do escopo. Não há importação automática das
contas ou notas locais antigas para a nuvem, e seus arquivos não são apagados.

## Executar e validar

```sh
flutter pub get
flutter devices
flutter run -d <id-do-dispositivo-android-ou-ios>
flutter analyze
```

No Linux, execute em um celular Android conectado com depuração USB ou em um
emulador Android. O plugin FlutterFire utilizado não oferece implementação Linux;
`flutter run -d linux` exibe uma mensagem de plataforma não suportada. Ao adicionar
plugins nativos, encerre a execução anterior e execute novamente para recompilar.

A arquitetura mantém services → repositories → use cases → facade → ViewModels
(estado, comandos e entrada principal) → UI, com Signals, Command, Result e go_router.
A definição visual dos temas fica em `lib/core/theme/app_theme.dart`.
Os testes de validação permanecem apenas locais em `test/`, conforme decisão do
projeto, cobrindo domínio, interface, sessão e regras do Firestore em emulador.
A validação de login real em Android/iOS depende da configuração nativa e dos
provedores habilitados no Firebase; os testes locais não substituem essa etapa.
