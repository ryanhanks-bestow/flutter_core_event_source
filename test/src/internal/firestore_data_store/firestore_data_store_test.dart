import 'package:core_event_source/common.dart';
import 'package:core_event_source/entry.dart';
import 'package:core_event_source/event_source.dart';
import 'package:core_event_source/internal.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_core_event_source/internal.dart';
import 'package:flutter_test/flutter_test.dart';

// import 'main.imports.dart';
DateTime t(int millisecondsSinceEpoch) =>
    DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

typedef Event = JsonObject;
typedef Command = JsonObject;
typedef State = int;
typedef View = int;
main() {
  JsonEventConverter<Event> eventConverter = JsonEventConverter(
      (event) => event as Map<String, dynamic>, (event) => event);
  late FakeFirebaseFirestore firestore;
  late String path;
  late String headRef;
  late FirestoreEntryStoreImpl<Event> entryStore;
  late FirestoreDataStore<Event> adapter;
  late Entry<Event> rootEntryIfEmpty;
  late DateTimeFactory dateTimeFactory;
  late EntryRefLogFactory entryRefLogFactory;
  setUp(() {
    firestore = FakeFirebaseFirestore();
    path = 'sources/1';
    headRef = 'head_1';
    dateTimeFactory = DateTimeFactory.increment();

    entryRefLogFactory = EntryRefLogFactory(dateTimeFactory);

    entryStore = FirestoreEntryStoreImpl.from(
      firestore,
      path,
      headRef,
      eventConverter,
      idFactory: IdFactory.increment(),
      entryRefLogFactory: entryRefLogFactory,
    );
    adapter = FirestoreDataStore(entryStore);

    rootEntryIfEmpty =
        Entry<Event>.newRoot(createdAt: dateTimeFactory.create());
  });
  group('initialize', () {
    test('happy path - no data', () async {
      await adapter.initialize(rootEntryIfEmpty);
      final initialEntry = await adapter.rootEntry;
      expect(initialEntry.ref.value, EntryRef.root.value);
      expect(initialEntry.refs.isEmpty, true);
      expect(initialEntry.events.isEmpty, true);
      final mainRef = await adapter.mainEntryRef;
      expect(mainRef, initialEntry.ref);
    });
    test('happy path - data exists', () async {
      final previousAdapter = FirestoreEntryStoreImpl.from(
          firestore, path, headRef, eventConverter);
      await previousAdapter.initialize(rootEntryIfEmpty);
      await adapter.initialize(rootEntryIfEmpty);
      final initialEntry = await adapter.rootEntry;
      expect(initialEntry.ref.value, EntryRef.root.value);
      expect(initialEntry.refs.isEmpty, true);
      expect(initialEntry.events.isEmpty, true);
      final mainRef = await adapter.mainEntryRef;
      expect(mainRef, initialEntry.ref);
    });
    test('happy path - contention arises', () async {
      entryStore = FirestoreEntryStoreImpl.from(
        firestore,
        path,
        headRef,
        eventConverter,
        idFactory: IdFactory.increment(),
        entryRefLogFactory: entryRefLogFactory,
        hasContention: (_) => true,
      );
      adapter = FirestoreDataStore(entryStore);
      await adapter.initialize(rootEntryIfEmpty);
      final initialEntry = await entryStore.mainEntryRef;
      expect(initialEntry, null);
    }, skip: true);
  });
  group('update head entry', () {
    test('updateHeadEntry', () async {
      await adapter.initialize(rootEntryIfEmpty);
      final entry1 = Entry<Event>(
          ref: const EntryRef('entry1'),
          refs: [EntryRef.root],
          events: [{}],
          createdAt: t(1));
      await adapter.appendHeadEntry(entry1);
      expect(await adapter.headEntryRef, entry1.ref);
      expect(await entryStore.entryRefLog, [
        EntryRefLog.apply(
            previousRef: EntryRef.root, nextRef: entry1.ref, createdAt: t(2))
      ]);
    });
  });
  group('forward head ref', () {
    test('updateHeadEntryRef', () async {
      await adapter.initialize(rootEntryIfEmpty);
      const entryRef1 = EntryRef('entry1');
      const entryRef2 = EntryRef('entry2');
      await adapter.forwardHeadEntryRef(entryRef1, entryRef2);
      expect(await adapter.headEntryRef, entryRef2);
      expect(await entryStore.entryRefLog, [
        EntryRefLog.forward(
            previousRef: entryRef1, nextRef: entryRef2, createdAt: t(2))
      ]);
    });
  });
  group('reset head ref', () {
    test('resetHeadEntryRef', () async {
      await adapter.initialize(rootEntryIfEmpty);
      const entryRef1 = EntryRef('entry1');
      const entryRef2 = EntryRef('entry2');
      await adapter.resetHeadEntryRef(entryRef1, entryRef2);
      expect(await adapter.headEntryRef, entryRef2);
      expect(await entryStore.entryRefLog, [
        EntryRefLog.reset(
            previousRef: entryRef1, nextRef: entryRef2, createdAt: t(2))
      ]);
    });
  });
  group('mainEntryRefSnapshotStream', () {
    test('initial state', () async {
      await adapter.initialize(rootEntryIfEmpty);
      expect(await adapter.mainEntryRefStream.first, EntryRef.root);
      // final entryRef1 = EntryRef('entry1');
      // final entryRef2 = EntryRef('entry2');
      // await adapter.resetHeadEntryRef(entryRef1, entryRef2);
      // expect(await adapter.headEntryRef, entryRef2);
      // expect(await entryStore.entryRefLog, [
      //   EntryRefLog.reset(
      //       previousRef: entryRef1, nextRef: entryRef2, createdAt: t(2))
      // ]);
    });
  });
  test('entryQuerySnapshots', () async {
    await adapter.initialize(rootEntryIfEmpty);
    expect((await adapter.entrySnapshotsStream.first).toList(),
        [EntrySnapshot(rootEntryIfEmpty, isPending: false)]);
  });
}
