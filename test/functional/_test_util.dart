import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_event_source/event_source.dart';
import 'package:flutter_core_event_source/flutter_core_event_source.dart';

import '../test_doubles/fake_behavior.dart';

Future<EventSource<FakeCommand, FakeView>> buildTestEventSourceInstance({
  required FirebaseFirestore firestore,
  required String headRefId,
}) async {
  return await FirestoreEventStore.instanceFor(firestore: firestore)
      .source(path: 'test/1', reader: FakeEventJsonConverter())
      .head(headRefId)
      .get<FakeCommand, FakeState, FakeView>(behavior: FakeBehavior());
}
