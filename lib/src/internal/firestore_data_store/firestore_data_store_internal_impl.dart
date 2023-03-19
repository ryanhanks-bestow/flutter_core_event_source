import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:core_event_source/entry.dart';
import 'package:core_event_source/event_source.dart';

import '../../../internal.dart';

typedef HasContention = bool Function(DocumentSnapshot<EntryRef?>);

class FirestoreEntryStoreImpl<Event>
    implements FirestoreDataStoreInternal<Event> {
  static HasContention hasContention =
      (documentSnapshot) => documentSnapshot.exists;
  final CollectionReference<Entry<Event>> _entryCollectionReference;
  final CollectionReference<EntryRefLog> _mainEntryRefLogCollectionReference;
  final CollectionReference<EntryRefLog> _headEntryRefLogCollectionReference;
  final CollectionReference<EntryRef> _headRefCollectionReference;
  final DocumentReference<EntryRef> _mainRefDocumentReference;
  final DocumentReference<EntryRef?> _mainRefMaybeDocumentReference;
  final HasContention _hasContention;
  final IdFactory _idFactory;
  final EntryRefLogFactory _entryRefLogFactory;

  factory FirestoreEntryStoreImpl.from(
    FirebaseFirestore firestore,
    String path,
    String headRef,
    JsonEventConverter<Event> eventConverter, {
    HasContention? hasContention,
    IdFactory? idFactory,
    EntryRefLogFactory? entryRefLogFactory,
  }) {
    final entryCollectionReference = firestore
        .doc(path)
        .collection('objects')
        .withConverter<Entry<Event>>(
            fromFirestore: (doc, options) => Entry.fromJson(
                doc.data()!,
                (json) => eventConverter
                    .fromJsonObject(json as Map<String, dynamic>)),
            toFirestore: (data, options) =>
                data.toJson(eventConverter.toJsonObject));
    final headRefCollectionReference = firestore
        .doc(path)
        .collection('heads')
        .doc(headRef)
        .collection('refs')
        .withConverter(
            fromFirestore: (doc, options) => EntryRef.fromJson(doc.data()!),
            toFirestore: (data, options) => data.toJson());
    final mainRefDocumentReference = firestore.doc(path).withConverter(
        fromFirestore: (doc, options) => EntryRef.fromJson(doc.data()!),
        toFirestore: (data, options) => data.toJson());
    final mainRefMaybeDocumentReference = firestore.doc(path).withConverter(
        fromFirestore: (doc, options) =>
            doc.exists ? EntryRef.fromJson(doc.data()!) : null,
        toFirestore: (data, options) => data?.toJson() ?? {});
    final headEntryRefLogCollectionReference = firestore
        .doc(path)
        .collection('heads')
        .doc(headRef)
        .collection('refLog')
        .withConverter(
            fromFirestore: (doc, options) => EntryRefLog.fromJson(doc.data()!),
            toFirestore: (data, options) => data.toJson());
    final mainEntryRefLogCollectionReference = firestore
        .doc(path)
        .collection('heads')
        .doc(headRef)
        .collection('refLog')
        .withConverter(
            fromFirestore: (doc, options) => EntryRefLog.fromJson(doc.data()!),
            toFirestore: (data, options) => data.toJson());
    return FirestoreEntryStoreImpl(
      entryCollectionReference: entryCollectionReference,
      headRefCollectionReference: headRefCollectionReference,
      mainRefDocumentReference: mainRefDocumentReference,
      mainRefMaybeDocumentReference: mainRefMaybeDocumentReference,
      headEntryRefLogCollectionReference: headEntryRefLogCollectionReference,
      hasContention: hasContention,
      idFactory: idFactory,
      entryRefLogFactory: entryRefLogFactory,
      mainEntryRefLogCollectionReference: mainEntryRefLogCollectionReference,
    );
  }

  FirestoreEntryStoreImpl({
    required CollectionReference<Entry<Event>> entryCollectionReference,
    required CollectionReference<EntryRef> headRefCollectionReference,
    required DocumentReference<EntryRef> mainRefDocumentReference,
    required DocumentReference<EntryRef?> mainRefMaybeDocumentReference,
    required CollectionReference<EntryRefLog>
        headEntryRefLogCollectionReference,
    required CollectionReference<EntryRefLog>
        mainEntryRefLogCollectionReference,
    HasContention? hasContention,
    IdFactory? idFactory,
    EntryRefLogFactory? entryRefLogFactory,
  })  : _mainRefDocumentReference = mainRefDocumentReference,
        _mainRefMaybeDocumentReference = mainRefMaybeDocumentReference,
        _headRefCollectionReference = headRefCollectionReference,
        _entryCollectionReference = entryCollectionReference,
        _headEntryRefLogCollectionReference =
            headEntryRefLogCollectionReference,
        _mainEntryRefLogCollectionReference =
            mainEntryRefLogCollectionReference,
        _hasContention = hasContention ?? FirestoreEntryStoreImpl.hasContention,
        _idFactory = idFactory ?? IdFactory.random(),
        _entryRefLogFactory =
            entryRefLogFactory ?? EntryRefLogFactory(DateTimeFactory.now());

  @override
  Stream<QuerySnapshot<Entry<Event>>> get entryQuerySnapshots =>
      _entryCollectionReference.snapshots(includeMetadataChanges: true);

  @override
  Future<EntryRef?> get headEntryRef => _headRefCollectionReference
      .orderBy('createdAt', descending: true)
      .limit(1)
      .get()
      .then((value) => value.docs.firstOrNull?.data());

  @override
  Future<Entry<Event>> get rootEntry async =>
      (await _entryCollectionReference.doc(EntryRef.root.value).get()).data()!;

  @override
  Future<void> initialize(Entry<Event> rootEntryIfEmpty) async {
    assert(rootEntryIfEmpty.refs.isEmpty); // initial entry can't have parent
    assert(rootEntryIfEmpty
        .events.isEmpty); // initial entry events not supported atm
    final mainRefDoc = await _mainRefMaybeDocumentReference.get();
    if (mainRefDoc.exists) {
      return;
    }

    final initialEntry = rootEntryIfEmpty;
    await _entryCollectionReference.firestore
        .runTransaction((transaction) async {
      final mainRef = await transaction.get(_mainRefMaybeDocumentReference);
      if (_hasContention(mainRef)) {
        return false;
      } else {
        transaction.set(_entryCollectionReference.doc(initialEntry.ref.value),
            initialEntry);
        transaction.set(_mainRefDocumentReference, initialEntry.ref);
      }
    });
  }

  @override
  Future<EntryRef> get mainEntryRef async =>
      (await _mainRefDocumentReference.get()).data()!;

  @override
  Stream<DocumentSnapshot<EntryRef>> get mainEntryRefSnapshotStream =>
      _mainRefDocumentReference.snapshots(includeMetadataChanges: true);

  @override
  Future<void> updateHeadEntry(Entry<Event> entry) async {
    final batch = _entryCollectionReference.firestore.batch();
    batch.set(_entryCollectionReference.doc(entry.ref.value), entry);
    batch.set(_headRefCollectionReference.doc(_idFactory.create()), entry.ref);
    batch.set(_mainEntryRefLogCollectionReference.doc(_idFactory.create()),
        _entryRefLogFactory.apply(previous: entry.refs.first, next: entry.ref));
    await batch.commit();
  }

  @override
  Future<void> updateMainEntryRef(EntryRef previous, EntryRef next) async {
    await _entryCollectionReference.firestore
        .runTransaction((transaction) async {
      final mainRef =
          (await transaction.get(_mainRefDocumentReference)).data()!;
      if (mainRef != previous) {
        return Null;
      } else {
        transaction.set(_mainRefDocumentReference, next);
        final log = _entryRefLogFactory.forward(previous: previous, next: next);
        transaction.set(
            _mainEntryRefLogCollectionReference.doc(_idFactory.create()), log);
      }
    });
  }

  @override
  Future<void> forwardHeadEntryRef(EntryRef previous, EntryRef next) async {
    final batch = _headRefCollectionReference.firestore.batch();
    batch.set(_headRefCollectionReference.doc(_idFactory.create()), next);
    batch.set(_mainEntryRefLogCollectionReference.doc(_idFactory.create()),
        _entryRefLogFactory.forward(previous: previous, next: next));
    await batch.commit();
  }

  @override
  Future<void> resetHeadEntryRef(EntryRef previous, EntryRef next) async {
    final batch = _headRefCollectionReference.firestore.batch();
    batch.set(_headRefCollectionReference.doc(_idFactory.create()), next);
    batch.set(_mainEntryRefLogCollectionReference.doc(_idFactory.create()),
        _entryRefLogFactory.reset(previous: previous, next: next));
    await batch.commit();
  }

  @override
  Future<Iterable<EntryRefLog>> get entryRefLog async =>
      (await _mainEntryRefLogCollectionReference.orderBy('createdAt').get())
          .docs
          .map((e) => e.data());
}
