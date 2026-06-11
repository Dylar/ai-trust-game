// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_db.dart';

// ignore_for_file: type=lint
class $UserRowsTable extends UserRows with TableInfo<$UserRowsTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, displayName, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserRowsTable createAlias(String alias) {
    return $UserRowsTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String id;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserRow({
    required this.id,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserRowsCompanion toCompanion(bool nullToAbsent) {
    return UserRowsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserRow copyWith({
    String? id,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserRow(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserRow copyWithCompanion(UserRowsCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserRowsCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserRowsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserRowsCompanion.insert({
    required String id,
    required String displayName,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserRowsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserRowsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionRowsTable extends SessionRows
    with TableInfo<$SessionRowsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, role, mode, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionRowsTable createAlias(String alias) {
    return $SessionRowsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final String userId;
  final String role;
  final String mode;
  final DateTime updatedAt;
  const SessionRow({
    required this.id,
    required this.userId,
    required this.role,
    required this.mode,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    map['mode'] = Variable<String>(mode);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionRowsCompanion toCompanion(bool nullToAbsent) {
    return SessionRowsCompanion(
      id: Value(id),
      userId: Value(userId),
      role: Value(role),
      mode: Value(mode),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      mode: serializer.fromJson<String>(json['mode']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'mode': serializer.toJson<String>(mode),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionRow copyWith({
    String? id,
    String? userId,
    String? role,
    String? mode,
    DateTime? updatedAt,
  }) => SessionRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    mode: mode ?? this.mode,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionRow copyWithCompanion(SessionRowsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      mode: data.mode.present ? data.mode.value : this.mode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('mode: $mode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, role, mode, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.mode == this.mode &&
          other.updatedAt == this.updatedAt);
}

class SessionRowsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> role;
  final Value<String> mode;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionRowsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.mode = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionRowsCompanion.insert({
    required String id,
    required String userId,
    required String role,
    required String mode,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       role = Value(role),
       mode = Value(mode),
       updatedAt = Value(updatedAt);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<String>? mode,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (mode != null) 'mode': mode,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? role,
    Value<String>? mode,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionRowsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      mode: mode ?? this.mode,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionRowsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('mode: $mode, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InteractionRowsTable extends InteractionRows
    with TableInfo<$InteractionRowsTable, InteractionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InteractionRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _interactionIdMeta = const VerificationMeta(
    'interactionId',
  );
  @override
  late final GeneratedColumn<String> interactionId = GeneratedColumn<String>(
    'interaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    interactionId,
    sessionId,
    userId,
    message,
    answer,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<InteractionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('interaction_id')) {
      context.handle(
        _interactionIdMeta,
        interactionId.isAcceptableOrUnknown(
          data['interaction_id']!,
          _interactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interactionIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {interactionId};
  @override
  InteractionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InteractionRow(
      interactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interaction_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $InteractionRowsTable createAlias(String alias) {
    return $InteractionRowsTable(attachedDatabase, alias);
  }
}

class InteractionRow extends DataClass implements Insertable<InteractionRow> {
  final String interactionId;
  final String sessionId;
  final String userId;
  final String message;
  final String answer;
  final DateTime savedAt;
  const InteractionRow({
    required this.interactionId,
    required this.sessionId,
    required this.userId,
    required this.message,
    required this.answer,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['interaction_id'] = Variable<String>(interactionId);
    map['session_id'] = Variable<String>(sessionId);
    map['user_id'] = Variable<String>(userId);
    map['message'] = Variable<String>(message);
    map['answer'] = Variable<String>(answer);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  InteractionRowsCompanion toCompanion(bool nullToAbsent) {
    return InteractionRowsCompanion(
      interactionId: Value(interactionId),
      sessionId: Value(sessionId),
      userId: Value(userId),
      message: Value(message),
      answer: Value(answer),
      savedAt: Value(savedAt),
    );
  }

  factory InteractionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InteractionRow(
      interactionId: serializer.fromJson<String>(json['interactionId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      userId: serializer.fromJson<String>(json['userId']),
      message: serializer.fromJson<String>(json['message']),
      answer: serializer.fromJson<String>(json['answer']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'interactionId': serializer.toJson<String>(interactionId),
      'sessionId': serializer.toJson<String>(sessionId),
      'userId': serializer.toJson<String>(userId),
      'message': serializer.toJson<String>(message),
      'answer': serializer.toJson<String>(answer),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  InteractionRow copyWith({
    String? interactionId,
    String? sessionId,
    String? userId,
    String? message,
    String? answer,
    DateTime? savedAt,
  }) => InteractionRow(
    interactionId: interactionId ?? this.interactionId,
    sessionId: sessionId ?? this.sessionId,
    userId: userId ?? this.userId,
    message: message ?? this.message,
    answer: answer ?? this.answer,
    savedAt: savedAt ?? this.savedAt,
  );
  InteractionRow copyWithCompanion(InteractionRowsCompanion data) {
    return InteractionRow(
      interactionId: data.interactionId.present
          ? data.interactionId.value
          : this.interactionId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      message: data.message.present ? data.message.value : this.message,
      answer: data.answer.present ? data.answer.value : this.answer,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InteractionRow(')
          ..write('interactionId: $interactionId, ')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('message: $message, ')
          ..write('answer: $answer, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(interactionId, sessionId, userId, message, answer, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InteractionRow &&
          other.interactionId == this.interactionId &&
          other.sessionId == this.sessionId &&
          other.userId == this.userId &&
          other.message == this.message &&
          other.answer == this.answer &&
          other.savedAt == this.savedAt);
}

class InteractionRowsCompanion extends UpdateCompanion<InteractionRow> {
  final Value<String> interactionId;
  final Value<String> sessionId;
  final Value<String> userId;
  final Value<String> message;
  final Value<String> answer;
  final Value<DateTime> savedAt;
  final Value<int> rowid;
  const InteractionRowsCompanion({
    this.interactionId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.message = const Value.absent(),
    this.answer = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InteractionRowsCompanion.insert({
    required String interactionId,
    required String sessionId,
    required String userId,
    required String message,
    required String answer,
    required DateTime savedAt,
    this.rowid = const Value.absent(),
  }) : interactionId = Value(interactionId),
       sessionId = Value(sessionId),
       userId = Value(userId),
       message = Value(message),
       answer = Value(answer),
       savedAt = Value(savedAt);
  static Insertable<InteractionRow> custom({
    Expression<String>? interactionId,
    Expression<String>? sessionId,
    Expression<String>? userId,
    Expression<String>? message,
    Expression<String>? answer,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (interactionId != null) 'interaction_id': interactionId,
      if (sessionId != null) 'session_id': sessionId,
      if (userId != null) 'user_id': userId,
      if (message != null) 'message': message,
      if (answer != null) 'answer': answer,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InteractionRowsCompanion copyWith({
    Value<String>? interactionId,
    Value<String>? sessionId,
    Value<String>? userId,
    Value<String>? message,
    Value<String>? answer,
    Value<DateTime>? savedAt,
    Value<int>? rowid,
  }) {
    return InteractionRowsCompanion(
      interactionId: interactionId ?? this.interactionId,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      answer: answer ?? this.answer,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (interactionId.present) {
      map['interaction_id'] = Variable<String>(interactionId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InteractionRowsCompanion(')
          ..write('interactionId: $interactionId, ')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('message: $message, ')
          ..write('answer: $answer, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RequestAnalysisRowsTable extends RequestAnalysisRows
    with TableInfo<$RequestAnalysisRowsTable, RequestAnalysisRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RequestAnalysisRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classificationMeta = const VerificationMeta(
    'classification',
  );
  @override
  late final GeneratedColumn<String> classification = GeneratedColumn<String>(
    'classification',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signalsJsonMeta = const VerificationMeta(
    'signalsJson',
  );
  @override
  late final GeneratedColumn<String> signalsJson = GeneratedColumn<String>(
    'signals_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attackPatternsJsonMeta =
      const VerificationMeta('attackPatternsJson');
  @override
  late final GeneratedColumn<String> attackPatternsJson =
      GeneratedColumn<String>(
        'attack_patterns_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _intentSummaryMeta = const VerificationMeta(
    'intentSummary',
  );
  @override
  late final GeneratedColumn<String> intentSummary = GeneratedColumn<String>(
    'intent_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventCountMeta = const VerificationMeta(
    'eventCount',
  );
  @override
  late final GeneratedColumn<int> eventCount = GeneratedColumn<int>(
    'event_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suspicionCountMeta = const VerificationMeta(
    'suspicionCount',
  );
  @override
  late final GeneratedColumn<int> suspicionCount = GeneratedColumn<int>(
    'suspicion_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelFailCountMeta = const VerificationMeta(
    'modelFailCount',
  );
  @override
  late final GeneratedColumn<int> modelFailCount = GeneratedColumn<int>(
    'model_fail_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    requestId,
    sessionId,
    userId,
    completedAt,
    classification,
    signalsJson,
    attackPatternsJson,
    intentSummary,
    eventCount,
    suspicionCount,
    modelFailCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'request_analyses';
  @override
  VerificationContext validateIntegrity(
    Insertable<RequestAnalysisRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('classification')) {
      context.handle(
        _classificationMeta,
        classification.isAcceptableOrUnknown(
          data['classification']!,
          _classificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_classificationMeta);
    }
    if (data.containsKey('signals_json')) {
      context.handle(
        _signalsJsonMeta,
        signalsJson.isAcceptableOrUnknown(
          data['signals_json']!,
          _signalsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_signalsJsonMeta);
    }
    if (data.containsKey('attack_patterns_json')) {
      context.handle(
        _attackPatternsJsonMeta,
        attackPatternsJson.isAcceptableOrUnknown(
          data['attack_patterns_json']!,
          _attackPatternsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attackPatternsJsonMeta);
    }
    if (data.containsKey('intent_summary')) {
      context.handle(
        _intentSummaryMeta,
        intentSummary.isAcceptableOrUnknown(
          data['intent_summary']!,
          _intentSummaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intentSummaryMeta);
    }
    if (data.containsKey('event_count')) {
      context.handle(
        _eventCountMeta,
        eventCount.isAcceptableOrUnknown(data['event_count']!, _eventCountMeta),
      );
    } else if (isInserting) {
      context.missing(_eventCountMeta);
    }
    if (data.containsKey('suspicion_count')) {
      context.handle(
        _suspicionCountMeta,
        suspicionCount.isAcceptableOrUnknown(
          data['suspicion_count']!,
          _suspicionCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_suspicionCountMeta);
    }
    if (data.containsKey('model_fail_count')) {
      context.handle(
        _modelFailCountMeta,
        modelFailCount.isAcceptableOrUnknown(
          data['model_fail_count']!,
          _modelFailCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelFailCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {requestId};
  @override
  RequestAnalysisRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RequestAnalysisRow(
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      classification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classification'],
      )!,
      signalsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signals_json'],
      )!,
      attackPatternsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attack_patterns_json'],
      )!,
      intentSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intent_summary'],
      )!,
      eventCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_count'],
      )!,
      suspicionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}suspicion_count'],
      )!,
      modelFailCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}model_fail_count'],
      )!,
    );
  }

  @override
  $RequestAnalysisRowsTable createAlias(String alias) {
    return $RequestAnalysisRowsTable(attachedDatabase, alias);
  }
}

class RequestAnalysisRow extends DataClass
    implements Insertable<RequestAnalysisRow> {
  final String requestId;
  final String sessionId;
  final String userId;
  final DateTime completedAt;
  final String classification;
  final String signalsJson;
  final String attackPatternsJson;
  final String intentSummary;
  final int eventCount;
  final int suspicionCount;
  final int modelFailCount;
  const RequestAnalysisRow({
    required this.requestId,
    required this.sessionId,
    required this.userId,
    required this.completedAt,
    required this.classification,
    required this.signalsJson,
    required this.attackPatternsJson,
    required this.intentSummary,
    required this.eventCount,
    required this.suspicionCount,
    required this.modelFailCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['request_id'] = Variable<String>(requestId);
    map['session_id'] = Variable<String>(sessionId);
    map['user_id'] = Variable<String>(userId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['classification'] = Variable<String>(classification);
    map['signals_json'] = Variable<String>(signalsJson);
    map['attack_patterns_json'] = Variable<String>(attackPatternsJson);
    map['intent_summary'] = Variable<String>(intentSummary);
    map['event_count'] = Variable<int>(eventCount);
    map['suspicion_count'] = Variable<int>(suspicionCount);
    map['model_fail_count'] = Variable<int>(modelFailCount);
    return map;
  }

  RequestAnalysisRowsCompanion toCompanion(bool nullToAbsent) {
    return RequestAnalysisRowsCompanion(
      requestId: Value(requestId),
      sessionId: Value(sessionId),
      userId: Value(userId),
      completedAt: Value(completedAt),
      classification: Value(classification),
      signalsJson: Value(signalsJson),
      attackPatternsJson: Value(attackPatternsJson),
      intentSummary: Value(intentSummary),
      eventCount: Value(eventCount),
      suspicionCount: Value(suspicionCount),
      modelFailCount: Value(modelFailCount),
    );
  }

  factory RequestAnalysisRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RequestAnalysisRow(
      requestId: serializer.fromJson<String>(json['requestId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      userId: serializer.fromJson<String>(json['userId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      classification: serializer.fromJson<String>(json['classification']),
      signalsJson: serializer.fromJson<String>(json['signalsJson']),
      attackPatternsJson: serializer.fromJson<String>(
        json['attackPatternsJson'],
      ),
      intentSummary: serializer.fromJson<String>(json['intentSummary']),
      eventCount: serializer.fromJson<int>(json['eventCount']),
      suspicionCount: serializer.fromJson<int>(json['suspicionCount']),
      modelFailCount: serializer.fromJson<int>(json['modelFailCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'requestId': serializer.toJson<String>(requestId),
      'sessionId': serializer.toJson<String>(sessionId),
      'userId': serializer.toJson<String>(userId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'classification': serializer.toJson<String>(classification),
      'signalsJson': serializer.toJson<String>(signalsJson),
      'attackPatternsJson': serializer.toJson<String>(attackPatternsJson),
      'intentSummary': serializer.toJson<String>(intentSummary),
      'eventCount': serializer.toJson<int>(eventCount),
      'suspicionCount': serializer.toJson<int>(suspicionCount),
      'modelFailCount': serializer.toJson<int>(modelFailCount),
    };
  }

  RequestAnalysisRow copyWith({
    String? requestId,
    String? sessionId,
    String? userId,
    DateTime? completedAt,
    String? classification,
    String? signalsJson,
    String? attackPatternsJson,
    String? intentSummary,
    int? eventCount,
    int? suspicionCount,
    int? modelFailCount,
  }) => RequestAnalysisRow(
    requestId: requestId ?? this.requestId,
    sessionId: sessionId ?? this.sessionId,
    userId: userId ?? this.userId,
    completedAt: completedAt ?? this.completedAt,
    classification: classification ?? this.classification,
    signalsJson: signalsJson ?? this.signalsJson,
    attackPatternsJson: attackPatternsJson ?? this.attackPatternsJson,
    intentSummary: intentSummary ?? this.intentSummary,
    eventCount: eventCount ?? this.eventCount,
    suspicionCount: suspicionCount ?? this.suspicionCount,
    modelFailCount: modelFailCount ?? this.modelFailCount,
  );
  RequestAnalysisRow copyWithCompanion(RequestAnalysisRowsCompanion data) {
    return RequestAnalysisRow(
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      classification: data.classification.present
          ? data.classification.value
          : this.classification,
      signalsJson: data.signalsJson.present
          ? data.signalsJson.value
          : this.signalsJson,
      attackPatternsJson: data.attackPatternsJson.present
          ? data.attackPatternsJson.value
          : this.attackPatternsJson,
      intentSummary: data.intentSummary.present
          ? data.intentSummary.value
          : this.intentSummary,
      eventCount: data.eventCount.present
          ? data.eventCount.value
          : this.eventCount,
      suspicionCount: data.suspicionCount.present
          ? data.suspicionCount.value
          : this.suspicionCount,
      modelFailCount: data.modelFailCount.present
          ? data.modelFailCount.value
          : this.modelFailCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RequestAnalysisRow(')
          ..write('requestId: $requestId, ')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('completedAt: $completedAt, ')
          ..write('classification: $classification, ')
          ..write('signalsJson: $signalsJson, ')
          ..write('attackPatternsJson: $attackPatternsJson, ')
          ..write('intentSummary: $intentSummary, ')
          ..write('eventCount: $eventCount, ')
          ..write('suspicionCount: $suspicionCount, ')
          ..write('modelFailCount: $modelFailCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    requestId,
    sessionId,
    userId,
    completedAt,
    classification,
    signalsJson,
    attackPatternsJson,
    intentSummary,
    eventCount,
    suspicionCount,
    modelFailCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestAnalysisRow &&
          other.requestId == this.requestId &&
          other.sessionId == this.sessionId &&
          other.userId == this.userId &&
          other.completedAt == this.completedAt &&
          other.classification == this.classification &&
          other.signalsJson == this.signalsJson &&
          other.attackPatternsJson == this.attackPatternsJson &&
          other.intentSummary == this.intentSummary &&
          other.eventCount == this.eventCount &&
          other.suspicionCount == this.suspicionCount &&
          other.modelFailCount == this.modelFailCount);
}

class RequestAnalysisRowsCompanion extends UpdateCompanion<RequestAnalysisRow> {
  final Value<String> requestId;
  final Value<String> sessionId;
  final Value<String> userId;
  final Value<DateTime> completedAt;
  final Value<String> classification;
  final Value<String> signalsJson;
  final Value<String> attackPatternsJson;
  final Value<String> intentSummary;
  final Value<int> eventCount;
  final Value<int> suspicionCount;
  final Value<int> modelFailCount;
  final Value<int> rowid;
  const RequestAnalysisRowsCompanion({
    this.requestId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.classification = const Value.absent(),
    this.signalsJson = const Value.absent(),
    this.attackPatternsJson = const Value.absent(),
    this.intentSummary = const Value.absent(),
    this.eventCount = const Value.absent(),
    this.suspicionCount = const Value.absent(),
    this.modelFailCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestAnalysisRowsCompanion.insert({
    required String requestId,
    required String sessionId,
    required String userId,
    required DateTime completedAt,
    required String classification,
    required String signalsJson,
    required String attackPatternsJson,
    required String intentSummary,
    required int eventCount,
    required int suspicionCount,
    required int modelFailCount,
    this.rowid = const Value.absent(),
  }) : requestId = Value(requestId),
       sessionId = Value(sessionId),
       userId = Value(userId),
       completedAt = Value(completedAt),
       classification = Value(classification),
       signalsJson = Value(signalsJson),
       attackPatternsJson = Value(attackPatternsJson),
       intentSummary = Value(intentSummary),
       eventCount = Value(eventCount),
       suspicionCount = Value(suspicionCount),
       modelFailCount = Value(modelFailCount);
  static Insertable<RequestAnalysisRow> custom({
    Expression<String>? requestId,
    Expression<String>? sessionId,
    Expression<String>? userId,
    Expression<DateTime>? completedAt,
    Expression<String>? classification,
    Expression<String>? signalsJson,
    Expression<String>? attackPatternsJson,
    Expression<String>? intentSummary,
    Expression<int>? eventCount,
    Expression<int>? suspicionCount,
    Expression<int>? modelFailCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (requestId != null) 'request_id': requestId,
      if (sessionId != null) 'session_id': sessionId,
      if (userId != null) 'user_id': userId,
      if (completedAt != null) 'completed_at': completedAt,
      if (classification != null) 'classification': classification,
      if (signalsJson != null) 'signals_json': signalsJson,
      if (attackPatternsJson != null)
        'attack_patterns_json': attackPatternsJson,
      if (intentSummary != null) 'intent_summary': intentSummary,
      if (eventCount != null) 'event_count': eventCount,
      if (suspicionCount != null) 'suspicion_count': suspicionCount,
      if (modelFailCount != null) 'model_fail_count': modelFailCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestAnalysisRowsCompanion copyWith({
    Value<String>? requestId,
    Value<String>? sessionId,
    Value<String>? userId,
    Value<DateTime>? completedAt,
    Value<String>? classification,
    Value<String>? signalsJson,
    Value<String>? attackPatternsJson,
    Value<String>? intentSummary,
    Value<int>? eventCount,
    Value<int>? suspicionCount,
    Value<int>? modelFailCount,
    Value<int>? rowid,
  }) {
    return RequestAnalysisRowsCompanion(
      requestId: requestId ?? this.requestId,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      classification: classification ?? this.classification,
      signalsJson: signalsJson ?? this.signalsJson,
      attackPatternsJson: attackPatternsJson ?? this.attackPatternsJson,
      intentSummary: intentSummary ?? this.intentSummary,
      eventCount: eventCount ?? this.eventCount,
      suspicionCount: suspicionCount ?? this.suspicionCount,
      modelFailCount: modelFailCount ?? this.modelFailCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (classification.present) {
      map['classification'] = Variable<String>(classification.value);
    }
    if (signalsJson.present) {
      map['signals_json'] = Variable<String>(signalsJson.value);
    }
    if (attackPatternsJson.present) {
      map['attack_patterns_json'] = Variable<String>(attackPatternsJson.value);
    }
    if (intentSummary.present) {
      map['intent_summary'] = Variable<String>(intentSummary.value);
    }
    if (eventCount.present) {
      map['event_count'] = Variable<int>(eventCount.value);
    }
    if (suspicionCount.present) {
      map['suspicion_count'] = Variable<int>(suspicionCount.value);
    }
    if (modelFailCount.present) {
      map['model_fail_count'] = Variable<int>(modelFailCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestAnalysisRowsCompanion(')
          ..write('requestId: $requestId, ')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('completedAt: $completedAt, ')
          ..write('classification: $classification, ')
          ..write('signalsJson: $signalsJson, ')
          ..write('attackPatternsJson: $attackPatternsJson, ')
          ..write('intentSummary: $intentSummary, ')
          ..write('eventCount: $eventCount, ')
          ..write('suspicionCount: $suspicionCount, ')
          ..write('modelFailCount: $modelFailCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionAnalysisRowsTable extends SessionAnalysisRows
    with TableInfo<$SessionAnalysisRowsTable, SessionAnalysisRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionAnalysisRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classificationMeta = const VerificationMeta(
    'classification',
  );
  @override
  late final GeneratedColumn<String> classification = GeneratedColumn<String>(
    'classification',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signalsJsonMeta = const VerificationMeta(
    'signalsJson',
  );
  @override
  late final GeneratedColumn<String> signalsJson = GeneratedColumn<String>(
    'signals_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attackPatternsJsonMeta =
      const VerificationMeta('attackPatternsJson');
  @override
  late final GeneratedColumn<String> attackPatternsJson =
      GeneratedColumn<String>(
        'attack_patterns_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _intentSummaryMeta = const VerificationMeta(
    'intentSummary',
  );
  @override
  late final GeneratedColumn<String> intentSummary = GeneratedColumn<String>(
    'intent_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestCountMeta = const VerificationMeta(
    'requestCount',
  );
  @override
  late final GeneratedColumn<int> requestCount = GeneratedColumn<int>(
    'request_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suspicionCountMeta = const VerificationMeta(
    'suspicionCount',
  );
  @override
  late final GeneratedColumn<int> suspicionCount = GeneratedColumn<int>(
    'suspicion_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelFailCountMeta = const VerificationMeta(
    'modelFailCount',
  );
  @override
  late final GeneratedColumn<int> modelFailCount = GeneratedColumn<int>(
    'model_fail_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    userId,
    classification,
    signalsJson,
    attackPatternsJson,
    intentSummary,
    requestCount,
    suspicionCount,
    modelFailCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_analyses';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionAnalysisRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('classification')) {
      context.handle(
        _classificationMeta,
        classification.isAcceptableOrUnknown(
          data['classification']!,
          _classificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_classificationMeta);
    }
    if (data.containsKey('signals_json')) {
      context.handle(
        _signalsJsonMeta,
        signalsJson.isAcceptableOrUnknown(
          data['signals_json']!,
          _signalsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_signalsJsonMeta);
    }
    if (data.containsKey('attack_patterns_json')) {
      context.handle(
        _attackPatternsJsonMeta,
        attackPatternsJson.isAcceptableOrUnknown(
          data['attack_patterns_json']!,
          _attackPatternsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attackPatternsJsonMeta);
    }
    if (data.containsKey('intent_summary')) {
      context.handle(
        _intentSummaryMeta,
        intentSummary.isAcceptableOrUnknown(
          data['intent_summary']!,
          _intentSummaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intentSummaryMeta);
    }
    if (data.containsKey('request_count')) {
      context.handle(
        _requestCountMeta,
        requestCount.isAcceptableOrUnknown(
          data['request_count']!,
          _requestCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestCountMeta);
    }
    if (data.containsKey('suspicion_count')) {
      context.handle(
        _suspicionCountMeta,
        suspicionCount.isAcceptableOrUnknown(
          data['suspicion_count']!,
          _suspicionCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_suspicionCountMeta);
    }
    if (data.containsKey('model_fail_count')) {
      context.handle(
        _modelFailCountMeta,
        modelFailCount.isAcceptableOrUnknown(
          data['model_fail_count']!,
          _modelFailCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelFailCountMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  SessionAnalysisRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionAnalysisRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      classification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classification'],
      )!,
      signalsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signals_json'],
      )!,
      attackPatternsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attack_patterns_json'],
      )!,
      intentSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intent_summary'],
      )!,
      requestCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}request_count'],
      )!,
      suspicionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}suspicion_count'],
      )!,
      modelFailCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}model_fail_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionAnalysisRowsTable createAlias(String alias) {
    return $SessionAnalysisRowsTable(attachedDatabase, alias);
  }
}

class SessionAnalysisRow extends DataClass
    implements Insertable<SessionAnalysisRow> {
  final String sessionId;
  final String userId;
  final String classification;
  final String signalsJson;
  final String attackPatternsJson;
  final String intentSummary;
  final int requestCount;
  final int suspicionCount;
  final int modelFailCount;
  final DateTime updatedAt;
  const SessionAnalysisRow({
    required this.sessionId,
    required this.userId,
    required this.classification,
    required this.signalsJson,
    required this.attackPatternsJson,
    required this.intentSummary,
    required this.requestCount,
    required this.suspicionCount,
    required this.modelFailCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['user_id'] = Variable<String>(userId);
    map['classification'] = Variable<String>(classification);
    map['signals_json'] = Variable<String>(signalsJson);
    map['attack_patterns_json'] = Variable<String>(attackPatternsJson);
    map['intent_summary'] = Variable<String>(intentSummary);
    map['request_count'] = Variable<int>(requestCount);
    map['suspicion_count'] = Variable<int>(suspicionCount);
    map['model_fail_count'] = Variable<int>(modelFailCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionAnalysisRowsCompanion toCompanion(bool nullToAbsent) {
    return SessionAnalysisRowsCompanion(
      sessionId: Value(sessionId),
      userId: Value(userId),
      classification: Value(classification),
      signalsJson: Value(signalsJson),
      attackPatternsJson: Value(attackPatternsJson),
      intentSummary: Value(intentSummary),
      requestCount: Value(requestCount),
      suspicionCount: Value(suspicionCount),
      modelFailCount: Value(modelFailCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionAnalysisRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionAnalysisRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      userId: serializer.fromJson<String>(json['userId']),
      classification: serializer.fromJson<String>(json['classification']),
      signalsJson: serializer.fromJson<String>(json['signalsJson']),
      attackPatternsJson: serializer.fromJson<String>(
        json['attackPatternsJson'],
      ),
      intentSummary: serializer.fromJson<String>(json['intentSummary']),
      requestCount: serializer.fromJson<int>(json['requestCount']),
      suspicionCount: serializer.fromJson<int>(json['suspicionCount']),
      modelFailCount: serializer.fromJson<int>(json['modelFailCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'userId': serializer.toJson<String>(userId),
      'classification': serializer.toJson<String>(classification),
      'signalsJson': serializer.toJson<String>(signalsJson),
      'attackPatternsJson': serializer.toJson<String>(attackPatternsJson),
      'intentSummary': serializer.toJson<String>(intentSummary),
      'requestCount': serializer.toJson<int>(requestCount),
      'suspicionCount': serializer.toJson<int>(suspicionCount),
      'modelFailCount': serializer.toJson<int>(modelFailCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionAnalysisRow copyWith({
    String? sessionId,
    String? userId,
    String? classification,
    String? signalsJson,
    String? attackPatternsJson,
    String? intentSummary,
    int? requestCount,
    int? suspicionCount,
    int? modelFailCount,
    DateTime? updatedAt,
  }) => SessionAnalysisRow(
    sessionId: sessionId ?? this.sessionId,
    userId: userId ?? this.userId,
    classification: classification ?? this.classification,
    signalsJson: signalsJson ?? this.signalsJson,
    attackPatternsJson: attackPatternsJson ?? this.attackPatternsJson,
    intentSummary: intentSummary ?? this.intentSummary,
    requestCount: requestCount ?? this.requestCount,
    suspicionCount: suspicionCount ?? this.suspicionCount,
    modelFailCount: modelFailCount ?? this.modelFailCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionAnalysisRow copyWithCompanion(SessionAnalysisRowsCompanion data) {
    return SessionAnalysisRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      classification: data.classification.present
          ? data.classification.value
          : this.classification,
      signalsJson: data.signalsJson.present
          ? data.signalsJson.value
          : this.signalsJson,
      attackPatternsJson: data.attackPatternsJson.present
          ? data.attackPatternsJson.value
          : this.attackPatternsJson,
      intentSummary: data.intentSummary.present
          ? data.intentSummary.value
          : this.intentSummary,
      requestCount: data.requestCount.present
          ? data.requestCount.value
          : this.requestCount,
      suspicionCount: data.suspicionCount.present
          ? data.suspicionCount.value
          : this.suspicionCount,
      modelFailCount: data.modelFailCount.present
          ? data.modelFailCount.value
          : this.modelFailCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionAnalysisRow(')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('classification: $classification, ')
          ..write('signalsJson: $signalsJson, ')
          ..write('attackPatternsJson: $attackPatternsJson, ')
          ..write('intentSummary: $intentSummary, ')
          ..write('requestCount: $requestCount, ')
          ..write('suspicionCount: $suspicionCount, ')
          ..write('modelFailCount: $modelFailCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    userId,
    classification,
    signalsJson,
    attackPatternsJson,
    intentSummary,
    requestCount,
    suspicionCount,
    modelFailCount,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionAnalysisRow &&
          other.sessionId == this.sessionId &&
          other.userId == this.userId &&
          other.classification == this.classification &&
          other.signalsJson == this.signalsJson &&
          other.attackPatternsJson == this.attackPatternsJson &&
          other.intentSummary == this.intentSummary &&
          other.requestCount == this.requestCount &&
          other.suspicionCount == this.suspicionCount &&
          other.modelFailCount == this.modelFailCount &&
          other.updatedAt == this.updatedAt);
}

class SessionAnalysisRowsCompanion extends UpdateCompanion<SessionAnalysisRow> {
  final Value<String> sessionId;
  final Value<String> userId;
  final Value<String> classification;
  final Value<String> signalsJson;
  final Value<String> attackPatternsJson;
  final Value<String> intentSummary;
  final Value<int> requestCount;
  final Value<int> suspicionCount;
  final Value<int> modelFailCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionAnalysisRowsCompanion({
    this.sessionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.classification = const Value.absent(),
    this.signalsJson = const Value.absent(),
    this.attackPatternsJson = const Value.absent(),
    this.intentSummary = const Value.absent(),
    this.requestCount = const Value.absent(),
    this.suspicionCount = const Value.absent(),
    this.modelFailCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionAnalysisRowsCompanion.insert({
    required String sessionId,
    required String userId,
    required String classification,
    required String signalsJson,
    required String attackPatternsJson,
    required String intentSummary,
    required int requestCount,
    required int suspicionCount,
    required int modelFailCount,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       userId = Value(userId),
       classification = Value(classification),
       signalsJson = Value(signalsJson),
       attackPatternsJson = Value(attackPatternsJson),
       intentSummary = Value(intentSummary),
       requestCount = Value(requestCount),
       suspicionCount = Value(suspicionCount),
       modelFailCount = Value(modelFailCount),
       updatedAt = Value(updatedAt);
  static Insertable<SessionAnalysisRow> custom({
    Expression<String>? sessionId,
    Expression<String>? userId,
    Expression<String>? classification,
    Expression<String>? signalsJson,
    Expression<String>? attackPatternsJson,
    Expression<String>? intentSummary,
    Expression<int>? requestCount,
    Expression<int>? suspicionCount,
    Expression<int>? modelFailCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (userId != null) 'user_id': userId,
      if (classification != null) 'classification': classification,
      if (signalsJson != null) 'signals_json': signalsJson,
      if (attackPatternsJson != null)
        'attack_patterns_json': attackPatternsJson,
      if (intentSummary != null) 'intent_summary': intentSummary,
      if (requestCount != null) 'request_count': requestCount,
      if (suspicionCount != null) 'suspicion_count': suspicionCount,
      if (modelFailCount != null) 'model_fail_count': modelFailCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionAnalysisRowsCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? userId,
    Value<String>? classification,
    Value<String>? signalsJson,
    Value<String>? attackPatternsJson,
    Value<String>? intentSummary,
    Value<int>? requestCount,
    Value<int>? suspicionCount,
    Value<int>? modelFailCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionAnalysisRowsCompanion(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      classification: classification ?? this.classification,
      signalsJson: signalsJson ?? this.signalsJson,
      attackPatternsJson: attackPatternsJson ?? this.attackPatternsJson,
      intentSummary: intentSummary ?? this.intentSummary,
      requestCount: requestCount ?? this.requestCount,
      suspicionCount: suspicionCount ?? this.suspicionCount,
      modelFailCount: modelFailCount ?? this.modelFailCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (classification.present) {
      map['classification'] = Variable<String>(classification.value);
    }
    if (signalsJson.present) {
      map['signals_json'] = Variable<String>(signalsJson.value);
    }
    if (attackPatternsJson.present) {
      map['attack_patterns_json'] = Variable<String>(attackPatternsJson.value);
    }
    if (intentSummary.present) {
      map['intent_summary'] = Variable<String>(intentSummary.value);
    }
    if (requestCount.present) {
      map['request_count'] = Variable<int>(requestCount.value);
    }
    if (suspicionCount.present) {
      map['suspicion_count'] = Variable<int>(suspicionCount.value);
    }
    if (modelFailCount.present) {
      map['model_fail_count'] = Variable<int>(modelFailCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionAnalysisRowsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('classification: $classification, ')
          ..write('signalsJson: $signalsJson, ')
          ..write('attackPatternsJson: $attackPatternsJson, ')
          ..write('intentSummary: $intentSummary, ')
          ..write('requestCount: $requestCount, ')
          ..write('suspicionCount: $suspicionCount, ')
          ..write('modelFailCount: $modelFailCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DriftDB extends GeneratedDatabase {
  _$DriftDB(QueryExecutor e) : super(e);
  $DriftDBManager get managers => $DriftDBManager(this);
  late final $UserRowsTable userRows = $UserRowsTable(this);
  late final $SessionRowsTable sessionRows = $SessionRowsTable(this);
  late final $InteractionRowsTable interactionRows = $InteractionRowsTable(
    this,
  );
  late final $RequestAnalysisRowsTable requestAnalysisRows =
      $RequestAnalysisRowsTable(this);
  late final $SessionAnalysisRowsTable sessionAnalysisRows =
      $SessionAnalysisRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userRows,
    sessionRows,
    interactionRows,
    requestAnalysisRows,
    sessionAnalysisRows,
  ];
}

typedef $$UserRowsTableCreateCompanionBuilder =
    UserRowsCompanion Function({
      required String id,
      required String displayName,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserRowsTableUpdateCompanionBuilder =
    UserRowsCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserRowsTableFilterComposer
    extends Composer<_$DriftDB, $UserRowsTable> {
  $$UserRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserRowsTableOrderingComposer
    extends Composer<_$DriftDB, $UserRowsTable> {
  $$UserRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserRowsTableAnnotationComposer
    extends Composer<_$DriftDB, $UserRowsTable> {
  $$UserRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserRowsTableTableManager
    extends
        RootTableManager<
          _$DriftDB,
          $UserRowsTable,
          UserRow,
          $$UserRowsTableFilterComposer,
          $$UserRowsTableOrderingComposer,
          $$UserRowsTableAnnotationComposer,
          $$UserRowsTableCreateCompanionBuilder,
          $$UserRowsTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$DriftDB, $UserRowsTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UserRowsTableTableManager(_$DriftDB db, $UserRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserRowsCompanion(
                id: id,
                displayName: displayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserRowsCompanion.insert(
                id: id,
                displayName: displayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftDB,
      $UserRowsTable,
      UserRow,
      $$UserRowsTableFilterComposer,
      $$UserRowsTableOrderingComposer,
      $$UserRowsTableAnnotationComposer,
      $$UserRowsTableCreateCompanionBuilder,
      $$UserRowsTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$DriftDB, $UserRowsTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$SessionRowsTableCreateCompanionBuilder =
    SessionRowsCompanion Function({
      required String id,
      required String userId,
      required String role,
      required String mode,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SessionRowsTableUpdateCompanionBuilder =
    SessionRowsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> role,
      Value<String> mode,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SessionRowsTableFilterComposer
    extends Composer<_$DriftDB, $SessionRowsTable> {
  $$SessionRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionRowsTableOrderingComposer
    extends Composer<_$DriftDB, $SessionRowsTable> {
  $$SessionRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionRowsTableAnnotationComposer
    extends Composer<_$DriftDB, $SessionRowsTable> {
  $$SessionRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionRowsTableTableManager
    extends
        RootTableManager<
          _$DriftDB,
          $SessionRowsTable,
          SessionRow,
          $$SessionRowsTableFilterComposer,
          $$SessionRowsTableOrderingComposer,
          $$SessionRowsTableAnnotationComposer,
          $$SessionRowsTableCreateCompanionBuilder,
          $$SessionRowsTableUpdateCompanionBuilder,
          (
            SessionRow,
            BaseReferences<_$DriftDB, $SessionRowsTable, SessionRow>,
          ),
          SessionRow,
          PrefetchHooks Function()
        > {
  $$SessionRowsTableTableManager(_$DriftDB db, $SessionRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionRowsCompanion(
                id: id,
                userId: userId,
                role: role,
                mode: mode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String role,
                required String mode,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionRowsCompanion.insert(
                id: id,
                userId: userId,
                role: role,
                mode: mode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftDB,
      $SessionRowsTable,
      SessionRow,
      $$SessionRowsTableFilterComposer,
      $$SessionRowsTableOrderingComposer,
      $$SessionRowsTableAnnotationComposer,
      $$SessionRowsTableCreateCompanionBuilder,
      $$SessionRowsTableUpdateCompanionBuilder,
      (SessionRow, BaseReferences<_$DriftDB, $SessionRowsTable, SessionRow>),
      SessionRow,
      PrefetchHooks Function()
    >;
typedef $$InteractionRowsTableCreateCompanionBuilder =
    InteractionRowsCompanion Function({
      required String interactionId,
      required String sessionId,
      required String userId,
      required String message,
      required String answer,
      required DateTime savedAt,
      Value<int> rowid,
    });
typedef $$InteractionRowsTableUpdateCompanionBuilder =
    InteractionRowsCompanion Function({
      Value<String> interactionId,
      Value<String> sessionId,
      Value<String> userId,
      Value<String> message,
      Value<String> answer,
      Value<DateTime> savedAt,
      Value<int> rowid,
    });

class $$InteractionRowsTableFilterComposer
    extends Composer<_$DriftDB, $InteractionRowsTable> {
  $$InteractionRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get interactionId => $composableBuilder(
    column: $table.interactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InteractionRowsTableOrderingComposer
    extends Composer<_$DriftDB, $InteractionRowsTable> {
  $$InteractionRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get interactionId => $composableBuilder(
    column: $table.interactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InteractionRowsTableAnnotationComposer
    extends Composer<_$DriftDB, $InteractionRowsTable> {
  $$InteractionRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get interactionId => $composableBuilder(
    column: $table.interactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$InteractionRowsTableTableManager
    extends
        RootTableManager<
          _$DriftDB,
          $InteractionRowsTable,
          InteractionRow,
          $$InteractionRowsTableFilterComposer,
          $$InteractionRowsTableOrderingComposer,
          $$InteractionRowsTableAnnotationComposer,
          $$InteractionRowsTableCreateCompanionBuilder,
          $$InteractionRowsTableUpdateCompanionBuilder,
          (
            InteractionRow,
            BaseReferences<_$DriftDB, $InteractionRowsTable, InteractionRow>,
          ),
          InteractionRow,
          PrefetchHooks Function()
        > {
  $$InteractionRowsTableTableManager(_$DriftDB db, $InteractionRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InteractionRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InteractionRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InteractionRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> interactionId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String> answer = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InteractionRowsCompanion(
                interactionId: interactionId,
                sessionId: sessionId,
                userId: userId,
                message: message,
                answer: answer,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String interactionId,
                required String sessionId,
                required String userId,
                required String message,
                required String answer,
                required DateTime savedAt,
                Value<int> rowid = const Value.absent(),
              }) => InteractionRowsCompanion.insert(
                interactionId: interactionId,
                sessionId: sessionId,
                userId: userId,
                message: message,
                answer: answer,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InteractionRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftDB,
      $InteractionRowsTable,
      InteractionRow,
      $$InteractionRowsTableFilterComposer,
      $$InteractionRowsTableOrderingComposer,
      $$InteractionRowsTableAnnotationComposer,
      $$InteractionRowsTableCreateCompanionBuilder,
      $$InteractionRowsTableUpdateCompanionBuilder,
      (
        InteractionRow,
        BaseReferences<_$DriftDB, $InteractionRowsTable, InteractionRow>,
      ),
      InteractionRow,
      PrefetchHooks Function()
    >;
typedef $$RequestAnalysisRowsTableCreateCompanionBuilder =
    RequestAnalysisRowsCompanion Function({
      required String requestId,
      required String sessionId,
      required String userId,
      required DateTime completedAt,
      required String classification,
      required String signalsJson,
      required String attackPatternsJson,
      required String intentSummary,
      required int eventCount,
      required int suspicionCount,
      required int modelFailCount,
      Value<int> rowid,
    });
typedef $$RequestAnalysisRowsTableUpdateCompanionBuilder =
    RequestAnalysisRowsCompanion Function({
      Value<String> requestId,
      Value<String> sessionId,
      Value<String> userId,
      Value<DateTime> completedAt,
      Value<String> classification,
      Value<String> signalsJson,
      Value<String> attackPatternsJson,
      Value<String> intentSummary,
      Value<int> eventCount,
      Value<int> suspicionCount,
      Value<int> modelFailCount,
      Value<int> rowid,
    });

class $$RequestAnalysisRowsTableFilterComposer
    extends Composer<_$DriftDB, $RequestAnalysisRowsTable> {
  $$RequestAnalysisRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signalsJson => $composableBuilder(
    column: $table.signalsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attackPatternsJson => $composableBuilder(
    column: $table.attackPatternsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intentSummary => $composableBuilder(
    column: $table.intentSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventCount => $composableBuilder(
    column: $table.eventCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get suspicionCount => $composableBuilder(
    column: $table.suspicionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get modelFailCount => $composableBuilder(
    column: $table.modelFailCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RequestAnalysisRowsTableOrderingComposer
    extends Composer<_$DriftDB, $RequestAnalysisRowsTable> {
  $$RequestAnalysisRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signalsJson => $composableBuilder(
    column: $table.signalsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attackPatternsJson => $composableBuilder(
    column: $table.attackPatternsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intentSummary => $composableBuilder(
    column: $table.intentSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventCount => $composableBuilder(
    column: $table.eventCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get suspicionCount => $composableBuilder(
    column: $table.suspicionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get modelFailCount => $composableBuilder(
    column: $table.modelFailCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RequestAnalysisRowsTableAnnotationComposer
    extends Composer<_$DriftDB, $RequestAnalysisRowsTable> {
  $$RequestAnalysisRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get signalsJson => $composableBuilder(
    column: $table.signalsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attackPatternsJson => $composableBuilder(
    column: $table.attackPatternsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intentSummary => $composableBuilder(
    column: $table.intentSummary,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eventCount => $composableBuilder(
    column: $table.eventCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get suspicionCount => $composableBuilder(
    column: $table.suspicionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get modelFailCount => $composableBuilder(
    column: $table.modelFailCount,
    builder: (column) => column,
  );
}

class $$RequestAnalysisRowsTableTableManager
    extends
        RootTableManager<
          _$DriftDB,
          $RequestAnalysisRowsTable,
          RequestAnalysisRow,
          $$RequestAnalysisRowsTableFilterComposer,
          $$RequestAnalysisRowsTableOrderingComposer,
          $$RequestAnalysisRowsTableAnnotationComposer,
          $$RequestAnalysisRowsTableCreateCompanionBuilder,
          $$RequestAnalysisRowsTableUpdateCompanionBuilder,
          (
            RequestAnalysisRow,
            BaseReferences<
              _$DriftDB,
              $RequestAnalysisRowsTable,
              RequestAnalysisRow
            >,
          ),
          RequestAnalysisRow,
          PrefetchHooks Function()
        > {
  $$RequestAnalysisRowsTableTableManager(
    _$DriftDB db,
    $RequestAnalysisRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RequestAnalysisRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RequestAnalysisRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RequestAnalysisRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> requestId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String> classification = const Value.absent(),
                Value<String> signalsJson = const Value.absent(),
                Value<String> attackPatternsJson = const Value.absent(),
                Value<String> intentSummary = const Value.absent(),
                Value<int> eventCount = const Value.absent(),
                Value<int> suspicionCount = const Value.absent(),
                Value<int> modelFailCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestAnalysisRowsCompanion(
                requestId: requestId,
                sessionId: sessionId,
                userId: userId,
                completedAt: completedAt,
                classification: classification,
                signalsJson: signalsJson,
                attackPatternsJson: attackPatternsJson,
                intentSummary: intentSummary,
                eventCount: eventCount,
                suspicionCount: suspicionCount,
                modelFailCount: modelFailCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String requestId,
                required String sessionId,
                required String userId,
                required DateTime completedAt,
                required String classification,
                required String signalsJson,
                required String attackPatternsJson,
                required String intentSummary,
                required int eventCount,
                required int suspicionCount,
                required int modelFailCount,
                Value<int> rowid = const Value.absent(),
              }) => RequestAnalysisRowsCompanion.insert(
                requestId: requestId,
                sessionId: sessionId,
                userId: userId,
                completedAt: completedAt,
                classification: classification,
                signalsJson: signalsJson,
                attackPatternsJson: attackPatternsJson,
                intentSummary: intentSummary,
                eventCount: eventCount,
                suspicionCount: suspicionCount,
                modelFailCount: modelFailCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RequestAnalysisRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftDB,
      $RequestAnalysisRowsTable,
      RequestAnalysisRow,
      $$RequestAnalysisRowsTableFilterComposer,
      $$RequestAnalysisRowsTableOrderingComposer,
      $$RequestAnalysisRowsTableAnnotationComposer,
      $$RequestAnalysisRowsTableCreateCompanionBuilder,
      $$RequestAnalysisRowsTableUpdateCompanionBuilder,
      (
        RequestAnalysisRow,
        BaseReferences<
          _$DriftDB,
          $RequestAnalysisRowsTable,
          RequestAnalysisRow
        >,
      ),
      RequestAnalysisRow,
      PrefetchHooks Function()
    >;
typedef $$SessionAnalysisRowsTableCreateCompanionBuilder =
    SessionAnalysisRowsCompanion Function({
      required String sessionId,
      required String userId,
      required String classification,
      required String signalsJson,
      required String attackPatternsJson,
      required String intentSummary,
      required int requestCount,
      required int suspicionCount,
      required int modelFailCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SessionAnalysisRowsTableUpdateCompanionBuilder =
    SessionAnalysisRowsCompanion Function({
      Value<String> sessionId,
      Value<String> userId,
      Value<String> classification,
      Value<String> signalsJson,
      Value<String> attackPatternsJson,
      Value<String> intentSummary,
      Value<int> requestCount,
      Value<int> suspicionCount,
      Value<int> modelFailCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SessionAnalysisRowsTableFilterComposer
    extends Composer<_$DriftDB, $SessionAnalysisRowsTable> {
  $$SessionAnalysisRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signalsJson => $composableBuilder(
    column: $table.signalsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attackPatternsJson => $composableBuilder(
    column: $table.attackPatternsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intentSummary => $composableBuilder(
    column: $table.intentSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestCount => $composableBuilder(
    column: $table.requestCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get suspicionCount => $composableBuilder(
    column: $table.suspicionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get modelFailCount => $composableBuilder(
    column: $table.modelFailCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionAnalysisRowsTableOrderingComposer
    extends Composer<_$DriftDB, $SessionAnalysisRowsTable> {
  $$SessionAnalysisRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signalsJson => $composableBuilder(
    column: $table.signalsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attackPatternsJson => $composableBuilder(
    column: $table.attackPatternsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intentSummary => $composableBuilder(
    column: $table.intentSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestCount => $composableBuilder(
    column: $table.requestCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get suspicionCount => $composableBuilder(
    column: $table.suspicionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get modelFailCount => $composableBuilder(
    column: $table.modelFailCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionAnalysisRowsTableAnnotationComposer
    extends Composer<_$DriftDB, $SessionAnalysisRowsTable> {
  $$SessionAnalysisRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get signalsJson => $composableBuilder(
    column: $table.signalsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attackPatternsJson => $composableBuilder(
    column: $table.attackPatternsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intentSummary => $composableBuilder(
    column: $table.intentSummary,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestCount => $composableBuilder(
    column: $table.requestCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get suspicionCount => $composableBuilder(
    column: $table.suspicionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get modelFailCount => $composableBuilder(
    column: $table.modelFailCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionAnalysisRowsTableTableManager
    extends
        RootTableManager<
          _$DriftDB,
          $SessionAnalysisRowsTable,
          SessionAnalysisRow,
          $$SessionAnalysisRowsTableFilterComposer,
          $$SessionAnalysisRowsTableOrderingComposer,
          $$SessionAnalysisRowsTableAnnotationComposer,
          $$SessionAnalysisRowsTableCreateCompanionBuilder,
          $$SessionAnalysisRowsTableUpdateCompanionBuilder,
          (
            SessionAnalysisRow,
            BaseReferences<
              _$DriftDB,
              $SessionAnalysisRowsTable,
              SessionAnalysisRow
            >,
          ),
          SessionAnalysisRow,
          PrefetchHooks Function()
        > {
  $$SessionAnalysisRowsTableTableManager(
    _$DriftDB db,
    $SessionAnalysisRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionAnalysisRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionAnalysisRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SessionAnalysisRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> classification = const Value.absent(),
                Value<String> signalsJson = const Value.absent(),
                Value<String> attackPatternsJson = const Value.absent(),
                Value<String> intentSummary = const Value.absent(),
                Value<int> requestCount = const Value.absent(),
                Value<int> suspicionCount = const Value.absent(),
                Value<int> modelFailCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionAnalysisRowsCompanion(
                sessionId: sessionId,
                userId: userId,
                classification: classification,
                signalsJson: signalsJson,
                attackPatternsJson: attackPatternsJson,
                intentSummary: intentSummary,
                requestCount: requestCount,
                suspicionCount: suspicionCount,
                modelFailCount: modelFailCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String userId,
                required String classification,
                required String signalsJson,
                required String attackPatternsJson,
                required String intentSummary,
                required int requestCount,
                required int suspicionCount,
                required int modelFailCount,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionAnalysisRowsCompanion.insert(
                sessionId: sessionId,
                userId: userId,
                classification: classification,
                signalsJson: signalsJson,
                attackPatternsJson: attackPatternsJson,
                intentSummary: intentSummary,
                requestCount: requestCount,
                suspicionCount: suspicionCount,
                modelFailCount: modelFailCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionAnalysisRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftDB,
      $SessionAnalysisRowsTable,
      SessionAnalysisRow,
      $$SessionAnalysisRowsTableFilterComposer,
      $$SessionAnalysisRowsTableOrderingComposer,
      $$SessionAnalysisRowsTableAnnotationComposer,
      $$SessionAnalysisRowsTableCreateCompanionBuilder,
      $$SessionAnalysisRowsTableUpdateCompanionBuilder,
      (
        SessionAnalysisRow,
        BaseReferences<
          _$DriftDB,
          $SessionAnalysisRowsTable,
          SessionAnalysisRow
        >,
      ),
      SessionAnalysisRow,
      PrefetchHooks Function()
    >;

class $DriftDBManager {
  final _$DriftDB _db;
  $DriftDBManager(this._db);
  $$UserRowsTableTableManager get userRows =>
      $$UserRowsTableTableManager(_db, _db.userRows);
  $$SessionRowsTableTableManager get sessionRows =>
      $$SessionRowsTableTableManager(_db, _db.sessionRows);
  $$InteractionRowsTableTableManager get interactionRows =>
      $$InteractionRowsTableTableManager(_db, _db.interactionRows);
  $$RequestAnalysisRowsTableTableManager get requestAnalysisRows =>
      $$RequestAnalysisRowsTableTableManager(_db, _db.requestAnalysisRows);
  $$SessionAnalysisRowsTableTableManager get sessionAnalysisRows =>
      $$SessionAnalysisRowsTableTableManager(_db, _db.sessionAnalysisRows);
}
