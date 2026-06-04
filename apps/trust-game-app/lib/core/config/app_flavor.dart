enum AppFlavor {
  dev,
  test,
  prod;

  static AppFlavor fromName(String name) {
    return switch (name) {
      'dev' => AppFlavor.dev,
      'test' => AppFlavor.test,
      'prod' => AppFlavor.prod,
      _ => AppFlavor.dev,
    };
  }
}
