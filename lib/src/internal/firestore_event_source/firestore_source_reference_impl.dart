import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_event_source/event_source.dart';

import '../../../internal.dart';

class SourceReferenceImpl<Event> implements SourceReference<Event> {
  final FirebaseFirestore firestore;

  @override
  final String path;

  @override
  final JsonEventConverter<Event> eventJsonConverter;

  SourceReferenceImpl({
    required this.firestore,
    required this.path,
    required this.eventJsonConverter,
  });

  @override
  HeadReference<Event> head(String ref) {
    return FirestoreHeadReferenceImpl(ref, this);
  }
}
