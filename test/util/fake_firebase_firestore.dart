import 'dart:math';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart'
    as fake_cloud_firestore;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeFirebaseFirestore extends fake_cloud_firestore.FakeFirebaseFirestore {
  static FakeFirebaseFirestore get newInstance =>
      FakeFirebaseFirestore(Random().nextDouble().toString());
  @override
  final FirebaseApp app;

  FakeFirebaseFirestore([String? appId]) : app = _FakeFirebaseApp(appId);
}

class _FakeFirebaseApp extends Fake implements FirebaseApp {
  @override
  final String name;

  _FakeFirebaseApp([String? appId]) : name = appId ?? 'default';
// = 'FakeFirebaseApp1';
}
