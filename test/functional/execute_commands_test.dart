import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_event_source/event_source.dart';
import 'package:core_event_source/event_sourced_behavior.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../integration_test/firebase_options.dart';
import '../test_doubles/fake_behavior.dart';
import '../util/debug_bloc_observer.dart';
import '../util/fake_firebase_firestore.dart';
import '_test_util.dart';

String kEmulatorHost = '127.0.0.1';
int kAuthEmulatorPort = 9099;
int kFirestoreEmulatorPort = 8080;
late FirebaseApp app;

late FirebaseAuth auth;

late String email;
late String password;
late String userId;

late FirebaseFirestore firestore;

late String sourcePath;
late String sourceHeadRef;

late JsonEventConverter<FakeEvent> reader;
late EventSourcedBehavior<FakeCommand, FakeEvent, FakeState, FakeView> behavior;
late EventSource<FakeCommand, FakeView> source;

main() {
  late EventSource<FakeCommand, FakeView> source1;
  late FirebaseFirestore firestore;
  late FirebaseAuth auth;
  DebugBlocObserver.observe();
  blocTest(
    'execute command',
    setUp: () async {
      app = await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      auth = FirebaseAuth.instanceFor(app: app);
      await auth.useAuthEmulator(kEmulatorHost, kAuthEmulatorPort);
      final userNumber = Random().nextInt(1000);
      email = 'test.user-$userNumber@bestow.world';
      password = 'abc123!';

      try {
        await auth.createUserWithEmailAndPassword(
            email: email, password: password);
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') {
          rethrow;
        }
      }
      await auth.signInWithEmailAndPassword(email: email, password: password);
      final userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      userId = userCredential.user!.uid;

      firestore = FirebaseFirestore.instance;
      firestore.useFirestoreEmulator('127.0.0.1', 8080);
      source1 = await buildTestEventSourceInstance(
          headRefId: '1', firestore: firestore);
    },
    build: () => source1,
    act: (_) {
      source1.execute([{}]);
    },
    expect: () => [2],
  );
  blocTest(
    'execute two command, same execution',
    setUp: () async {
      firestore = FakeFirebaseFirestore.newInstance;
      source1 = await buildTestEventSourceInstance(
          headRefId: '1', firestore: firestore);
    },
    build: () => source1,
    act: (_) {
      source1.execute([{}, {}]);
    },
    expect: () => [4],
  );
  blocTest(
    'execute two command, same instance',
    setUp: () async {
      firestore = FakeFirebaseFirestore.newInstance;
      source1 = await buildTestEventSourceInstance(
          headRefId: '1', firestore: firestore);
    },
    build: () => source1,
    act: (_) {
      source1.execute([{}]);
      source1.execute([{}]);
    },
    expect: () => [2, 4],
  );
  blocTest(
    'execute commands on separate source instances, in sequence',
    setUp: () async {
      firestore = FakeFirebaseFirestore.newInstance;

      source1 = await buildTestEventSourceInstance(
          headRefId: '1', firestore: firestore);

      final done = source1.stream.first.then((value) async {
        source1 = await buildTestEventSourceInstance(
            headRefId: '1', firestore: firestore);
        await source1.stream.first;
      });
      source1.execute([{}]);
      await done;
    },
    build: () => source1,
    act: (_) {
      source1.execute([{}]);
      source1.execute([{}]);
    },
    expect: () => [4, 8],
  );
}
