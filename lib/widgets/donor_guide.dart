import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/information_content.dart';

class DonorGuide extends StatelessWidget {
  const DonorGuide({super.key});
  Widget panel(BuildContext context, Widget child) => Card(child: Padding(padding: const EdgeInsets.all(22), child: child));
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                                    const Text(
                                      'Донорлыққа қатысу тәртібі',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Бұл бөлімде донорлық шараны таңдау және қатысуды жоспарлау тәртібі берілген. Қан тапсыруға қатысты жеке сұрақтарды қан орталығының маманына жолдаңыз.',
                                      style: TextStyle(
                                        color: muted,
                                        height: 1.6,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    for (final step in donorParticipationSteps)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 14,
                                        ),
                                        child: panel(context, 
                                          Row(
                                            children: [
                                              Text(
                                                step.$1,
                                                style: const TextStyle(
                                                  color: red,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 26,
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      step.$2,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      step.$3,
                                                      style: const TextStyle(
                                                        color: muted,
                                                        height: 1.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    panel(context, 
                                      const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ресми ақпарат',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Қатысу кезеңдері Республикалық қан орталығының донорларға арналған материалдары бойынша жинақталды. Қабылдау тәртібі мен жеке медициналық талаптарды таңдаған орталықтан нақтылаңыз.',
                                            style: TextStyle(height: 1.6),
                                          ),
                                          SizedBox(height: 12),
                                          SelectableText(
                                            'rck.kz — Республикалық қан орталығы\nАқпарат тексерілген күн: 02.10.2026',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: muted,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                  ]);
}
