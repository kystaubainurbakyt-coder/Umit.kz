import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../state/app_store.dart';
import '../../models/models.dart';
import '../../widgets/brand.dart';
import '../../widgets/donor_guide.dart';
import '../auth/auth_screen.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/event_list.dart';
import '../../widgets/home_hero.dart';
import '../../widgets/information_section.dart';
import '../../widgets/member_progress.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialPage = 0});
  final int initialPage;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int page = widget.initialPage;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool menuOpen = true;
  Set<int> get joinedEvents => store.joinedEvents;
  List<CharityEvent> get events => store.events;
  String get currentName => store.currentName;
  String get currentEmail => store.currentEmail;
  String city = 'Барлық қалалар';
  bool newestFirst = false;
  Color get surface => Theme.of(context).colorScheme.surface;
  Color get outline => Theme.of(context).colorScheme.outlineVariant;

  String category = 'Барлығы', query = '';
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void changePage(int index) {
    if (index == 3 && !store.signedIn) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const AuthScreen(destinationPage: 3),
        ),
      );
      return;
    }
    setState(() {
      page = index;
      category = 'Барлығы';
      city = 'Барлық қалалар';
      newestFirst = false;
      query = '';
      search.clear();
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => page == 3 && !store.signedIn
        ? const AuthScreen(destinationPage: 3)
        : LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 950;
              return Scaffold(
                key: scaffoldKey,
                drawer: wide
                    ? null
                    : Drawer(
                        child: AppNavigation(
                          page: page,
                          onNavigate: changePage,
                          onClose: () =>
                              scaffoldKey.currentState?.closeDrawer(),
                          drawer: true,
                        ),
                      ),
                bottomNavigationBar: wide
                    ? null
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: NavigationBar(
                            selectedIndex: page,
                            onDestinationSelected: changePage,
                            destinations: const [
                              NavigationDestination(
                                icon: Icon(Icons.grid_view_rounded),
                                label: 'Басты бет',
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.event_outlined),
                                label: 'Шаралар',
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.bloodtype_outlined),
                                label: 'Донорлық',
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.person_outline),
                                label: 'Кабинет',
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.bookmark_outline),
                                label: 'Сақталған',
                              ),
                            ],
                          ),
                        ),
                      ),
                body: SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (wide)
                        AnimatedContainer(
                          key: const ValueKey('desktop-menu'),
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeInOutCubic,
                          width: menuOpen ? 260 : 0,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(),
                          child: OverflowBox(
                            alignment: Alignment.topLeft,
                            minWidth: 260,
                            maxWidth: 260,
                            child: ExcludeFocus(
                              excluding: !menuOpen,
                              child: ExcludeSemantics(
                                excluding: !menuOpen,
                                child: AppNavigation(
                                  page: page,
                                  onNavigate: changePage,
                                  onClose: () =>
                                      setState(() => menuOpen = false),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              color: surface,
                              padding: EdgeInsets.symmetric(
                                horizontal: wide ? 36 : 18,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    key: const ValueKey('toggle-menu'),
                                    tooltip: 'Мәзірді ашу / жабу',
                                    onPressed: () {
                                      if (wide) {
                                        setState(() => menuOpen = !menuOpen);
                                      } else {
                                        scaffoldKey.currentState?.openDrawer();
                                      }
                                    },
                                    icon: const Icon(Icons.menu),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!wide)
                                    const Expanded(child: Brand())
                                  else
                                    Expanded(
                                      child: Text(
                                        [
                                          'Басты бет',
                                          'Іс-шаралар тізімі',
                                          'Донорлық туралы',
                                          'Менің аккаунтым',
                                          'Сақталған шаралар',
                                        ][page],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    tooltip: 'Жеке кабинет',
                                    onPressed: () => changePage(3),
                                    icon: const CircleAvatar(
                                      backgroundColor: Color(0xFFF3E9EA),
                                      child: Icon(
                                        Icons.person_outline,
                                        color: red,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Аккаунттан шығу',
                                    onPressed: () {
                                      store.logout();
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute<void>(
                                          builder: (_) => const AuthScreen(),
                                        ),
                                        (_) => false,
                                      );
                                    },
                                    icon: const Icon(Icons.logout, size: 20),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: wide ? 34 : 18,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1180,
                                    ),
                                    child: ListView(
                                      key: ValueKey('home-content-$page'),
                                      padding: EdgeInsets.symmetric(
                                        vertical: wide ? 34 : 18,
                                      ),
                                      children: [
                                        if (page == 0) ...[
                                          HomeHero(
                                            currentName: currentName,
                                            onNavigate: changePage,
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              for (final stat in [
                                                (
                                                  Icons
                                                      .event_available_outlined,
                                                  '${events.length}',
                                                  'Үлгі шара',
                                                ),
                                                (
                                                  Icons.favorite_outline,
                                                  '${joinedEvents.length}',
                                                  'Қатысу',
                                                ),
                                                (
                                                  Icons.people_outline,
                                                  '3',
                                                  'Бағыттар',
                                                ),
                                              ])
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                        ),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          stat.$2,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                fontSize: 24,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          stat.$3,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color: muted,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 30),
                                        ],
                                        if (page == 2) const DonorGuide(),
                                        if (store.storageError != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            child: Text(
                                              store.storageError!,
                                              style: const TextStyle(
                                                color: red,
                                              ),
                                            ),
                                          ),
                                        if (page == 3) ...[
                                          const MemberProgress(),
                                          const SizedBox(height: 18),
                                          panel(
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: Color(
                                                    0xFFF3E9EA,
                                                  ),
                                                  child: Icon(
                                                    Icons.person,
                                                    color: red,
                                                    size: 32,
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        currentName,
                                                        style: const TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        currentEmail.isEmpty
                                                            ? 'Қонақ режимі'
                                                            : currentEmail,
                                                        style: const TextStyle(
                                                          color: muted,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 28),
                                        ],
                                        Text(
                                          page == 4
                                              ? 'Сақталған шаралар'
                                              : page == 3
                                              ? 'Менің іс-шараларым'
                                              : page == 2
                                              ? 'Донорлық шаралар'
                                              : page == 1
                                              ? 'Барлық іс-шаралар'
                                              : 'Алдағы шаралар',
                                          style: const TextStyle(
                                            fontSize: 23,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          page == 3
                                              ? 'Қатысу белгіленген шаралар. Таңдауды өзгерту үшін шараны ашыңыз.'
                                              : page == 4
                                              ? 'Кейін қарау үшін сақталған шаралар. Сақтау қатысуды білдірмейді.'
                                              : 'Шараның сипаттамасын, өтетін орны мен уақытын қараңыз.',
                                          style: const TextStyle(
                                            color: muted,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        if (page == 0 ||
                                            page == 1 ||
                                            page == 4) ...[
                                          TextField(
                                            controller: search,
                                            onChanged: (v) =>
                                                setState(() => query = v),
                                            decoration: const InputDecoration(
                                              hintText: 'Шара немесе қала бойынша іздеу',
                                              prefixIcon: Icon(Icons.search),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              for (final label in [
                                                'Барлығы',
                                                'Донорлық',
                                                'Еріктілік',
                                                'Қайырымдылық',
                                              ])
                                                ChoiceChip(
                                                  label: Text(label),
                                                  selected: category == label,
                                                  onSelected: (_) => setState(
                                                    () => category = label,
                                                  ),
                                                  selectedColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                  side: BorderSide.none,
                                                  showCheckmark: false,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                        if (page == 0 ||
                                            page == 1 ||
                                            page == 4) ...[
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 10,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              DropdownButton<String>(
                                                value: city,
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                items:
                                                    [
                                                          'Барлық қалалар',
                                                          'Алматы',
                                                          'Астана',
                                                          'Шымкент',
                                                        ]
                                                        .map(
                                                          (value) =>
                                                              DropdownMenuItem(
                                                                value: value,
                                                                child: Text(
                                                                  value,
                                                                ),
                                                              ),
                                                        )
                                                        .toList(),
                                                onChanged: (value) => setState(
                                                  () => city = value!,
                                                ),
                                              ),
                                              FilterChip(
                                                label: const Text(
                                                  'Күні бойынша: кему реті',
                                                ),
                                                selected: newestFirst,
                                                onSelected: (value) => setState(
                                                  () => newestFirst = value,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                        if (page == 3 &&
                                            joinedEvents.isNotEmpty) ...[
                                          Text(
                                            'Қатысатын шаралар: ${joinedEvents.length}',
                                            style: const TextStyle(
                                              color: red,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                        EventList(
                                          page: page,
                                          city: city,
                                          category: category,
                                          query: query,
                                          newestFirst: newestFirst,
                                          onNavigate: changePage,
                                        ),
                                        const SizedBox(height: 30),
                                        if (page == 0 ||
                                            page == 1 ||
                                            page == 2) ...[
                                          InformationSection(page: page),
                                          const SizedBox(height: 30),
                                        ],
                                        const Text(
                                          'ÜMIT — донорлық және қайырымдылық.\nДемонстрациялық нұсқа. Тізімде үлгі іс-шаралар берілген.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: muted,
                                            height: 1.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
  );
  Widget panel(Widget child) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: outline),
    ),
    child: child,
  );
}
