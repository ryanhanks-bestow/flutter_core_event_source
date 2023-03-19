import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_event_source/event_source.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../internal.dart';

/// The entry point for accessing an [FirestoreEventStore]
abstract class FirestoreEventStore implements EventStore {
  static final Map<String, FirestoreEventStore> _cachedInstances = {};

  /// Returns an [FirestoreEventStore] instance using the default [FirebaseApp].
  static FirestoreEventStore get instance {
    return FirestoreEventStore.instanceFor(
      firestore: FirebaseFirestore.instance,
    );
  }

  /// Returns an [FirestoreEventStore] instance using a specified [FirebaseApp].
  static FirestoreEventStore instanceFor(
      {required FirebaseFirestore firestore}) {
    if (_cachedInstances.containsKey(firestore.app.name)) {
      return _cachedInstances[firestore.app.name]!;
    }

    FirestoreEventStore newInstance =
        FirestoreEventStoreImpl(firestore: firestore);
    // FlutterEventStore newInstance = EventStoreImpl(firestore: firestore);
    _cachedInstances[firestore.app.name] = newInstance;

    return newInstance;
  }

  @override
  SourceReference<Event> source<Event>({
    required String path,
    required JsonEventConverter<Event> reader,
  });
}
