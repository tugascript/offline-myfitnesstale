enum _WhereUnion {
  and('AND'),
  or('OR');

  final String value;

  const _WhereUnion(this.value);
}

final class _WhereStatement {
  final String condition;
  final _WhereUnion union;

  const _WhereStatement(this.condition, this.union);
}

final class WhereBuilder {
  final List<_WhereStatement> _where = [];
  final List<Object?> _args = [];

  String? get where {
    if (_where.isEmpty) {
      return null;
    }

    final String firstCondition = "(${_where.first.condition})";
    if (_where.length == 1) {
      return firstCondition;
    }

    return [
      firstCondition,
      ..._where.skip(1).map((e) => '${e.union.value} (${e.condition})'),
    ].join(' ');
  }

  List<Object?>? get args => _args.isEmpty ? null : _args;

  void and(String condition, [Object? arg]) {
    _where.add(_WhereStatement(condition, _WhereUnion.and));

    if (arg != null) {
      _args.add(arg);
    }
  }

  void or(String condition, [Object? arg]) {
    _where.add(_WhereStatement(condition, _WhereUnion.or));

    if (arg != null) {
      _args.add(arg);
    }
  }
}
