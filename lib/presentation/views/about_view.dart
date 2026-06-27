import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho / Hero Card
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'PiramidGame IFPR-Pgua',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'O Ranking de Popularidade dos Alunos é um aplicativo desenvolvido em Flutter para fins didáticos no IFPR – Campus Paranaguá.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // A Lenda / História do App
            Text(
              'A Origem da Resenha',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tudo começou quando Coquinha percebeu que o campus andava meio anêmico e resolveu deixar sua marca histórica. Em conversas com Yumi, surgiu a ideia de ranquear os alunos por carisma, resenha e caos. Com o aval técnico de Matheus Grêmio (INFO23) e Matheus (INFO24), a consultoria de Sofia, Ana Júlia, Bárbara, Pedro Rodrigo e Lussani, além dos palpites essenciais (ou nem tanto) do Monão, as sugestões de bastidores de Bizzon, Rúbia e a campanha do Luizinho, nasceu o projeto ideal para agitar os corredores!',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),

            // Como Funciona / Regras
            Text(
              'Como Funciona?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildRuleItem(
              context,
              Icons.star_rounded,
              'Avaliação em Estrelas',
              'Cada estudante cadastrado é avaliado em exatamente 15 critérios comportamentais descontraídos, recebendo notas de 1 a 5 estrelas em cada.',
            ),
            _buildRuleItem(
              context,
              Icons.looks_one_rounded,
              'Cálculo do Nível Lenda',
              'A soma total das estrelas resulta no Nível Lenda do aluno (mínimo de 15 e máximo de 75 pontos), servindo como score no ranking.',
            ),
            _buildRuleItem(
              context,
              Icons.storage_rounded,
              'Armazenamento Local',
              'Todos os dados são persistidos de maneira 100% local no dispositivo usando SharedPreferences serializado em formato JSON.',
            ),
            _buildRuleItem(
              context,
              Icons.palette_rounded,
              'Temas Dinâmicos',
              'Permite alternar entre os temas claro e escuro a qualquer momento no cabeçalho da tela principal.',
            ),
            const SizedBox(height: 32),

            // Rodapé Acadêmico
            Center(
              child: Column(
                children: [
                  Text(
                    'TADS - Dispositivos Móveis',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    'IFPR Campus Paranaguá - 2026',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
