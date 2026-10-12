import 'package:flutter/material.dart';

enum UserRole { member, admin }

enum RequestStatus { pending, approved, rejected, completed, cancelled }

extension RequestLabel on RequestStatus {
  String get label => switch (this) {
    RequestStatus.pending => 'Қаралуда',
    RequestStatus.approved => 'Мақұлданды',
    RequestStatus.rejected => 'Қабылданбады',
    RequestStatus.completed => 'Қатысты',
    RequestStatus.cancelled => 'Бас тартылды',
  };
}

class Account {
  const Account({
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.salt,
    this.role = UserRole.member,
    this.blocked = false,
  });
  final String name, email, passwordHash, salt;
  final UserRole role;
  final bool blocked;
  Account withBlocked(bool value) => Account(
    name: name,
    email: email,
    passwordHash: passwordHash,
    salt: salt,
    role: role,
    blocked: value,
  );
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'hash': passwordHash,
    'salt': salt,
    'role': role.name,
    'blocked': blocked,
  };
  factory Account.fromJson(Map<String, dynamic> j) => Account(
    name: j['name'],
    email: j['email'],
    passwordHash: j['hash'],
    salt: j['salt'],
    role: UserRole.values.byName(j['role']),
    blocked: j['blocked'],
  );
}

class CharityEvent {
  const CharityEvent(
    this.id,
    this.category,
    this.title,
    this.location,
    this.date,
    this.icon,
    this.description, {
    this.capacity = 50,
    this.published = true,
    this.startsAt,
  });
  final int id, capacity;
  final String category, title, location, date, description;
  final IconData icon;
  final bool published;
  final DateTime? startsAt;
  DateTime get scheduledAt {
    if (startsAt != null) return startsAt!;
    final time = RegExp(r'(\d{2}):(\d{2})').firstMatch(date);
    return DateTime(2026, 10, int.tryParse(date.split(' ').first) ?? 1, int.tryParse(time?.group(1) ?? '') ?? 0, int.tryParse(time?.group(2) ?? '') ?? 0);
  }
  CharityEvent withPublished(bool value) => CharityEvent(
    id,
    category,
    title,
    location,
    date,
    icon,
    description,
    capacity: capacity,
    published: value,
    startsAt: startsAt,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'title': title,
    'location': location,
    'date': date,
    'description': description,
    'capacity': capacity,
    'published': published,
    'startsAt': scheduledAt.toIso8601String(),
  };
  static IconData categoryIcon(String category) => switch (category) {
    'Донорлық' => Icons.bloodtype_outlined,
    'Еріктілік' => Icons.people_outline,
    _ => Icons.volunteer_activism_outlined,
  };
  factory CharityEvent.fromJson(Map<String, dynamic> j) => CharityEvent(
    j['id'],
    j['category'],
    j['title'],
    j['location'],
    j['date'],
    categoryIcon(j['category']),
    j['description'],
    capacity: j['capacity'],
    published: j['published'],
    startsAt: DateTime.parse(j['startsAt']),
  );
}

class Participation {
  const Participation({
    required this.id,
    required this.email,
    required this.eventId,
    required this.status,
    this.note = '',
  });
  final int id, eventId;
  final String email, note;
  final RequestStatus status;
  String get ticket => 'UMIT-${id.toString().padLeft(6, '0')}';
  Participation change(RequestStatus next, String reason) => Participation(
    id: id,
    email: email,
    eventId: eventId,
    status: next,
    note: reason,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'eventId': eventId,
    'status': status.name,
    'note': note,
  };
  factory Participation.fromJson(Map<String, dynamic> j) => Participation(
    id: j['id'],
    email: j['email'],
    eventId: j['eventId'],
    status: RequestStatus.values.byName(j['status']),
    note: j['note'],
  );
}

class MemberNotice {
  const MemberNotice(this.id, this.email, this.text, {this.read = false});
  final int id;
  final String email, text;
  final bool read;
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'text': text,
    'read': read,
  };
  factory MemberNotice.fromJson(Map<String, dynamic> j) =>
      MemberNotice(j['id'], j['email'], j['text'], read: j['read']);
}
