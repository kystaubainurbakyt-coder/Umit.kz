import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../data/local_database.dart';
import '../data/seed_events.dart';

final store = AppStore();

/// Local prototype repository. Roles are checked here as well as in screens.
/// This is not a replacement for server-side authentication/authorization.
class AppStore extends ChangeNotifier {
  AppStore({LocalDatabase? database})
    : _database = database ?? LocalDatabase() {
    _seed();
  }
  static const adminEmail = 'admin@umit.kz';
  static const adminPassword = 'UmitAdmin2026!';
  static const storageKey = 'umit_local_v1';
  final Map<String, Account> _accounts = {};
  final List<CharityEvent> _events = [];
  final List<Participation> _requests = [];
  final List<MemberNotice> _notices = [];
  final Map<String, Set<int>> _saved = {};
  String? _email;
  int _nextRequest = 1, _nextNotice = 1;
  final LocalDatabase _database;
  bool _storageReady = false;
  Future<void> _writeQueue = Future.value();
  String? storageError;
  String get currentEmail => _email ?? '';
  String get currentName => account?.name ?? 'Қонақ';
  Account? get account => _accounts[_email];
  bool get isAdmin =>
      account?.role == UserRole.admin && account?.blocked == false;
  bool get signedIn => account != null && !account!.blocked;
  List<Account> get users {
    _requireAdmin();
    return List.unmodifiable(_accounts.values);
  }

  List<CharityEvent> get events =>
      List.unmodifiable(_events.where((e) => e.published));
  List<CharityEvent> get allEvents {
    _requireAdmin();
    return List.unmodifiable(_events);
  }

  List<Participation> get requests {
    _requireAdmin();
    return List.unmodifiable(_requests);
  }

  List<Participation> get myRequests =>
      List.unmodifiable(_requests.where((r) => r.email == _email));
  List<MemberNotice> get notices => List.unmodifiable(
    _notices.where((n) => n.email == _email).toList().reversed,
  );
  Set<int> get joinedEvents => myRequests
      .where(
        (r) =>
            r.status != RequestStatus.cancelled &&
            r.status != RequestStatus.rejected,
      )
      .map((r) => r.eventId)
      .toSet();
  Set<int> get savedEvents => Set.unmodifiable(_saved[currentEmail] ?? {});
  CharityEvent? eventById(int id) {
    for (final e in _events) {
      if (e.id == id) return e;
    }
    return null;
  }

  Participation? requestFor(int id) {
    for (final r in _requests.reversed) {
      if (r.email == _email && r.eventId == id) return r;
    }
    return null;
  }

  String memberName(String email) {
    _requireAdmin();
    return _accounts[email]?.name ?? email;
  }

  void _requireAdmin() {
    if (!isAdmin) throw StateError('Бұл әрекет тек әкімшіге қолжетімді.');
  }

  void _requireMember() {
    if (!signedIn)
      throw StateError('Өтінім жіберу үшін аккаунтыңызға кіріңіз.');
  }

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
  Account _newAccount(
    String name,
    String email,
    String password, {
    UserRole role = UserRole.member,
  }) {
    final random = Random.secure();
    final salt = base64Encode(List.generate(24, (_) => random.nextInt(256)));
    return Account(
      name: name,
      email: email,
      salt: salt,
      passwordHash: _hash(password, salt),
      role: role,
    );
  }

  void _seed() {
    _accounts[adminEmail] = _newAccount(
      'ÜMIT әкімшісі',
      adminEmail,
      adminPassword,
      role: UserRole.admin,
    );
    _events.addAll(seedEvents);
  }

  Future<void> initialize() async {
    try {
      await _database.open();
      var j = await _database.load();
      SharedPreferences? legacy;
      if (j == null) {
        legacy = await SharedPreferences.getInstance();
        final raw = legacy.getString(storageKey);
        j = raw == null ? _snapshot() : jsonDecode(raw) as Map<String, dynamic>;
      }
      final accounts = (j['accounts'] as List)
          .map((e) => Account.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final events = (j['events'] as List)
          .map((e) => CharityEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final requests = (j['requests'] as List)
          .map((e) => Participation.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final notices = (j['notices'] as List)
          .map((e) => MemberNotice.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final saved = (j['saved'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as List).cast<int>().toSet()),
      );
      if (!accounts.any((a) => a.role == UserRole.admin && !a.blocked))
        throw const FormatException('Missing admin');
      _accounts
        ..clear()
        ..addEntries(accounts.map((a) => MapEntry(a.email, a)));
      _events
        ..clear()
        ..addAll(events);
      _requests
        ..clear()
        ..addAll(requests);
      _notices
        ..clear()
        ..addAll(notices);
      _saved
        ..clear()
        ..addAll(saved);
      _nextRequest = j['nextRequest'];
      _nextNotice = j['nextNotice'];
      await _database.save(_snapshot());
      _storageReady = true;
      if (legacy != null) await legacy.remove(storageKey);
    } catch (_) {
      storageError = 'Жергілікті деректерді оқу мүмкін болмады. Сақтау бұғатталды; қолданбаны қайта іске қосып көріңіз.';
    }
    notifyListeners();
  }

  Future<void> flush() => _writeQueue;
  Future<void> closeStorage() async {
    await flush();
    await _database.close();
    _storageReady = false;
  }

  Future<Map<String, dynamic>> databaseSnapshot() async {
    _requireAdmin();
    await flush();
    _requireAdmin();
    if (!_storageReady || storageError != null) {
      throw StateError(storageError ?? 'Database is not initialized');
    }
    final snapshot = await _database.inspectTables();
    _requireAdmin();
    return snapshot;
  }

  Future<Uint8List> exportDatabase() async {
    _requireAdmin();
    await flush();
    _requireAdmin();
    if (!_storageReady || storageError != null) {
      throw StateError(storageError ?? 'Database is not initialized');
    }
    final bytes = await _database.exportBytes();
    _requireAdmin();
    return bytes;
  }

  Map<String, dynamic> _snapshot() => {
    'accounts': _accounts.values.map((a) => a.toJson()).toList(),
    'events': _events.map((e) => e.toJson()).toList(),
    'requests': _requests.map((r) => r.toJson()).toList(),
    'notices': _notices.map((n) => n.toJson()).toList(),
    'saved': _saved.map((k, v) => MapEntry(k, v.toList())),
    'nextRequest': _nextRequest,
    'nextNotice': _nextNotice,
  };

  void _changed() {
    notifyListeners();
    if (!_storageReady || storageError != null) return;
    final data = _snapshot();
    _writeQueue = _writeQueue
        .then((_) async {
          await _database.save(data);
        })
        .catchError((Object _) {
          storageError =
              'Өзгерістер құрылғыға сақталмады. Бос орынды тексеріңіз.';
          notifyListeners();
        });
  }

  String? register(String name, String email, String password) {
    email = email.trim().toLowerCase();
    if (name.trim().isEmpty ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) ||
        password.length < 6)
      return 'Тіркелу деректерін тексеріңіз.';
    if (_accounts.containsKey(email)) return 'Бұл электрондық пошта тіркелген.';
    _accounts[email] = _newAccount(name.trim(), email, password);
    _changed();
    return null;
  }

  String? login(String email, String password) {
    email = email.trim().toLowerCase();
    final a = _accounts[email];
    if (a == null || a.passwordHash != _hash(password, a.salt))
      return 'Электрондық пошта немесе құпиясөз қате.';
    if (a.blocked) return 'Аккаунт бұғатталған. Әкімшіге хабарласыңыз.';
    _email = email;
    notifyListeners();
    return null;
  }

  void logout() {
    _email = null;
    _saved.remove('');
    notifyListeners();
  }

  void toggleSaved(int id) {
    if (eventById(id) == null) return;
    final ids = _saved.putIfAbsent(currentEmail, () => {});
    if (!ids.add(id)) ids.remove(id);
    _changed();
  }

  int occupied(int id) => _requests
      .where(
        (r) =>
            r.eventId == id &&
            (r.status == RequestStatus.approved ||
                r.status == RequestStatus.completed),
      )
      .length;
  void apply(int id) {
    _requireMember();
    final e = eventById(id);
    if (e == null || !e.published) throw StateError('Шара қолжетімсіз.');
    final old = requestFor(id);
    if (old != null &&
        ![RequestStatus.cancelled, RequestStatus.rejected].contains(old.status))
      throw StateError('Өтінім бұрын жіберілген.');
    if (occupied(id) >= e.capacity) throw StateError('Бос орын жоқ.');
    _requests.add(
      Participation(
        id: _nextRequest++,
        email: currentEmail,
        eventId: id,
        status: RequestStatus.pending,
      ),
    );
    _notify(currentEmail, '«${e.title}» шарасына өтінім жіберілді.');
    _changed();
  }

  void cancel(int requestId) {
    _requireMember();
    final index = _requests.indexWhere(
      (r) => r.id == requestId && r.email == currentEmail,
    );
    if (index < 0) throw StateError('Өтінім табылмады.');
    final r = _requests[index];
    if (![RequestStatus.pending, RequestStatus.approved].contains(r.status))
      throw StateError('Бұл мәртебені өзгерту мүмкін емес.');
    _requests[index] = r.change(
      RequestStatus.cancelled,
      'Қатысушы бас тартты.',
    );
    _changed();
  }

  void review(int id, RequestStatus next, String note) {
    _requireAdmin();
    final index = _requests.indexWhere((r) => r.id == id);
    if (index < 0) throw StateError('Өтінім табылмады.');
    final r = _requests[index];
    final e = eventById(r.eventId);
    final allowed = r.status == RequestStatus.pending
        ? [RequestStatus.approved, RequestStatus.rejected]
        : r.status == RequestStatus.approved
        ? [RequestStatus.completed, RequestStatus.rejected]
        : <RequestStatus>[];
    if (!allowed.contains(next))
      throw StateError('Мәртебе ауысуына рұқсат жоқ.');
    if (next == RequestStatus.rejected && note.trim().isEmpty)
      throw StateError('Бас тарту себебін жазыңыз.');
    if (next == RequestStatus.approved &&
        (e == null ||
            !e.published ||
            occupied(e.id) >= e.capacity ||
            _accounts[r.email]?.blocked == true))
      throw StateError('Шара жабық, орын жоқ немесе аккаунт бұғатталған.');
    _requests[index] = r.change(next, note.trim());
    _notify(r.email, '«${e?.title ?? 'Шара'}»: ${next.label}. ${note.trim()}');
    _changed();
  }

  void saveEvent(CharityEvent event) {
    _requireAdmin();
    if (event.title.trim().isEmpty ||
        event.location.trim().isEmpty ||
        event.description.trim().isEmpty ||
        event.capacity < 1)
      throw StateError('Шараның міндетті өрістерін толтырыңыз.');
    if (event.capacity < occupied(event.id))
      throw StateError(
        'Орын саны мақұлданған қатысушылардан аз болмауы керек.',
      );
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index < 0) {
      _events.add(event);
    } else {
      _events[index] = event;
      for (final r in _requests.where(
        (r) =>
            r.eventId == event.id &&
            [RequestStatus.pending, RequestStatus.approved].contains(r.status),
      )) {
        _notify(
          r.email,
          '«${event.title}» шарасының ақпараты жаңартылды. Уақыты мен орнын тексеріңіз.',
        );
      }
    }
    _changed();
  }

  int get nextEventId => _events.fold(0, (int v, e) => max(v, e.id)) + 1;
  void deleteEvent(int id) {
    _requireAdmin();
    if (_requests.any((r) => r.eventId == id))
      throw StateError(
        'Өтінімі бар шараны өшіруге болмайды. Жариялаудан алыңыз.',
      );
    _events.removeWhere((e) => e.id == id);
    for (final ids in _saved.values) {
      ids.remove(id);
    }
    _changed();
  }

  void setBlocked(String email, bool value) {
    _requireAdmin();
    final a = _accounts[email];
    if (a == null || a.role == UserRole.admin)
      throw StateError('Әкімші аккаунтын бұғаттау мүмкін емес.');
    _accounts[email] = a.withBlocked(value);
    _changed();
  }

  void announce(String text) {
    _requireAdmin();
    if (text.trim().isEmpty) throw StateError('Хабарлама мәтінін жазыңыз.');
    for (final a in _accounts.values.where(
      (a) => a.role == UserRole.member && !a.blocked,
    )) {
      _notify(a.email, text.trim());
    }
    _changed();
  }

  void _notify(String email, String text) =>
      _notices.add(MemberNotice(_nextNotice++, email, text));
  void markRead() {
    _requireMember();
    for (var i = 0; i < _notices.length; i++) {
      final n = _notices[i];
      if (n.email == _email)
        _notices[i] = MemberNotice(n.id, n.email, n.text, read: true);
    }
    _changed();
  }

  @visibleForTesting
  void resetForTest() {
    _storageReady = false;
    _email = null;
    _accounts.clear();
    _events.clear();
    _requests.clear();
    _notices.clear();
    _saved.clear();
    _nextRequest = 1;
    _nextNotice = 1;
    storageError = null;
    _seed();
    notifyListeners();
  }
}
