import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/information_content.dart';

class InformationSection extends StatelessWidget {
  const InformationSection({super.key, required this.page});
  final int page;
  @override
  Widget build(BuildContext context) {
    final articles = page == 2
        ? [...informationArticles.take(2), ...donorArticles]
        : [...informationArticles, ...donorArticles];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Қатысушыларға арналған ақпарат',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Қатысуға дайындық, ұйымдастырушымен байланысу және қосымшаны пайдалану туралы нұсқаулықтар.',
          style: TextStyle(color: muted, height: 1.6),
        ),
        const SizedBox(height: 20),
        for (final article in articles)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                key: PageStorageKey(article.title),
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    article.summary,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
                children: [
                  for (final section in article.sections) ...[
                    const SizedBox(height: 18),
                    Text(
                      section.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      section.$2,
                      style: const TextStyle(height: 1.75, fontSize: 14),
                    ),
                  ],
                  if (article.source != null) ...[
                    const Divider(height: 32),
                    const Text(
                      'Ақпарат көзі',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      article.source!,
                      key: PageStorageKey('source-' + article.title),
                      style: const TextStyle(
                        fontSize: 12,
                        color: muted,
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
