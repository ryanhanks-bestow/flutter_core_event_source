import 'package:core_event_source/event_source.dart';
import 'package:core_event_source/event_sourced_behavior.dart';
import 'package:core_event_source/internal.dart' show EventSourceImpl;

import '../../../internal.dart';

class FirestoreHeadReferenceImpl<Event> extends HeadReference<Event> {
  @override
  final SourceReferenceImpl<Event> sourceReference;

  @override
  final String headRefName;

  FirestoreHeadReferenceImpl(
    this.headRefName,
    this.sourceReference,
  );

  @override
  Future<EventSource<Command, View>> start<Command, State, View>(
          EventSourcedBehavior<Command, Event, State, View> behavior) async =>
      await get(behavior: behavior);

  @override
  Future<EventSource<Command, View>> get<Command, State, View>({
    required EventSourcedBehavior<Command, Event, State, View> behavior,
  }) async {
    final entryStore = FirestoreEntryStoreImpl.from(sourceReference.firestore,
        sourceReference.path, headRefName, sourceReference.eventJsonConverter);
    final dataStore = FirestoreDataStore<Event>(entryStore);
    return EventSourceImpl.from(dataStore: dataStore, behavior: behavior);
  }
}
