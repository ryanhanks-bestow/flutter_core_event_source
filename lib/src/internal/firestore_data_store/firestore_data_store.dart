import 'package:core_event_source/entry.dart';
import 'package:core_event_source/internal.dart';
import 'package:rxdart/rxdart.dart';

import '../../../internal.dart';

class FirestoreDataStore<Event> implements CoreDataStore<Event> {
  final FirestoreDataStoreInternal<Event> entryStore;

  FirestoreDataStore(this.entryStore);

  @override
  Stream<Iterable<EntrySnapshot<Event>>> get entrySnapshotsStream =>
      entryStore.entryQuerySnapshots.map((querySnapshot) => querySnapshot.docs
          .map((documentSnapshot) => EntrySnapshot<Event>(
              documentSnapshot.data(),
              isPending: documentSnapshot.metadata.hasPendingWrites)));

  @override
  Future<EntryRef?> get headEntryRef async => (await entryStore.headEntryRef);

  @override
  Future<Entry<Event>> get rootEntry async => (await entryStore.rootEntry)!;

  @override
  Future<void> initialize(Entry<Event> rootEntryIfEmpty) =>
      entryStore.initialize(rootEntryIfEmpty);

  @override
  Future<EntryRef> get mainEntryRef async => await entryStore.mainEntryRef;

  @override
  Future<EntryRef?> get mainEntryRefMaybe async =>
      (await entryStore.mainEntryRef);

  @override
  Stream<EntryRef> get mainEntryRefStream =>
      entryStore.mainEntryRefSnapshotStream
          .map((snapshot) => snapshot.data())
          .whereNotNull();

  @override
  Future<void> appendHeadEntry(Entry<Event> entry) =>
      entryStore.updateHeadEntry(entry);

  @override
  Future<void> forwardHeadEntryRef(EntryRef previous, EntryRef next) =>
      entryStore.forwardHeadEntryRef(previous, next);

  @override
  Future<void> updateMainEntryRef(EntryRef previous, EntryRef next) =>
      entryStore.updateMainEntryRef(previous, next);

  @override
  Future<void> resetHeadEntryRef(EntryRef previous, EntryRef next) =>
      entryStore.resetHeadEntryRef(previous, next);
}
