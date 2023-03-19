// import 'package:core_event_source/event_source.dart';
// import 'package:core_event_source/event_sourced_behavior.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// import '../util/event_sourced_behavior_fake.dart';
// import '../util/fake_firebase_firestore.dart';

typedef Command = Map<String, dynamic>;
typedef Event = Map<String, dynamic>;
typedef State = Map<String, dynamic>;
typedef View = Map<String, dynamic>;

main() {}
// main() {
//   late FakeFirebaseFirestore firestore;
//   late EventStore eventStore;
//   late String sourceId = '1';
//   // late String instanceId = 'a';
//   late SourceReference sourceReference;
//   late EventSource source;
//   JsonEventConverter<Event> reader = JsonEventConverter(
//       (p0) => p0 as Map<String, dynamic>, (object) => object);
//   late EventSourcedBehaviorFake<Command, Event, State, View> behavior;
//   String path() => 'sources/$sourceId';
//   group('initialize, apply, validate', () {
//     setUp(() async {
//       firestore = FakeFirebaseFirestore('app2');
//       eventStore = EventStore.instanceFor(firestore: firestore);
//       behavior = EventSourcedBehaviorFake(commandHandler: (state, command) {
//         return EventSourcedBehaviorEffect.persist([{}]);
//       }, eventHandler: (state, event) {
//         return state..['value'] = 1;
//       });
//       sourceReference = eventStore.source(
//         path: path(),
//         reader: reader,
//       );
//       source = await sourceReference.head('1').get(behavior: behavior);
//     });
//     test('apply a transaction', () async {
//       source.execute([{}]);
//       //
//       // await source.close();
//       // print(source.view.state);
//       // sourceReference;
//       // source = await sourceReference.start();
//     });
//     // test('reload instance and validate state', () async {
//     //   // final doc = await ref2.get();
//     //   // print(doc.data());
//     //   print(eventStore);
//     // });
//   });
// }
