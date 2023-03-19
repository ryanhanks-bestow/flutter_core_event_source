import 'package:core_event_source/event_source.dart';
import 'package:flutter_core_event_source/flutter_core_event_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/fake_firebase_firestore.dart';

main() {
  test('instanceFor returns EventStore by firebase appId', () {
    final firestore1 = FakeFirebaseFirestore('1');
    final firestore2 = FakeFirebaseFirestore('2');
    final eventStore1 = FirestoreEventStore.instanceFor(firestore: firestore1);
    final eventStore2 = FirestoreEventStore.instanceFor(firestore: firestore2);
    expect(eventStore1 == eventStore2, false);
    final firestore3 = FakeFirebaseFirestore('1');
    final eventStore3 = FirestoreEventStore.instanceFor(firestore: firestore3);
    expect(eventStore1, eventStore3);
  });
}
