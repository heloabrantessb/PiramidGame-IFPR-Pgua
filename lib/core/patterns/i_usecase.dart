abstract interface class IUseCase<T, Params> {
  Future<T> call(Params params);
}
