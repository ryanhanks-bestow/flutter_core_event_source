import 'package:core_event_source/common.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Command = JsonObject;
typedef Event = JsonObject;
typedef State = int;
typedef View = int;

main() {
  // late EventSource<Command, Event> source1;
  // late EventSource<Command, Event> source2;

  test('merge', () {});
  // blocTest('merge',
  //     setUp: () async {
  //       source1 = buildTestEventSourceInstance(headRefId: '1');
  //       source2 = buildTestEventSourceInstance(headRefId: '2');
  //     },
  //     build: () => source2.view,
  //     act: (_) => source1.execute([{}]),
  //     expect: () => [4]);
}
