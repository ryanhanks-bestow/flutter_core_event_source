import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_event_source/event_source.dart';

import '../../../flutter_core_event_source.dart';
import '../../../internal.dart';

class FirestoreEventStoreImpl implements FirestoreEventStore {
  final FirebaseFirestore firestore;

  FirestoreEventStoreImpl({required this.firestore});

  @override
  SourceReference<Event> source<Event>(
      {required String path, required JsonEventConverter<Event> reader}) {
    return FirestoreSourceReferenceImpl<Event>(
        firestore: firestore, path: path, eventJsonConverter: reader);
  }
}
