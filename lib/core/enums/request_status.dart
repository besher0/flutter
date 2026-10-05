enum Status {
  init,
  loading,
  loaded,
  failure;

  bool get isInit => this == init;

  bool get isLoading => this == loading;

  bool get isFailed => this == failure;

  bool get isSuccess => this == loaded;
}
