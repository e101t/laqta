import 'dart:async';

class Timestamp implements Comparable<Timestamp> {
  const Timestamp._(this._dateTime);

  factory Timestamp.fromDate(DateTime dateTime) => Timestamp._(dateTime);

  factory Timestamp.now() => Timestamp._(DateTime.now());

  final DateTime _dateTime;

  DateTime toDate() => _dateTime;

  @override
  int compareTo(Timestamp other) => _dateTime.compareTo(other._dateTime);
}

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class FieldValue {
  const FieldValue._();

  static DateTime serverTimestamp() => DateTime.now();
}

class SetOptions {
  const SetOptions({this.merge = false});

  final bool merge;
}

class BackendFunctionException implements Exception {
  const BackendFunctionException({this.code = 'backend_error', this.message});

  final String code;
  final String? message;

  @override
  String toString() => message ?? code;
}

class BackendDataException implements Exception {
  const BackendDataException({
    this.plugin = 'backend',
    this.code = 'backend_error',
    this.message,
  });

  final String plugin;
  final String code;
  final String? message;

  @override
  String toString() => message ?? code;
}

class DocumentSnapshot<T extends Map<String, dynamic>> {
  DocumentSnapshot(this.id, this._data, {DocumentReference<T>? ref})
    : reference = ref ?? DocumentReference<T>(id);

  final String id;
  final T? _data;
  final DocumentReference<T> reference;

  T? data() => _data;

  bool get exists => _data != null;

  DocumentReference<T> get ref => reference;
}

class QueryDocumentSnapshot<T extends Map<String, dynamic>>
    extends DocumentSnapshot<T> {
  QueryDocumentSnapshot(super.id, T super.data);

  @override
  T data() => super.data() ?? <String, dynamic>{} as T;
}

class QuerySnapshot<T extends Map<String, dynamic>> {
  const QuerySnapshot([this.docs = const []]);

  final List<QueryDocumentSnapshot<T>> docs;
}

class DocumentReference<T extends Map<String, dynamic>> {
  const DocumentReference(this.id);

  final String id;

  Future<DocumentSnapshot<T>> get() async => DocumentSnapshot<T>(id, null);

  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {}

  Future<void> update(Map<String, dynamic> data) async {}

  Future<void> delete() async {}

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      CollectionReference<Map<String, dynamic>>(path);
}

class Query<T extends Map<String, dynamic>> {
  const Query(this.path);

  final String path;

  Query<T> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  }) => this;

  Query<T> orderBy(Object field, {bool descending = false}) => this;

  Query<T> limit(int limit) => this;

  Query<T> limitToLast(int limit) => this;

  Future<QuerySnapshot<T>> get() async => QuerySnapshot<T>(<QueryDocumentSnapshot<T>>[]);

  Stream<QuerySnapshot<T>> snapshots() => Stream<QuerySnapshot<T>>.value(
    QuerySnapshot<T>(<QueryDocumentSnapshot<T>>[]),
  );
}

class CollectionReference<T extends Map<String, dynamic>> extends Query<T> {
  const CollectionReference(super.path);

  DocumentReference<T> doc([String? id]) =>
      DocumentReference<T>(id ?? DateTime.now().microsecondsSinceEpoch.toString());

  Future<DocumentReference<T>> add(Map<String, dynamic> data) async => doc();
}

class LegacyDataStore {
  const LegacyDataStore._();

  static const LegacyDataStore instance = LegacyDataStore._();

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      CollectionReference<Map<String, dynamic>>(path);

  DocumentReference<Map<String, dynamic>> doc(String path) =>
      DocumentReference<Map<String, dynamic>>(path);

  WriteBatch batch() => WriteBatch();
}

class FieldPath {
  const FieldPath._();

  static String documentId() => '__name__';
}

class WriteBatch {
  void set(
    DocumentReference<Map<String, dynamic>> reference,
    Map<String, dynamic> data, [
    SetOptions? options,
  ]) {}

  void update(
    DocumentReference<Map<String, dynamic>> reference,
    Map<String, dynamic> data,
  ) {}

  void delete(DocumentReference<Map<String, dynamic>> reference) {}

  Future<void> commit() async {}
}

class BackendFunctionClient {
  const BackendFunctionClient._();

  static const BackendFunctionClient instance = BackendFunctionClient._();

  BackendCallable httpsCallable(String name) => BackendCallable(name);
}

class BackendCallable {
  const BackendCallable(this.name);

  final String name;

  Future<BackendCallableResult> call([Object? parameters]) async {
    throw BackendFunctionException(
      code: 'unsupported',
      message: 'Backend callable $name is not available in the mobile runtime.',
    );
  }
}

class BackendCallableResult {
  const BackendCallableResult(this.data);

  final Object? data;
}
