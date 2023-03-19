import 'package:integration_test/integration_test.dart';

import '../test/functional/execute_commands_test.dart' as execute_commands_test;
import '../test/util/logging.dart';

main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  initializeDebugLogging();
  final mains = [
    // firestore_event_store_test.main,
    execute_commands_test.main,
    // event_source_impl_test.main
  ];
  for (final main in mains) {
    main();
  }
}
