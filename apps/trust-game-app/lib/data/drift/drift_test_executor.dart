import 'package:drift/drift.dart';

import 'drift_test_executor_unsupported.dart'
    if (dart.library.io) 'drift_test_executor_io.dart';

QueryExecutor createDriftTestExecutor() {
  return createPlatformDriftTestExecutor();
}
