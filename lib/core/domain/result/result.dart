import '../failures/failure.dart';

class Result<T> {
  final T? _value;
  final Failure? _failure;

  const Result._(this._value, this._failure);

  factory Result.success(T value) => Result._(value, null);
  factory Result.failure(Failure failure) => Result._(null, failure);

  bool get isSuccess => _failure == null;
  T? get valueOrNull => _value;
  Failure? get failureOrNull => _failure;
}
